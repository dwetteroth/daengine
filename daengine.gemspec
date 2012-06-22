$:.push File.expand_path("../lib", __FILE__)
# require File.expand_path("../lib/daengine/version", __FILE__)

# Maintain your gem's version:
require "daengine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "daengine"
  s.version     = Daengine::VERSION
  s.authors     = ["sbhatia"]
  s.email       = ["samcojava@yahoo.com"]
  s.homepage    = "http://www.globalizeyourthinking.com"
  s.summary     = "Daengine GEM."
  s.description = "Daengine handles digital asset processing."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md", "Gemfile"]
  s.test_files = Dir.glob("spec/**/*")

  s.executables << 'process_assets'

  s.add_dependency "rails", "~> 3.2.3"
  s.add_dependency 'mongoid'
  s.add_development_dependency 'factory_girl'

  s.add_development_dependency 'rspec-rails'

end
