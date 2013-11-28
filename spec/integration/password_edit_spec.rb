require 'spec_helper'
require 'ssl'

describe 'Password edit' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:user) { create(:user,
      password_reset_token: '12345',
      password_reset_sent_at: 12.hours.ago
      ) }
    let(:do_request) { edit_password(user.password_reset_token) }

    subject { do_request }

    context 'for valid token' do
      it 'should return data in JSON' do
        subject
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it 'should return 200 HTTP code' do
        subject
        last_response.status.should == 200
      end

      it "should return JSON formatted message 'Password updated successfully'" do
        subject
        parsed_last_response["message"].should == 'Password updated successfully'
      end
    end

    context 'for expired token' do
      let(:user) { create(:user,
        password_reset_token: '12345',
        password_reset_sent_at: 48.hours.ago
        ) }
      let(:do_request) { edit_password(user.password_reset_token) }

      subject { do_request }

      it 'should return data in JSON' do
        subject
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it 'should return 403 HTTP code' do
        subject
        last_response.status.should == 403
      end

      it "should return JSON formatted message 'Token has expired'" do
        subject
        parsed_last_response["message"].should == 'Token has expired'
      end
    end

    context 'for non registered user' do
      let(:do_request) { edit_password('nonexistent-user@example.com') }

      subject { do_request }

      it 'should return data in JSON' do
        subject
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it 'should return 404 HTTP code' do
        subject
        last_response.status.should == 404
      end

      it "should return JSON formatted message 'User not found'" do
        subject
        parsed_last_response["message"].should == 'User not found'
      end
    end
  end

  private
  def edit_password(token)
    put '/password_reset', { password: 'qwerty',  token: token }, base_env
  end
end
