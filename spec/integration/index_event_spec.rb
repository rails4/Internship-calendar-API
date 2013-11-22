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
      create_list(:event, 5)
      get '/events'
    end

    it 'should contain proper number of events' do
      parsed_last_response["message"].size.should == 5
    end
  end
end