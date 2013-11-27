require 'spec_helper'
require 'ssl'

describe 'Password reset request' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:user) { create(:user) }
    let(:do_request) { send_password_reset(user.email) }
    subject { do_request }

    it 'should return data in JSON' do
      subject
      last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
    end

    it 'should return 200 HTTP code' do
      subject
      last_response.status.should == 200
    end

    it 'should return JSON formatted message' do
      subject
      parsed_last_response["message"].should == 'Password reset email has been sent'
    end

    it 'should generate password reset token' do
      subject
      user.password_reset_token.should be_blank
    end

    it "should send reset email" do
      Pony.should_receive(:mail)
      subject
    end
  end

  private
  def send_password_reset(email)
    post '/password_reset', { email: email }, base_env
  end
end