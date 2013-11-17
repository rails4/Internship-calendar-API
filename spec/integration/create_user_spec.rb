require 'spec_helper'

describe 'Create user' do
  include CalendarApp

  it "should return 400 HTTP code for invalid params" do
    create_user(nil)
    last_response.status.should == 400
  end

  it "should return 400 HTTP code for invalid params" do
    create_user(base_params.merge(email: 'foo'))
    last_response.status.should == 400
  end

  it "should return 400 HTTP for not uniq email address" do
    User.create(email: 'foo@bar.pl', password: 'foo')
    create_user(base_params.merge(email: 'foo@bar.pl'))
    last_response.status == 400
  end

  it "should return 200 HTTP code for valid params" do
    create_user
    last_response.status.should == 200
  end

  it "should save user into database" do
    expect {
      create_user
    }.to change{ User.count }.by(1)
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
