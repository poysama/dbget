require 'yaml'

module DBGet
  autoload :Admin, File.join(File.dirname(__FILE__), 'dbget/admin')
  autoload :Binaries, File.join(File.dirname(__FILE__), 'dbget/binaries')
  autoload :Config, File.join(File.dirname(__FILE__), 'dbget/config')
  autoload :Constants, File.join(File.dirname(__FILE__), 'dbget/constants')
  autoload :Dump, File.join(File.dirname(__FILE__), 'dbget/dump')
  autoload :Controller, File.join(File.dirname(__FILE__), 'dbget/controller')
  autoload :Loaders, File.join(File.dirname(__FILE__), 'dbget/loaders')
  autoload :Runner, File.join(File.dirname(__FILE__), 'dbget/runner')
  autoload :Utils, File.join(File.dirname(__FILE__), 'dbget/utils')

  def self.read_config(dbget_path)
    config_file = File.join(dbget_path, Constants::CONFIG_PATH)
    DBGet::Config.load_from_yml(config_file)
  end

  def self.base_backups_path
    DBGet::Config.instance['backups']['path']
  end

  def self.cache_path
    DBGet::Config.instance['backups']['cache']
  end
end
