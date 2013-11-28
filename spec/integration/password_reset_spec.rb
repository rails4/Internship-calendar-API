require 'spec_helper'
require 'ssl'

describe 'Password reset request' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:user) { User.create(email: 'example@example.com', password_digest: 'nnnnnn' ) }
    let(:do_request) { send_password_reset(user.email) }
    subject { do_request }

    context 'for registered user' do
      it 'should return data in JSON' do
        subject
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it 'should return 200 HTTP code' do
        subject
        last_response.status.should == 200
      end

      it "should return JSON formatted message 'Password reset email has been sent'" do
        subject
        parsed_last_response["message"].should == 'Password reset email has been sent'
      end

      it 'should generate password reset token' do
        subject
        user.reload.password_reset_token.should_not be_nil
      end

      it 'should generate password reset email sent date' do
        subject
        user.reload.password_reset_sent_at.should_not be_nil
      end

      it "should send password reset email" do
        Pony.should_receive(:mail).once.with(hash_including(to: user.email))
        subject
      end
    end

    context 'for non registered user' do
      let(:do_request) { send_password_reset('example@example.com') }
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

      it 'should not send password reset email' do
        Pony.should_not_receive(:mail)
        subject
      end
    end
  end

  private
  def send_password_reset(email)
    post '/password_reset', { email: email }, base_env
  end
end
