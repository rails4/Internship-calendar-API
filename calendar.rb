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
    json_message('OK')
  end

  # User
  get '/users' do
    json_message(User.all)
  end

  get '/users/:id' do
    begin
      json_message(User.find(params[:id]))
    rescue Mongoid::Errors::DocumentNotFound
      json_error(404, 'User not found')
    end
  end

  post '/user' do
    begin
      User.create!(email: params[:email], password: params[:password])
      json_message('User created')
    rescue Mongoid::Errors::Validations
      json_error(400, 'Invalid params')
    end
  end

  put '/users/:id' do
    begin
      User.find(params[:id]).update_attributes!(email: params[:email], password: params[:password])
      json_message('User updated successfully')
    rescue Mongoid::Errors::DocumentNotFound
      json_error(404, 'User not found')
    rescue Mongoid::Errors::Validations => e
      if e.to_s.include?('Email is already taken')
        json_error(409, 'Email is already taken')
      end
      json_error(400, 'Invalid params')
    end
  end

  # Event
  get '/events' do
    json_message(Event.all)
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
      json_message('Event was successfully created')
    rescue Mongoid::Errors::Validations => e
      if e.to_s.include?("can't be blank")
        json_error(400, 'Validation failed: blank params')
      end
    rescue InvalidDateOrder
      json_error(400, 'Invalid date: end date is earlier than start date')
    end
  end

  delete '/event/:id' do
    begin
      Event.find(params[:id]).delete
      json_message('Event has been deleted')
    rescue Mongoid::Errors::DocumentNotFound
      json_error(404, "Event not found!")
    end
  end

  private
  def json_message(message)
    { message: message }.to_json
  end

  def json_error(code, message)
    error code, json_message(message)
  end
end
