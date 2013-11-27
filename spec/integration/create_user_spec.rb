require 'spec_helper'
require 'ssl'

describe 'Create user' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:do_request) { create_user }

  context 'when request params are invalid' do
    before { post '/user', nil }

    it 'should return data in JSON' do
      last_response.header['Content-type'].should == "application/json;charset=utf-8"
    end

    it 'should return 400 HTTP code' do
      last_response.status.should == 400
    end

    it 'should return error message' do
      parsed_last_response['message'].should == 'Invalid params'
    end

    context 'when email address is not unique' do
      before do
        User.create(email: 'user@example.com', password: 'foo')
        post '/user', { email: 'user@example.com', password: 'bar' }
      end

      it 'should return 409 HTTP code' do
        last_response.status == 409
      end

      it 'should return error message' do
        parsed_last_response['message'].should == 'Email is already taken'
      end
    end
  end

  context 'when request params are valid' do
    subject do
      post '/user', { email: 'user@example.com', password: 'bar' }, base_env
      last_response
    end

    it 'should return data in JSON' do
      subject.header['Content-type'].should == "application/json;charset=utf-8"
    end

    it 'should return 200 HTTP code for valid params' do
      subject.status.should == 200
    end

    it 'should return message' do
      subject
      parsed_last_response['message'].should == 'User created successfully'
    end

    it 'should save user into database' do
      expect { subject }.to change{ User.count }.by(1)
    end
  end
end
end
