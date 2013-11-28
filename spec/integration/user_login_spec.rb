require 'spec_helper'
require 'ssl'

describe 'User login' do
  include CalendarApp
  
  it_should_behave_like "HTTPS" do
    let(:params) { { email: 'no-email' } }
    let(:do_request) { user_login(params) }
    
    subject { do_request }
    let!(:user) { User.create(email: 'user@example.com', password: '12345') }
    let(:message) { JSON.parse(subject.body) }

    context 'response for non-existent email' do
      its(:status) { should eq(404) }
      its(["Content-Type"]) { should eq('application/json;charset=utf-8') }

      it 'should return "User not found" message' do 
        message.should == { 'message' => 'User not found' }
      end
    end

    context 'for invalid password' do
      let(:params) { { email: 'user@example.com', password: 'abcde' } }

      its(:status) { should eq(403) }
      its(["Content-Type"]) { should eq('application/json;charset=utf-8') }

      it 'should return "Forbidden" message' do
        message.should == { 'message' => 'Forbidden' }
      end
    end

    context 'for successful login' do
      let(:params) { { email: 'user@example.com', password: '12345' } }

      its(:status) { should eq(200) }
      its(["Content-Type"]) { should eq('application/json;charset=utf-8') }

      it 'should return user token' do
        message.should == { 'message' => { 'token' => user.token } }
      end
    end
  end

  private
  def user_login(params = {})
    get 'login', params, base_env
  end
end
