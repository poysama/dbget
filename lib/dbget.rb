require 'yaml'

module DBGet
  DBGET_LIB_ROOT = File.join(File.dirname(__FILE__), 'dbget')
  autoload :Admin, File.join(DBGET_LIB_ROOT, 'admin')
  autoload :Binaries, File.join(DBGET_LIB_ROOT, 'binaries')
  autoload :Config, File.join(DBGET_LIB_ROOT, 'config')
  autoload :Constants, File.join(DBGET_LIB_ROOT, 'constants')
  autoload :Dump, File.join(DBGET_LIB_ROOT, 'dump')
  autoload :Controller, File.join(DBGET_LIB_ROOT, 'controller')
  autoload :Loader, File.join(DBGET_LIB_ROOT, 'loader')
  autoload :Runner, File.join(DBGET_LIB_ROOT, 'runner')
  autoload :Utils, File.join(DBGET_LIB_ROOT, 'utils')

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
