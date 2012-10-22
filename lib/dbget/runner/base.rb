require 'optparse'

module DBGet
  module Runner
    class Base
      def self.boot(args)
        self.new(args).run!
      end

      def initialize(args)
        @options = {}
        @options['db'] = args.shift
        @optparse = optparser
      end

      def set_env_defaults
        if ENV.include?('DBGET_PATH')
          @dbget_path = ENV['DBGET_PATH']
        else
          raise "DBGET_PATH not defined!"
        end

        @options['append_date'] = ENV['dbget_append_date']
        @options['clean'] = ENV['dbget_clean'] || false
        @options['collections'] = ENV['dbget_collections']
        @options['custom_name'] = ENV['dbget_custom_name']
        @options['date'] = ENV['dbget_date']
        @options['source'] = ENV['dbget_source']
        @options['suffix'] = ENV['dbget_suffix']
        @options['type'] = ENV['dbget_type']
        @options['user'] = ENV['dbget_user']
      end

      def run!
        set_env_defaults

        unless @options['db'].empty?
          @optparse.parse!
          DBGet.read_config(@dbget_path)
          prepare_dump_options(@options)

          DBGet::Controller.boot(@options)
        else
          p @optparse.help
          exit 1
        end
      end

      def prepare_dump_options(options)
        options['collections'] = get_final_collection(options['collections'])
        options['date'] = format_date(options['date'])
        options
      end

      def get_final_collection(collection)
        unless collection.nil?
          collection.split(',')
        else
          []
        end
      end

      def format_date(date)
        unless date.nil?
          Date.strptime(date, "%Y-%m-%d")
        end
      end

      def optparser
        OptionParser.new do |opts|
          opts.banner = "Usage: dbget-jenkins db [options]\n"
          opts.separator "Options:"

          opts.on('-d', '--date DATE', 'Date of database dump (yyyy-mm-dd).') {|date| @options['date'] = date}
          opts.on('-c', '--clean', 'Drops the database before dumping') {@options['clean'] = true}
          opts.on('--source SOURCE', 'Specify the source that contained the database.') {|source| @options['source'] = source}
          opts.on('-a', '--append-date', 'Append the given date as suffix') { @options['append_date'] = true }
          opts.on('--collections COLLECTION', 'Only dump specific mongodb collections separated by comma') {|collection| @options['collections'] = collection}
          opts.on('-n', '--name NAME', 'Specify a custom name/key for databases') {|name| @options['custom_name'] = name}
          opts.on('-u', '--user USER', 'Database name prefixed username') {|user| @options['user'] = user}
          opts.on('--suffix SUFFIX', 'Database name prefixed username') {|suffix| @options['suffix'] = suffix}
          opts.on('--type TYPE', 'Database type: Mongo or MySQL') {|type| @options['type'] = type}
        end
      end
    end
  end
end
