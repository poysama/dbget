module DBGet
  module Binaries
    def self.get_binary(bin)
      `which #{bin}`.chomp
    end

    def self.mysql_cmd
      get_binary('mysql')
    end

    def self.mongorestore_cmd
      get_binary('mongorestore')
    end

    def self.find_cmd
      get_binary('find')
    end

    def self.tar_cmd
      get_binary('tar')
    end
  end
end
