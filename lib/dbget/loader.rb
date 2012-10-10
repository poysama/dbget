module DBGet
  module Loader
    autoload :MySql, File.join(DBGET_LIB_ROOT, 'loader/mysql')
    autoload :Mongo, File.join(DBGET_LIB_ROOT, 'loader/mongo')
  end
end
