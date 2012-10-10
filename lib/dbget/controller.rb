module DBGet
  class Controller
    def self.boot(options)
      self.new(options).run!
    end

    def initialize(options)
      @dump = DBGet::Dump.new(options)
      @config = DBGet::Config.instance
    end

    def run!
      user_allowed?
      @dump.prepare
      finalize_dump
      load_dump
      status_report
    end

    def user_allowed?
      unless @config['users'].include?(@dump.user)
        raise "User not allowed to dump"
        exit 1
      end
    end

    def finalize_dump
      if @dump.in_cache? @dump.cache_file
        message = "Found cached file #{@dump.cache_file}, no need to decrypt."
      else
        message = "Decrypting #{@dump.encrypted_dump}..."
      end

      Utils.say_with_time message do
        @dump.decrypted_dump = @dump.decrypt_dump
      end

      @dump.set_final_db
    end

    def load_dump
      Utils.say_with_time "Dumping, this may take a while" do
        case @dump.type
        when 'mysql'
          DBGet::Loader::MySql.boot(@dump, @config).load!
        when 'mongo'
          DBGet::Loader::Mongo.boot(@dump, @config).load!
        else
          raise "Dump is not supported!"
        end
      end
    end

    def status_report
      Utils.say "Dump for #{@dump.db} done!"
      Utils.say "Source: #{@dump.decrypted_dump}"
      Utils.say "Target: #{@dump.target_db}"
    end
  end
end
