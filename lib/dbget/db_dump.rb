require 'fileutils'

module DBGet
  class DBDump

    BASE_BACKUPS_PATH = DBGet::Config.instance['backups']['path']
    CACHE_PATH = DBGet::Config.instance['backups']['cache']

    def initialize(opts)
      @name = opts['db']
      @date = Date.strptime(opts['date'], "%m-%d-%Y") unless opts['date'] == 'date'
      @server = opts['server']
      @db_type = opts['dbtype']
      @storage_path = File.join(BASE_BACKUPS_PATH, opts['server'], @db_type)
      @db_name = get_full_db_name
      @db_file_path = nil
      @status = ''
      @status_description = ''
    end

    def read
      if @status != "ERROR"
        sql_dump = get_dump
      end

      if !sql_dump.nil?
        @status = "SUCCESS"
      end

      instance_variables.each do |i|
        puts "#{i.to_s.delete('@')}: #{instance_variable_get(i)}"
      end

      puts "\r\n"

      if @status == "SUCCESS"
        File.read(sql_dump)
      end
    end

    protected

    def get_dump
      @db_file_path = find_dump_file(@db_name)

      if !@db_file_path.nil?
        if File.exists? File.join(CACHE_PATH, File.basename(@db_file_path, ".*"))
          File.join(CACHE_PATH, File.basename(@db_file_path, ".*"))
        elsif File.exists? @db_file_path
          compressed_db_dump = copy_to_cache(@db_file_path)

          if File.extname(compressed_db_dump) == ".enc"
            compressed_db_dump = Utils.decode_file(compressed_db_dump)
          end

          decompressed_db_dump = Utils.decompress_file(compressed_db_dump)

          # Disabled masking for the meantime until caresharing_guid
          # if db_name.match(/.caresharing_/)
          #  masked_db_dump = Utils.mask(decompressed_db_dump)
          # else
          #    masked_db_dump = decompressed_db_dump
          # end
          masked_db_dump = decompressed_db_dump
          compressed_db_dump = Utils.compress_file(masked_db_dump)
        end
      else
        @status = "ERROR"
        @status_description = "Empty db file path!"
      end
    end

    def get_full_db_name
      begin
        if !@name.nil? and !@db_type.nil?
          DBGet::Config.instance['mapping'][@name][@db_type]
        end
      rescue
        @status = "ERROR"
        @status_description = "Database #{@name} not found in server config!"
      end
    end

    def find_dump_file(db_name)
      monthly_dir_path = File.join(@storage_path, db_name.to_s)
      monthly_dirs = Dir["#{monthly_dir_path}/*/"].sort

      if !monthly_dirs.empty?
        db_month = latest? ? File.basename(monthly_dirs.last) : @date.strftime("%Y%m")
        db_dumps_path = File.join(monthly_dir_path.to_s, db_month.to_s)
        db_dumps = Utils.list_files(db_dumps_path)

        if latest?
          db_file = db_dumps.last
        else
          db_dumps.each do |filename|
            if filename.include? "-#{@date.strftime("%Y%m%d")}"
              db_file = filename
              break
            end
          end
        end

        File.join(db_dumps_path, db_file)
      else
        @status = "ERROR"
        @status_description = "No dump file found!"
      end
    end

    def copy_to_cache(file_path)
      FileUtils.mkdir_p(CACHE_PATH)
      FileUtils.cp(file_path, CACHE_PATH)

      File.join(CACHE_PATH, File.basename(file_path))
    end

    def latest?
      @date.nil?
    end
  end
end
