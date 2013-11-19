require 'spec_helper'

describe 'Show event' do
  include CalendarApp
  
  context 'when event successfully showed' do
    let(:event) { create(:event)}
    let(:user) { create(:user)}
    subject! do
      event.users << user
      user.events << event
      show_event(id: event._id, token: user.token)
    end
    
    it 'response should be in JSON' do
      last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
    end
  
    it "should return 200 HTTP code" do
      last_response.status.should == 200
    end
  end
  
  context 'when :id param is incorrect' do
    subject! { show_event(id: "abc", token: user.token) }
    
    it 'response should be in JSON' do
      last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
    end
  
    it "should return 404 HTTP code" do
      last_response.status.should == 404
    end

    it "should return JSON formatted message {'error': 'Event not found!'}" do
      parsed_last_response["message"].should == "Expected event with given id is not found!"
    end
  end
  
  private
  def show_event(params = {})
    get "/event/#{params[:id]}", params
  end
end