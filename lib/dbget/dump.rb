require 'fileutils'

module DBGet
  class Dump
    include Constants
    include Utils

    attr_reader :decrypted_dump, :db_type, :user, :name
    attr_reader :date, :clean, :verbose
    attr_accessor :db_name, :collections

    def initialize(opts)
      @name = opts['db']
      @db_type = opts['db_type']
      @user = opts['user']
      @server = opts['server']

      @collections = opts['collections']
      @date = opts['date']
      @clean = opts['clean']
      @verbose = opts['verbose']

      @storage_path = File.join(DBGet.base_backups_path, @server, @db_type)
   end

    def get_final_dump
      @db_name = get_backup_name
      @encrypted_dump = get_encrypted_dump
      @decrypted_dump = get_decrypted_dump
    end

    def clean?
      @clean
    end

    protected

    def get_decrypted_dump
      unless @encrypted_dump.nil?
        cached_file_path = File.join(DBGet.cache_path, decrypted_file_name)
        cached_file_path.concat('.tar') if @db_type.eql? 'mongo'

        if File.exists? cached_file_path
          file_path = cached_file_path
        elsif File.exists? @encrypted_dump
          cached_encrypted_file = copy_to_cache(@encrypted_dump)
          decrypted_file = decrypt_file(cached_encrypted_file)
          file_path = Utils.decompress_file(decrypted_file)
        end

        file_path
      end
    end

    def decrypted_file_name
      File.basename(@encrypted_dump.split('.').first)
    end

    def get_backup_name
      if !@name.nil? and !@db_type.nil?
        db = DBGet::Config.database(@name)

        if db.nil?
          raise "Database \'#{@name}\' not found in config!"
        end

        db[@db_type]
      end
    end

    def get_encrypted_dump
      monthly_dir_path = File.join(@storage_path, @db_name)

      unless File.exist?(monthly_dir_path)
        raise "Database \'#{@db_name}\' can't be found in #{@storage_path}!"
      end

      monthly_dirs = Utils.get_files(monthly_dir_path)

      if !monthly_dirs.empty?
        db_month = get_db_month(monthly_dirs)
        db_dumps_path = File.join(monthly_dir_path.to_s, db_month.to_s)
        db_dumps = Utils.get_files(db_dumps_path)

        File.join(db_dumps_path, get_db_file(db_dumps))
      end
    end

    def get_db_month(monthly_dirs)
      if latest?
        File.basename(monthly_dirs.last)
      else
        @date.strftime("%Y%m")
      end
    end

    def get_db_file(db_dumps)
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

      db_file
    end

   def copy_to_cache(file_path)
      FileUtils.mkdir_p(DBGet.cache_path)
      FileUtils.cp(file_path, DBGet.cache_path)

      File.join(DBGet.cache_path, File.basename(file_path))
    end

    def decrypt_file(file_path)
      if File.extname(file_path) == ".enc"
        Utils.decode_file(file_path)
      end
    end

    def latest?
      @date.nil?
    end
 end
end
