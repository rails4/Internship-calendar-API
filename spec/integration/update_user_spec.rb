require 'spec_helper'
require 'ssl'

describe 'Update user' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:do_request) { update_user(id: user.id) }
    let(:user) { create(:user) }

    context 'for non-existen ID' do
      before do
        update_user(id: 'assf')
      end

      it 'should return 403 HTTP code' do
        last_response.status.should == 403
      end

      it 'response should be in JSON' do
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it 'should return message "Forbidden"' do
        parsed_last_response.should == { 'message' => 'Forbidden' }
      end
    end

    context 'when params are invalid' do
      context 'for invalid email' do
        before do
          update_user(email: 'invalid.email', token: user.token, id: user.id)
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
          update_user(id: user.id, password: '', token: user.token)
        end

        it 'should return 400 HTTP code' do
          last_response.status.should == 400
        end

        it 'response should be in JSON' do
          last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
        end

        it 'should return message "Invalid params' do
          parsed_last_response['message'].should == 'Invalid params' 
        end
      end
    end

    context 'when email address already exists' do
      before do
        User.create(email: 'another_user@example.com', password: 'asd')
        update_user(email: 'another_user@example.com', token: user.token, id: user.id)
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
        update_user(email: 'user2@example.com', password: 'asd', token: user.token, id: user.id)
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

  private
  def update_user(params = {})
    put "users/#{params[:id]}", params, base_env
  end
end