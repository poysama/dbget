require 'fileutils'

module DBGet
  class Dump
    include Constants
    include Utils

    attr_reader :db_type, :user, :db
    attr_reader :encrypted_dump
    attr_reader :date, :clean, :verbose, :append_date
    attr_accessor :backup_name, :collections, :target_db, :decrypted_dump

    def initialize(opts)
      @db = opts['db']
      @db_type = opts['db_type']
      @user = opts['user']
      @server = opts['server']
      @custom_name = opts['custom_name']

      @collections = opts['collections']
      @date = opts['date']
      @clean = opts['clean']
      @verbose = opts['verbose']
      @append_date = opts['append_date']

      @storage_path = File.join(DBGet.base_backups_path, @server, @db_type)
    end

    def prepare
      @backup_name = get_backup_name
      @encrypted_dump = get_encrypted_dump
    end

    def set_final_db
      @target_db = @custom_name || @backup_name
    end

    def form_db_name
      if !date.nil? and append_date
        self.target_db = "#{self.user}_#{self.target_db}_#{Utils.get_converted_date(self.date)}"
      else
        self.target_db = "#{self.user}_#{self.target_db}"
      end
    end

    def clean?
      @clean
    end

    def decrypt_dump
      unless @encrypted_dump.nil?
        if in_cache? cache_file
          file_path = cache_file
        elsif File.exists? @encrypted_dump
          file_path = Utils.decompress_file(decrypt_file(copy_to_cache(@encrypted_dump)))
        end

        file_path
      end
    end

    def in_cache?(file)
      File.exists? file
    end

    def cache_file
      file = File.join(DBGet.cache_path, decrypted_file_name)
      file.concat('.tar') if @db_type.eql? 'mongo'

      file
    end

    protected

    def latest?
      @date.nil?
    end

    def decrypted_file_name
      File.basename(@encrypted_dump.split('.').first)
    end

    def get_backup_name
      if !@db.nil? and !@db_type.nil?
        db = DBGet::Config.database(@db)

        if db.nil?
          raise "Database \'#{@db}\' not found in config!"
        end

        db[@db_type]
      end
    end

    def get_encrypted_dump
      monthly_dir_path = File.join(@storage_path, @backup_name)

      unless File.exist?(monthly_dir_path)
        raise "Database \'#{@backup_name}\' can't be found in #{@storage_path}!"
      end

      monthly_dirs = Utils.get_files(monthly_dir_path).sort

      if !monthly_dirs.empty?
        db_month = get_db_month(monthly_dirs)
        db_dumps_path = File.join(monthly_dir_path.to_s, db_month.to_s)
        db_dumps = Utils.get_files(db_dumps_path)

        @encrypted_dump = File.join(db_dumps_path, get_db_file(db_dumps))
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

  end
end
