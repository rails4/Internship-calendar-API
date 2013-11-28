require 'spec_helper'
require 'ssl'

describe 'User.show' do
  include CalendarApp
  
  it_should_behave_like "HTTPS" do
    let(:do_request) { show_user(token: user.token, id: user.id) }
    
    context 'when user is not logged in' do
      before { show_user(id: user.id) }

      it 'should return HTTP 403' do
        last_response.status.should == 403
      end

      it 'should return error message' do
        parsed_last_response['message'].should == 'Forbidden'
      end
    end

    context 'when user is logged in' do
      context 'for valid request params' do
        let(:user) { create(:user, email: 'sa@example.com', password: 'aa') }

        before { show_user(token: user.token, id: user.id) }

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

  private
  def show_user(params = {})
    get "/users/#{params[:id]}", params, base_env
  end
end