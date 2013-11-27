require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'mongoid'

require_relative 'models/user'
require_relative 'models/event'
require_relative 'lib/secure_connection'

Mongoid.load!("config/mongoid.yml")

class PasswordInvalid < StandardError; end
class AccessDenied < StandardError; end

class Calendar < Sinatra::Base
  include SecureConnection

  before {
    content_type :json
    ensure_ssl! unless Sinatra::Base.development?
    unless (['/status', '/login', '/events', '/event', '/user'].any? {|path| request.path_info =~ /#{path}/ })
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
      raise AccessDenied if params[:id] != user_id(@current_user)
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
    begin
      user = User.find_by(token: params[:token]) if params[:token]
    rescue Mongoid::Errors::DocumentNotFound
      user = nil
    end

    events = Event.where(private: false)
    events = events.where(name: Regexp.new(params[:search])) if params[:search]

    if user
      user_events = user.events.where(private: true)
      user_events = user_events.where(name: Regexp.new(params[:search])) if
        params[:search]
      events += user_events
    end

    json_message(events)
  end

  post '/event' do
    begin
      @current_user = User.find_by(token: params[:token])
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
        owner: @current_user._id,
        private: params[:private]
      )
      json_message('Event was successfully created')
    rescue Mongoid::Errors::Validations => e
      if e.to_s.include?("can't be blank")
        json_error(400, 'Validation failed: blank params')
      end
    rescue InvalidDateOrder
      json_error(400, 'Invalid date: end date is earlier than start date')
    rescue
      json_error(403, 'Forbidden')
    end
  end

  get '/event/:id' do
    begin
      user = User.find_by(token: params[:token]) if params[:token]
      event = Event.find(params[:id])
      if !event.private || (event.private 
        && event.users.include?(user))
        json_message(event)
      else
        json_error(403, "Forbidden")
      end
    rescue Mongoid::Errors::DocumentNotFound
      json_error(404, "Not found!")
    end
  end

  delete '/event/:id' do
    begin
      @current_user = User.find_by(token: params[:token])
      event = Event.find(params[:id])
      if event.owner == @current_user._id
        event.delete
        json_message('Event has been deleted')
      else
        raise AccessDenied
      end
    rescue Mongoid::Errors::DocumentNotFound
      json_error(404, "Event not found!")
    rescue AccessDenied
      json_error(403, 'Forbidden')
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

  def user_id(user)
    user._id.to_s
  end
end
