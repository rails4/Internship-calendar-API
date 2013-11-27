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
    let(:user) { create(:user) }

    before do
      event = create(:event)
      event.users << user
      get '/events', { token: user.token }
    end

    it 'should return 200 HTTP code' do
      last_response.status == 200
    end

    it 'should return all public events and user private events' do
      events = Event.where(private: false).map(&:id).map(&:to_s).sort
      events += user.events.where(private: true).map(&:id).map(&:to_s).sort

      parsed_last_response["message"].map{ |event| event["_id"] }.sort.should == events
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

  context 'when search params is exist in db' do
    let(:event) { create(:event, private: false) }

    before do
      get '/events', { search: event.name }
    end

    it 'should return 200 HTTP code' do
      last_response.status == 200
    end

    it 'should return match events' do
     events = JSON.parse(Event.where(name: event.name).to_json)
     parsed_last_response["message"].should == events
    end
  end

  context 'when search params is not exist in db' do
    before do
      create(:event, private: false)
      get '/events', { search: 'abc' }
    end

    it 'should return 200 HTTP code' do
      last_response.status == 200
    end

    it 'should return blank array' do
      parsed_last_response["message"].should == []
    end
  end

  context 'when search params blank' do
    before do
      create(:event, private: false)
      get '/events', { search: '' }
    end

    it 'should return 200 HTTP code' do
      last_response.status == 200
    end

    it 'should return all events from db' do
      events = JSON.parse(Event.all.to_json)
      parsed_last_response["message"].should == events
    end
  end

  context 'when user token is valid and search params exist in db' do
    let(:user) { create(:user) }
    let(:private_event) { create(:event, name: "Bob's private Party") }

    before do
      private_event.users << user
      create_list(:event, 3, private: false)
      get '/events', { token: user.token, search: "Bob's party" }
    end

    it 'should return 200 HTTP code' do
      last_response.status == 200
    end

    it 'should return only public events' do
      events = JSON.parse(Event.where(private: false).to_json)
      parsed_last_response["message"].should == events
    end
  end

  context 'when user token is valid and search params exist in db' do
    let(:user) { create(:user) }
    let(:private_event) { create(:event, name: "Bob's private Party") }
    let(:private_event_2) { create(:event) }

    before do
      private_event.users << user
      private_event_2.users << user
      create_list(:event, 3, private: false)
      get '/events', { token: user.token, search: "Bob's party" }
    end

    it 'should return 200 HTTP code' do
      last_response.status == 200
    end

    it 'should return match events' do
      events = Event.where(name: "Bob's party").map(&:id).map(&:to_s).sort
      parsed_last_response["message"].map{ |event| event["_id"] }.sort.should == events
    end
  end
end
