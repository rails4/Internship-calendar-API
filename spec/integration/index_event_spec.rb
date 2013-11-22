require 'spec_helper'

describe 'Index event' do
  include CalendarApp
  subject! { get '/events' }

  it 'should return HTTP 200 code' do
    last_response.status == 200
  end

  it 'should return response in JSON' do
    last_response.header['Content-type'] == "application/json;charset=utf-8"
  end

  it 'should return a hash' do
    parsed_last_response.should be_a(Hash)
  end

  context 'when no event records exist' do
    it 'should return an empty array' do
      parsed_last_response["message"] == []
    end
  end

  context 'when in database are created events' do
    subject! do
      create_list(:event, 5, private: false)
      get '/events'
    end

    it 'should contain proper number of events' do
      parsed_last_response["message"].size.should == 5
    end
  end

  context 'when user token is valid' do
    before do
      event = create(:event)
      event.users << user
      get '/events', { token: user.token }
    end

    it 'should return 200 HTTP code' do
      last_response.status == 200
    end

    it 'should return all public events and user private events' do
      events = JSON.parse(Event.where(private: false).to_json)
      events += user.events.where(private: true)
      parsed_last_response["message"].should == events
    end
  end

  context 'when user token is invalid' do
    before do
      create(:event, private: false)
      get '/events', { token: 'invalid_token' }
    end

    it 'should return 200 HTTP code' do
      last_response.status == 200
    end

    it 'should return only public events' do
      events = JSON.parse(Event.where(private: false).to_json)
      parsed_last_response["message"].should == events
    end
  end
end
