require 'spec_helper'

describe 'User.show' do
  include CalendarApp

  context 'when user is not logged in' do
    before { get 'users/non-existent-id' }

    it 'should return HTTP 403' do
      last_response.status.should == 403
    end

    it 'should return error message' do
      parsed_last_response['message'].should == 'Forbidden'
    end
  end

  context 'when user is logged in' do
    context 'for valid request params' do
      let(:user) { User.create(email: 'example@example.com', password: 'foo') }
      before { get "/users/#{user.id}", token: user.token }

      it 'should return HTTP 200' do
        last_response.status.should == 200
      end

      it 'should return data in JSON' do
        last_response.header['Content-type'].should == "application/json;charset=utf-8"
      end

      it 'should contain user e-mail address' do
        parsed_last_response['message']['email'].should == user.email
      end
    end
  end
end
