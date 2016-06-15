# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lexisnexis/version"

Gem::Specification.new do |s|
  s.name = %q{lexisnexis}
  s.version = LexisNexis::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Peter Karman <peter.karman@gsa.gov>"]
  s.email = %q{peter.karman@gsa.gov}
  s.homepage = %q{http://github.com/18F/identity-lexisnexis-api-client-gem}
  s.summary = %q{LexisNexis API client}
  s.description = %q{LexisNexis API client for Ruby}
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.files = Dir.glob("app/**/*") + Dir.glob("lib/**/*") + [
     "LICENSE",
     "README.md",
     "Gemfile",
     "lexisnexis-api-client.gemspec"
  ]
  s.license = "LICENSE"
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency('dotenv')
  s.add_dependency('hashie')
  s.add_dependency('savon')
  s.add_dependency('logger')

  s.add_development_dependency('rspec')
end
