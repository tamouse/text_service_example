ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "vcr"

VCR.configure do |c|
  c.default_cassette_options = {
    record: :new_episodes,
    erb: true
  }
  c.cassette_library_dir = Rails.root.join('test/support/vcr/cassettes')
  c.hook_into :faraday
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

