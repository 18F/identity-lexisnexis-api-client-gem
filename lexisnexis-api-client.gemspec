$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'lexisnexis/version'

Gem::Specification.new do |s|
  s.name = 'lexisnexis'
  s.version = LexisNexis::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = [
    'Jonathan Hooper <jonathan.hooper@gsa.gov>',
  ]
  s.email = 'hello@login.gov'
  s.homepage = 'https://github.com/18F/identity-lexisnexis-api-client-gem'
  s.summary = 'LexisNexis API client'
  s.description = 'LexisNexis API client for Ruby'
  s.date = Time.now.utc.strftime('%Y-%m-%d')
  s.files = Dir.glob('app/**/*') + Dir.glob('lib/**/*') + [
    'LICENSE.md',
    'README.md',
    'Gemfile',
    'lexisnexis-api-client.gemspec',
  ]
  s.license = 'LICENSE'
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.rdoc_options = ['--charset=UTF-8']

  s.add_dependency('faraday')
  s.add_dependency('activesupport')
  s.add_dependency('proofer') # git dependency
  s.add_dependency('redacted_struct', '>= 1.0.0')

  s.add_development_dependency('pry-byebug')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop', '~> 0.81.0')
  s.add_development_dependency('webmock')
end
