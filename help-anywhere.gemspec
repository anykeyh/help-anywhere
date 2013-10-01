$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "help-anywhere/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "help-anywhere"
  s.version     = HelpAnywhere::VERSION
  s.authors     = ["Yacine Petitprez"]
  s.email       = ["yacine@kosmogo.com"]

  s.homepage    = "http://github.com/anykeyh/help-anywhere"
  s.summary     = "Provide help anywhere in your web applications."
  s.description = "Provide help anywhere in web applications."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
  
  s.license = 'THIS IS PROVIDED UNDER MIT LICENSE'  

  s.add_dependency "rails", "~> 3.2.13"

  s.add_development_dependency "sqlite3"
end
