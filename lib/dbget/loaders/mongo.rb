module DBGet
  module Loaders
    class Mongo
      include Constants

      def self.boot(dump, config)
        self.new(dump, config)
      end

      def initialize(dump, config)
        @dump = dump
        @config = config
      end

      def load!
        temp_path = get_temp_path

        FileUtils.mkdir(temp_path) if !File.exists?(temp_path)

        @dump.db_name = Utils.form_db_name(@dump)
        extract_mongo_dump(temp_path)
        prepare_bson_files(temp_path)

        dump_files = Dir["#{temp_path}/*#{MONGO_FILE_EXT}"]
        dump_files = specify_collections(dump_files, temp_path)
        mongo_restore(dump_files)
        remove_temp_path(temp_path)

        Utils.say "Dump for #{@dump.db_name} done!"
      end

      def mongo_restore(dump_files)
        dump_files.each do |file|
          unless index?(file)
            Utils.say_with_time "Dumping #{file}..." do
              mongo_restore = Binaries.mongorestore_cmd

              system "#{mongo_restore} -d #{@dump.db_name} #{file} --drop"
            end
          end
        end
      end

      def get_temp_path
        random = Utils.randomize(16)
        decrypted_basename = File.basename(@dump.decrypted_dump, '.tar')
        temp_path = File.join(DBGet.cache_path, "#{decrypted_basename}_#{random}")
      end

      def remove_temp_path(path)
        if FileUtils.rm_rf(path)
          Utils.say "Temp directory removed!"
        end
      end

      def index?(file)
        File.basename(file) == "#{MONGO_INDEX_FILE}#{MONGO_FILE_EXT}"
      end

      def specify_collections(dump_files, temp_path)
        if !@dump.collections.empty?
          @dump.collections = @dump.collections.collect do |c|
            File.join(temp_path, c.concat(MONGO_FILE_EXT))
          end

          dump_files &= @dump.collections
        end

        dump_files
      end

      def extract_mongo_dump(temp_path)
        Utils.say_with_time "Extracting archive..." do
          `#{Binaries.tar_cmd} -C #{temp_path} -xf #{@dump.decrypted_dump} 2> /dev/null`
        end
      end

      def prepare_bson_files(temp_path)
        Utils.say_with_time "Moving mongo files..." do
          `#{Binaries.find_cmd} #{temp_path} -name '*#{MONGO_FILE_EXT}'`.each_line do |l|
            FileUtils.mv(l.chomp!, File.join(temp_path, File.basename(l)))
          end
        end
      end
    end
  end
end
