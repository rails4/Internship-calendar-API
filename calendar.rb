require 'rubygems'
require 'bundler/setup'

class Calendar < Sinatra::Base

  get '/status' do
    [200, {}, 'OK']
  end

end
