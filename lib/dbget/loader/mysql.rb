module DBGet
  module Loader
    class MySql
      include Constants
      include Binaries

      def self.boot(dump, config)
        self.new(dump, config)
      end

      def initialize(dump, config)
        @dump = dump
        @config = config
        @date = @dump.date
        @dump_command = form_dump_command
      end

      def load!
        @dump.form_db_name
        clean_dump if @dump.clean?
        create_db_if_not_exist
        dump_mysql
      end

      def form_dump_command
        @dump_command = "#{Binaries.mysql_cmd} "
        @dump_command += "-h#{@config['mysql']['host']} "
        @dump_command += "-P#{@config['mysql']['port']} "
        @dump_command += "-u#{@config['mysql']['username']} "
        @dump_command += "-p#{@config['mysql']['password']} " if @config['mysql']['password']
        @dump_command
      end

      def get_converted_date
        @dump.date.to_s.delete('-')
      end

      def clean_dump
        puts "Dropping database..."
        system "echo \"DROP DATABASE IF EXISTS #{@dump.target_db}\" | #{@dump_command}"
      end

      def create_db_if_not_exist
        system "echo \"CREATE DATABASE IF NOT EXISTS #{@dump.target_db}\" | #{@dump_command}"
      end

      def dump_mysql
        @dump_command += " #{@dump.target_db} "

        out = system("#{@dump_command}< #{@dump.decrypted_dump}")
        exit 1 unless out
      end
    end
  end
end
