require 'spec_helper'

describe 'Show users' do
  include CalendarApp

  it "should return 200 HTTP for /users" do
    get '/users'
    last_response.status.should == 200
  end

  it "should return an empty array if there are no users in database" do
    get '/users'
    last_response.body.should == [].to_json
  end

  it "should include the list of users" do
    create_user
    get '/users'
    last_response.body.should include('example@example.com')
  end

  def create_user(params=base_params)
    post '/user', params
  end

  def base_params
    {
      email: 'example@example.com',
      password: 'foo'
    }
  end
end
