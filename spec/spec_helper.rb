# use local 'lib' dir in include path
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'pry-byebug'
require 'webmock/rspec'

require 'lexisnexis'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].sort.each { |file| require file }

def example_config
  LexisNexis::Proofer::Config.new(
    base_url: 'https://example.com',
    request_mode: 'testing',
    account_id: 'test_account',
    username: 'test_username',
    password: 'test_password',
    instant_verify_workflow: 'customers.gsa.instant.verify.workflow',
    phone_finder_workflow: 'customers.gsa.phonefinder.workflow',
  )
end

RSpec.configure do |config|
  config.color = true
  config.example_status_persistence_file_path = './tmp/rspec-examples.txt'
end
