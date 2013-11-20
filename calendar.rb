require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'mongoid'

require_relative 'models/user'
require_relative 'models/event'

Mongoid.load!("config/mongoid.yml")

class PasswordInvalid < StandardError; end
class AccessDenied < StandardError; end

class Calendar < Sinatra::Base

  before {
    content_type :json
    unless ['/status', '/login', '/events', '/user'].include?(request.path_info)
      require_param(params[:token])
      begin
        @current_user = User.find_by(token: params[:token])
      rescue
        json_error(403, 'Forbidden')
      end
    end
  }

  get '/status' do
    json_message('OK')
  end

  # User
  get '/users/:id' do
    begin
      raise AccessDenied if params[:id] != @current_user.id.to_s
      json_message(@current_user)
    rescue AccessDenied
      json_error(403, 'Forbidden')
    end
  end

  get '/current_user/' do
    json_message(@current_user)
  end

  get '/login' do
    begin
      user = User.find_by(email: params[:email])
      if user = user.authenticate(params[:password])
        json_message({token: user.token})
      else
        raise PasswordInvalid
      end
    rescue PasswordInvalid
      json_error(403, 'Forbidden')
    rescue Mongoid::Errors::DocumentNotFound
      json_error(404, 'User not found')
    end
  end

  post '/user' do
    begin
      User.create!(email: params[:email], password: params[:password])
      json_message('User created successfully')
    rescue Mongoid::Errors::Validations => e
      if e.to_s.include?('Email is already taken')
        json_error(409, 'Email is already taken')
      end
      json_error(400, 'Invalid params')
    end
  end

  delete '/users' do
      @current_user.delete
      json_message('The user has been removed!')
  end

  put '/users/:id' do
    begin
      @current_user.update_attributes!(email: params[:email], password: params[:password])
      json_message('User updated successfully')
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

  def require_param(param)
    json_error(403, 'Forbidden') unless param.present?
  end
end
