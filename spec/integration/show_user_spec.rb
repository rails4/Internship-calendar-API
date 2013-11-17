require 'spec_helper'

describe 'User.show' do
  include CalendarApp

  context 'when request params are invalid' do
    before { get 'users/non-existent-id' }

    it 'should return data in JSON' do
      last_response.header['Content-type'].should == "application/json;charset=utf-8"
    end

    it 'should return HTTP 404' do
      last_response.status.should == 404
    end

    it 'should return error message' do
      parsed_last_response['message'].should == 'User not found'
    end
  end

  context 'when request params are valid' do
    let(:user) { User.create(email: 'example@example.com', password: 'foo') }
    before { get "/users/#{user.id}" }

    it 'should return HTTP 200 after a valid request' do
      last_response.status.should == 200
    end

    it 'should return data in JSON' do
      last_response.header['Content-type'].should == "application/json;charset=utf-8"
    end

    it 'should contain user e-mail address' do
      parsed_last_response['email'].should == user.email
    end
  end
end
