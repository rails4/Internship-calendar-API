require 'spec_helper'
require 'ssl'

describe 'Show event' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:do_request) { show_event }
    
    context "when token is valid" do
      context 'for correct params' do
        subject! do
          event = create(:event)
          user = create(:user)
          event.users << user
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

      context 'for incorrect params' do
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
    end

    context 'when token is invalid' do
      subject do
        event = create(:event)
        user = create(:user)
        event.users << user
        show_event(id: event._id, token: "invalid token")
      end

      it "should return invalid response" do
        subject
        last_response.status.should == 404
      end

      it "should return message 'Not found!'" do
        subject
        parsed_last_response["message"].should == "Not found!"
      end
    end

    context "when event is public" do
      context 'for correct params' do
        subject do
          event = create(:event, private: false)
          show_event(id: event._id)
        end

        it 'response should be in JSON' do
          subject
          last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
        end

        it "should return 200 HTTP code" do
          subject
          last_response.status.should == 200
        end

        it "should return event in response" do
          subject
          parsed_last_response['message']["name"].should == "Bob's party"
        end
      end

      context 'for incorrect params' do
        subject do
          event = create(:event, private: false)
          show_event(id: "abc")
        end

        it 'response should be in JSON' do
          subject
          last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
        end

        it "should return 404 HTTP code" do
          subject
          last_response.status.should == 404
        end

        it "should return JSON formatted message {'error': 'Not found!'}" do
          subject
          parsed_last_response["message"].should == "Not found!"
        end
      end
    end
  end

  private
  def show_event(params = {})
    get "/event/#{params[:id]}", params, base_env
  end
end