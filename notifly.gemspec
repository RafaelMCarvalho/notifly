$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "notifly/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "notifly"
  s.version     = Notifly::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Notifly."
  s.description = "TODO: Description of Notifly."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.6"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails", '~> 3.1.0'
end