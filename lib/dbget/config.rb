require 'singleton'

module DBGet
  class Config < Hash
    include Singleton

    def self.load_from_yml(yaml_path)
      config = self.instance
      config.clear
      config.merge!(YAML.load_file(yaml_path))
    end

    def self.database(name)
      self.instance['databases'][name]
    end
  end
end
