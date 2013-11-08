require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'mongoid'

require_relative 'models/user'

Mongoid.load!("config/mongoid.yml")

class Calendar < Sinatra::Base

  get '/status' do
    [200, {}, 'OK']
  end

end
