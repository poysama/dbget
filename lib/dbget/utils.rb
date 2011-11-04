require 'csv'

module DBGet
  module Utils

    def self.list_files(path)
      dirs = []
      Dir.new(path).entries.each do |dir_name|
        dirs.push(dir_name) if dir_name != "." and dir_name != ".."
      end
      dirs.sort
    end

    def self.decode_file(input_file)
      output_file = input_file.sub(/\.enc$/, "")
      pass_phrase = DBGet::Config.instance['openssl']['passphrase']

      command =  "openssl enc -d -aes-256-cbc -in #{input_file}"
      command += " -pass pass:#{pass_phrase}"
      command += " -out #{output_file}; rm #{input_file}"
      system command

      output_file
    end

    def self.decompress_file(input_file)
      command = "gzip -df #{input_file}"
      system command

      input_file.sub(/\.gz$/, "")
    end

    def self.compress_file(input_file)
      command = "gzip #{input_file}"
      system command

      input_file.concat('.gz')
    end

    def self.mask(input_file)
      sql_dump = File.read(input_file)

      mask_config = load_mask_config
      mask_config.each do |table_name, table_config|
        column_info = get_columns(sql_dump, table_name, table_config)
        next_index = 0

        while string_start_index = sql_dump.index("INSERT INTO `#{table_name}` VALUES ", next_index)
          string_end_index = sql_dump.index(");", string_start_index)

          insert_string = sql_dump[string_start_index, string_end_index - string_start_index + 2]
          next_index = string_end_index - insert_string.length

          new_insert_string = "INSERT INTO `#{table_name}` VALUES "
          new_insert_string += parse_and_mask(insert_string, column_info)
          new_insert_string[-1] = ';'

          sql_dump[string_start_index, string_end_index - string_start_index + 2] = new_insert_string
          next_index += new_insert_string.length
        end
      end

      sql_file = File.open(input_file, "w")
      sql_file.write(sql_dump)
      sql_file.close

      input_file
    end

    def self.load_mask_config
      YAML.load_file(File.join(File.dirname(__FILE__), '../../config/mask.yml'))
    end

    def self.get_columns(sql_dump, table_name, table_config)
      column_array = []
      column_hash = {}

      start_index = sql_dump.index("CREATE TABLE `#{table_name}` (\n")
      end_index = sql_dump.index(';', start_index)

      create_string = sql_dump[start_index, end_index - start_index + 1]
      columns_start = create_string.index("\n") + 1

      parsed_create_string = create_string[columns_start, end_index - columns_start]

      parsed_create_string.each_line do |l|
        if column_name = l.match(/`([^`]*)`/) and !l.include?('KEY')
          column_array.push(column_name[1])
        end
      end

      column_array.each_with_index { |n, i| column_hash[n] = [i] }
      table_config['columns'].each { |k, v| column_hash[k].push(v) }
      column_hash
    end

    def self.parse_and_mask(insert_string, column_info)
      final_insert_string = ""
      parsed_insert_string = insert_string.slice!(0, insert_string.index('('))

      until insert_string.empty?
        sliced_insert_string = insert_string.slice!(0, insert_string.index(/\)(?:(?:,\()|;)/) + 2)

        sliced_insert_string.slice!(0)
        sliced_insert_string.chomp!('),')
        sliced_insert_string.chomp!(');')
        sliced_insert_string.gsub!(/\\'(?!([,)]))/, "''")

        split_insert_string = CSV.parse(sliced_insert_string, :quote_char => "'").first
        split_insert_string.map! do |field_value|
          field_value == "NULL" ? field_value : "'#{field_value.gsub("'","\\'")}'"
        end

        column_info.each do |field_name, values|
          if values.count > 1
            unless values.last.nil?
              split_insert_string[values.first].replace("\'#{values.last}\'")
            else
              split_insert_string[values.first].replace("\'Masked\'")
            end
          end
        end

        joined_insert_string = split_insert_string.join(',')
        joined_insert_string = '('.concat(joined_insert_string)
        joined_insert_string.concat(')')
        joined_insert_string.concat(',')

        final_insert_string.concat(joined_insert_string)
      end
      final_insert_string
    end
  end
end
