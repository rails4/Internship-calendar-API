require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'mongoid'

require_relative 'models/user'
require_relative 'models/event'

Mongoid.load!("config/mongoid.yml")

class Calendar < Sinatra::Base

  before { content_type :json }

  get '/status' do
    json_answer('OK')
  end

  # User
  get '/users' do
    User.all.to_json
  end

  post '/user' do
    begin
      User.create!(email: params[:email], password: params[:password])
      json_answer('User created')
    rescue Mongoid::Errors::Validations
      error 400, json_answer('Invalid params')
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
      { message: 'Event was successfully created' }.to_json
    rescue Mongoid::Errors::Validations => e
     if e.to_s.include?("can't be blank")
       error 400, json_answer('Validation failed: blank params')
     end
    rescue InvalidDateOrder
      error 400, json_answer('Invalid date: end date is earlier than start date')
    end
  end

  get '/users/:id' do
    begin
      User.find(params[:id]).to_json
    rescue
      Mongoid::Errors::DocumentNotFound
      error 404, json_answer('User not found')
    end
  end

  put '/users/:id' do
    begin
      User.find(params[:id]).update_attributes!(email: params[:email], password: params[:password])
      json_answer('User updated successfully')
    rescue Mongoid::Errors::DocumentNotFound
      error 404,  json_answer('User not found')
    rescue Mongoid::Errors::Validations => e
      if e.to_s.include?('Email is already taken')
        error 409, json_answer('Email is already taken')
      end
      error 400, json_answer('Invalid params')
    end
  end

  private
  def json_answer(message)
    { message: message }.to_json
  end
end
