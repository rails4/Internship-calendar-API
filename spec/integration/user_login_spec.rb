require 'spec_helper'

describe 'User login' do
  include CalendarApp
  subject { get 'login', params }
  let!(:user) { User.create(email: 'user@example.com', password: '12345') }
  let(:message) { JSON.parse(subject.body) }

  context 'response for non-existent email' do
    let(:params) { { email: 'no-email' } }

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
