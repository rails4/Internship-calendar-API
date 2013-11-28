require 'spec_helper'
require 'ssl'

describe 'Delete event' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:do_request) { delete_event }

    context "when user is event's owner" do
      let(:user) { User.create(email: 'user@example.com', password: 'aa') }
      let(:event) { create(:event, owner: user.id) }
      
      subject! do
        delete_event(id: event._id, token: user.token)
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

    context "when user isn't event's owner" do
      let(:event) { create(:event) }
      subject! do
        delete_event(id: event._id, token: user.token)
      end

      it 'response should be in JSON' do
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it "should return 403 HTTP code" do
        last_response.status.should == 403
      end

      it 'should return error formatted JSON message "Forbidden"' do
        parsed_last_response['message'].should == 'Forbidden'
      end

    end

    context 'when :id param is incorrect' do
      let(:event) { create(:event) }
      let(:user) { User.create(email: 'user@example.com', password: 'aa') }
      subject! do
        event.owner = user._id
        delete_event(id: "abc", token: user.token)
      end

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
  end

  private
  def delete_event(params = {})
    delete "/event/#{params[:id]}", params, base_env
  end
end