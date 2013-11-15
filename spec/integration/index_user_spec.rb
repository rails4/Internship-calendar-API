require 'spec_helper'

describe 'Show users' do
  include CalendarApp

  it 'should return HTTP 200 after a valid request' do
    get '/users'
    last_response.status == 200
  end

  it 'should return data in JSON' do
    get '/users'
    last_response.header['Content-type'] == "application/json;charset=utf-8"
  end

  it 'should return an array' do
    get '/users'
    parsed_last_response.should be_an(Array)
  end

  context 'when no user records exist' do 
    it 'should return an empty array' do
      get '/users'
      parsed_last_response == []
    end
  end

  context 'when user records exist' do
    let!(:user) { User.create(email: 'example@example.com', password: 'foo') }
    let!(:another_user) {
      User.create(email: 'anotherexample@example.com', password: 'bar')
    }
    subject do
      get '/users'
      parsed_last_response
    end

    its(:size) { should eq(2) }

    it 'should have the right order' do
      subject[0]['email'].should eq(user.email)
      subject[1]['email'].should eq(another_user.email)
    end

    its 'first record should contain proper values' do
      subject[0]['email'].should eq(user.email)
    end
  end
end
