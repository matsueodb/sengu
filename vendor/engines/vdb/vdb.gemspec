$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "vdb/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "vdb"
  s.version     = Vdb::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Vdb."
  s.description = "TODO: Description of Vdb."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.2"

  s.add_dependency "pg"
  s.add_dependency "rspec"
  s.add_dependency "rspec-rails"
  s.add_dependency "factory_girl_rails"
  s.add_dependency "database_cleaner"
  s.add_dependency "shoulda-matchers"
  s.add_dependency "devise"
  s.add_dependency "kaminari"
  s.add_dependency "rails_config"
  s.add_dependency "nokogiri"
  s.add_dependency "breadcrumbs_on_rails"
  s.add_dependency "rails_best_practices"
end
