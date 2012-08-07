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
      @dump.get_final_dump
      load_dump
    end

    def user_allowed?
      unless @config['users'].include?(@dump.user)
        raise "User not allowed to dump"
        exit 1
      end
    end

   def load_dump
      case @dump.db_type
      when 'mysql'
        DBGet::Loaders::MySql.boot(@dump, @config).load!
      when 'mongo'
        DBGet::Loaders::Mongo.boot(@dump, @config).load!
      else
        raise "Dump is not supported!"
      end
    end
  end
end
