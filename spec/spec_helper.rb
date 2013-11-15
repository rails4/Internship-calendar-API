require 'simplecov'
SimpleCov.start

require_relative '../calendar'

require 'mongoid-rspec'
require 'rack/test'

module CalendarApp
  include Rack::Test::Methods

  def app
    Calendar
  end

  def parsed_last_response
    @parsed_last_response ||= JSON.parse(last_response.body)
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before(:each) do
    Mongoid.purge!
  end

  config.include Mongoid::Matchers

  config.order = 'random'
end
