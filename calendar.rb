require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'mongoid'

require_relative 'models/user'
require_relative 'models/event'

Mongoid.load!("config/mongoid.yml")

class Calendar < Sinatra::Base

  before do
    content_type 'application/json'
  end

  get '/status' do
    [200, {}, 'OK']
  end

  post '/user' do
    begin
      User.create!(email: params[:email], password: params[:password])
    rescue Mongoid::Errors::Validations
      error 400, {error: 'Validation failed'}.to_json
    end
  end

  post '/event' do
    begin
      Event.create!(
        name: params[:name],
        description: params[:description],
        category: params[:category],
        subcategory: params[:subcategory],
        start_time: params[:start_time],
        end_time: params[:end_time],
        city: params[:city],
        address: params[:address],
        country: params[:country],
        private: params[:private]
      )
    rescue Mongoid::Errors::Validations
      error 400, {error: 'Validation failed'}.to_json
    rescue InvalidDateOrder
      error 400, {error: 'Invalid Date Order: end_time is 
                          earlier than start_time'}.to_json
    end
  end
end
