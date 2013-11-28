require 'spec_helper'
require 'ssl'

describe 'Current_user' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:do_request) { get_current_user }
    
    context 'when token is missing' do
      subject! { get_current_user }

      it 'response should be in JSON' do
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it 'should return 403 HTTP code' do
        last_response.status.should == 403
      end

      it 'should return JSON formatted message "Forbidden"' do
        parsed_last_response["message"].should == 'Forbidden'
      end
    end
    
    context 'when token is present ' do
      context 'and is valid' do
        let(:user) { User.create(email: 'user@example.com', password: 'secret') }
        subject! do
          get_current_user(token: user.token)
        end
        
        it 'response should be in JSON' do
          last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
        end

        it 'should return 200 HTTP code' do
          last_response.status.should == 200
        end

        it 'should return user in JSON formatted message' do
          parsed_last_response['message']['email'].should == 'user@example.com'
          parsed_last_response['message']['token'].should == user.token
        end
      end

      context 'and is invalid' do
        subject! do
          get_current_user(token: 'invalid_token')
        end

        it 'response should be in JSON' do
          last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
        end

        it 'should return 403 HTTP code' do
          last_response.status.should == 403
        end
        
        it 'should return JSON formatted message "Forbidden"' do
          parsed_last_response["message"].should == 'Forbidden'
        end
      end
    end
  end

  private
  def get_current_user(params = {})
    get '/current_user/', params, base_env
  end
end
