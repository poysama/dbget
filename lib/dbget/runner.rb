module DBGet
  class Runner
    def self.boot(user, options)
      self.new(parse_options(user, options)).run!
    end

    def self.parse_options(user, options)
      opts = {}
      opts['user'] = user

      options.each do |o|
        k, v = o.split('=')
        opts[k] = v
      end

      opts
    end

    def initialize(options)
      @options = options
    end

    def run!
      init_config(get_dbget_path)
      prepare_dump_options
      dump
    end

    def prepare_dump_options
      @options['collections'] = get_final_collection(@options['collections'])
      @options['date'] = format_date(@options['date'])
      @options['clean'] = Utils.to_bool(@options['clean'])
      @options['verbose'] = Utils.to_bool(@options['verbose'])
      @options['append_date'] = Utils.to_bool(@options['append_date'])
    end

    def get_final_collection(collection)
      unless collection == 'EMPTY'
        collection.split(',')
      else
        []
      end
    end

    def format_date(date)
      unless date == 'xxxx-xx-xx'
        Date.strptime(date, "%Y-%m-%d")
      end
    end

    def dump
      Controller.boot(@options)
    end

    def get_dbget_path
      if ENV.include?('DBGET_PATH')
        ENV['DBGET_PATH']
      else
        raise "DBGET_PATH not defined"
      end
    end

    def init_config(dbget_path)
      DBGet.read_config(dbget_path)
    end
  end
end
