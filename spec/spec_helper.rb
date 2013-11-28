require 'simplecov'
require 'timecop'
SimpleCov.start

require_relative '../calendar'

require 'mongoid-rspec'
require 'rack/test'
require 'factory_girl'
Dir[File.dirname(__FILE__)+"/factories/*.rb"].each {|file| require file }

Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

Mongoid.load!("config/mongoid.yml", 'test')

module Pony
  def self.mail(options={})
  end
end

module CalendarApp
  def self.included(base)
    base.instance_eval do
      include Rack::Test::Methods
    end
  end

  def app
    Calendar
  end

  def parsed_last_response
    @parsed_last_response ||= JSON.parse(last_response.body)
  end

  def parsed_date(date)
    DateTime.parse(date)
  end

  def user
    User.create(email: 'example@example.com', password: '12345')
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before(:each) do
    Mongoid.purge!
    Timecop.return
  end
  
  config.include Mongoid::Matchers
  config.order = 'random'
  config.include FactoryGirl::Syntax::Methods

end
