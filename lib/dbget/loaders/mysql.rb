module DBGet
  module Loaders
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
        form_db_name
        clean_dump if @dump.clean?
        create_db_if_not_exist

        if dump_file_exist?
          dump_mysql
        else
          raise "Dump for #{@dump.decrypted_dump} not found!"
        end

        puts "Hooray! Dump for #{@dump.decrypted_dump} done!"
      end

      def form_db_name
        if @dump.date.nil?
          @dump.db_name = "#{@dump.user}_#{@dump.db_name}"
        else
          @dump.db_name = "#{@dump.user}_#{@dump.db_name}_#{get_converted_date}"
        end
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
        system "echo \"DROP DATABASE IF EXISTS #{@dump.db_name}\" | #{@dump_command}"
      end

      def create_db_if_not_exist
        system "echo \"CREATE DATABASE IF NOT EXISTS #{@dump.db_name}\" | #{@dump_command}"
      end

      def dump_file_exist?
        File.exist?(@dump.decrypted_dump) and !File.size?(@dump.decrypted_dump).nil?
      end

      def dump_mysql
        @dump_command += " #{@dump.db_name} "

        puts "Dumping #{@dump.name} to #{@dump.db_name}..."

        system "#{@dump_command}< #{File.join(@dump.decrypted_dump)}"
      end
    end
  end
end
