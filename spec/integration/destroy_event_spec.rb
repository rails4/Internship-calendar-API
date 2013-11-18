require 'spec_helper'

describe 'Delete event' do
  include CalendarApp
  
  context 'when event successfully deleted' do
    let(:event) { create(:event) }
    subject! do
      delete_event(event._id)
    end
    
    it 'response should be in JSON' do
      last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
    end
  
    it "should return 200 HTTP code" do
      last_response.status.should == 200
    end

    it "should return JSON formatted message {'message': 'Event has been deleted'}" do
      parsed_last_response["message"].should == "Event has been deleted"
    end

    it "should delete event from database" do
      expect {
        subject
      }.to change{ Event.count }.by(0)
    end
  end
  
  context 'when :id param is incorrect' do
    subject! { delete_event("abc") }
    
    it 'response should be in JSON' do
      last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
    end
  
    it "should return 404 HTTP code" do
      last_response.status.should == 404
    end

    it "should return JSON formatted message {'error': 'Event not found!'}" do
      parsed_last_response["message"].should == "Event not found!"
    end
  end
  
  private
  def delete_event(id = nil)
    delete "/event/#{id}"
  end
end