# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'dbget/version'

Gem::Specification.new do |s|
  s.name        = "dbget"
  s.version     = DBGet::VERSION
  s.authors     = ["Jan Mendoza"]
  s.email       = ["poymode@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Get an encrypted and compressed backup of a MySQL or mongoDB}
  s.description = %q{This serves the backup}

  s.rubyforge_project = "dbget"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'thor'

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
