require 'spec_helper'

describe 'Update user' do
  include CalendarApp
  let(:user) { User.create(email: 'user@example.com', password: 'kle') }

  context 'for non-existen ID' do
    before do
      put 'users/-1'
    end

    it 'should return 404 HTTP code' do
      last_response.status.should == 404
    end

    it 'response should be in JSON' do
      last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
    end

    it 'should return message "User not found"' do
      parsed_last_response.should == { 'message' => 'User not found' }
    end
  end

  context 'when params are invalid' do
    context 'for invalid email' do
      before do
        params = { email: 'invalid.email' }
        put "users/#{user.id}", params
      end

      it 'should return 400 HTTP code' do
        last_response.status.should == 400
      end

      it 'response should be in JSON' do
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it 'should return message "Invalid params' do
        parsed_last_response.should == { 'message' => 'Invalid params' }
      end
    end

    context 'for invalid password' do
      before do
        params = { password: '' }
        put "users/#{user.id}", params
      end

      it 'should return 400 HTTP code' do
        last_response.status.should == 400
      end

      it 'response should be in JSON' do
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it 'should return message "Invalid params' do
        parsed_last_response.should == { 'message' => 'Invalid params' }
      end
    end
  end

  context 'when email address already exists' do
    before do
      User.create(email: 'another_user@example.com', password: 'asd')
      params = { email: 'another_user@example.com' }
      put "users/#{user.id}", params
    end

    it 'should return 409 HTTP code' do
      last_response.status.should == 409
    end

    it 'response should be in JSON' do
      last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
    end

    it 'should return message "Email is already taken' do
      parsed_last_response.should == { 'message' => 'Email is already taken' }
    end
  end

  context 'for successful update' do
    before do
      params = { email: 'user2@example.com', password: 'asd' }
      put "users/#{user.id}", params
    end

    it 'should return 200 HTTP code' do
      last_response.status.should == 200
    end

    it 'response should be in JSON' do
      last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
    end

    it 'should return message "User updated successfully"' do
      parsed_last_response.should == { 'message' => 'User updated successfully' }
    end
  end
end
