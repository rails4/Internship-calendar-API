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

  put '/users/:id' do
    content_type :json
    begin
      User.find(params[:id]).update_attributes!(email: params[:email], password: params[:password])
      { message: 'User updated successfully' }.to_json
    rescue Mongoid::Errors::DocumentNotFound
      error 404, { message: 'User not found' }.to_json
    rescue Mongoid::Errors::Validations => e
      if e.to_s.include?('Email is already taken')
        error 409, { message: 'Email is already taken' }.to_json
      end
      error 400, { message: 'Invalid params' }.to_json
    end
  end
end
