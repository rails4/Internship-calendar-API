require 'spec_helper'

describe 'Show event' do
  include CalendarApp
  
  context 'when event successfully showed' do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
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

    it "should return event in response" do
      parsed_last_response['message']["name"].should == "Bob's party"
    end
  end

  context "when checking user.token" do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    context "when user.token is valid" do
      subject do
        event.users << user
        show_event(id: event._id, token: user.token)
      end
      it "should return valid response" do
        subject
        last_response.status.should == 200
      end
    end

    context "when user.token is invalid" do
      subject do
        event.users << user
        show_event(id: event._id, token: "abc")
      end
      
      it "should return invalid response" do
        subject
        last_response.status.should == 403
      end

      it "should return message 'Forbidden'" do
        subject
        parsed_last_response["message"].should == "Forbidden"
      end
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
      parsed_last_response["message"].should == "Not found!"
    end
  end

  private
  def show_event(params = {})
    get "/event/#{params[:id]}", params
  end
end