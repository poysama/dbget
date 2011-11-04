require 'yaml'

module DBGet

  autoload :DBDump, File.join(File.dirname(__FILE__), 'dbget/db_dump')
  autoload :Config, File.join(File.dirname(__FILE__), 'dbget/config')
  autoload :Utils, File.join(File.dirname(__FILE__), 'dbget/utils')

  def self.read_config
    DBGet::Config.load_from_yml(File.join(File.dirname(__FILE__), '../config/dbget.yml'))
  end

end
