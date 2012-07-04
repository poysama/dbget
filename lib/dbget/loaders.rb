module DBGet
  module Loaders
    autoload :MySql, File.join(File.dirname(__FILE__), 'loaders/mysql')
    autoload :Mongo, File.join(File.dirname(__FILE__), 'loaders/mongo')
  end
end
