require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'mongoid'

require_relative 'models/user'
require_relative 'models/event'

Mongoid.load!("config/mongoid.yml")

class Calendar < Sinatra::Base

  get '/status' do
    [200, {}, 'OK']
  end

  post '/user' do
    begin
      User.create!(email: params[:email], password: params[:password])
    rescue Mongoid::Errors::Validations
      [400, {}, nil]
    end
  end
end
