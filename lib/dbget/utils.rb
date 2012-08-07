require 'csv'
require 'benchmark'

module DBGet
  module Utils

    def self.get_files(path)
      Dir.new(path).entries - %w{ . .. }.sort
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

    def self.say(message, subitem = false)
      puts "#{subitem ? "   ->" : "--"} #{message}"
    end

    def self.say_with_time(message)
      say(message)
      result = nil
      time = Benchmark.measure { result = yield }
      say "%.4fs" % time.real, :subitem
      say("#{result} rows", :subitem) if result.is_a?(Integer)
      result
    end

    def self.randomize(size)
      chars = ('a'..'z').to_a + ('A'..'Z').to_a
      (0...size).collect { chars[Kernel.rand(chars.length)] }.join
    end

    def self.to_bool(string)
      return true if string == true || string =~ (/(true|t|yes|y|1)$/i)
      return false if string == false || string.empty? || string =~ (/(false|f|no|n|0)$/i)
      raise ArgumentError.new("invalid value for Boolean: \"#{string}\"")
    end

    def self.form_db_name(dump)
      if dump.date.nil?
        dump.db_name = "#{dump.user}_#{dump.db_name}"
      else
        dump.db_name = "#{dump.user}_#{dump.db_name}_#{get_converted_date(dump)}"
      end
    end

    def self.get_converted_date(dump)
      dump.date.to_s.delete('-')
    end
  end
end
