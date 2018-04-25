ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'vcr'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb
end

# Make minitest output look better
require 'minitest/reporters'
MiniTest::Reporters.use! [
  MiniTest::Reporters::DefaultReporter.new(color: true, slow_count: 5),
  MiniTest::Reporters::JUnitReporter.new
]
