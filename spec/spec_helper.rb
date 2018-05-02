# use local 'lib' dir in include path
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'pry-byebug'
require 'dotenv'

Dotenv.load('.env.test')

require 'proofer'
require 'lexisnexis'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].sort.each { |file| require file }

RSpec.configure do |config|
  config.color = true
  config.example_status_persistence_file_path = './tmp/rspec-examples.txt'
end
