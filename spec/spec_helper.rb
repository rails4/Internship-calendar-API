require 'simplecov'
SimpleCov.start

require_relative '../calendar'

require 'mongoid-rspec'
require 'rack/test'

Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

Mongoid.load!("config/mongoid.yml", 'test')

module CalendarApp
  include Rack::Test::Methods

  def app
    Calendar
  end

  def parsed_last_response
    @parsed_last_response ||= JSON.parse(last_response.body)
  end

  def parsed_date(date)
    DateTime.parse(date)
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
