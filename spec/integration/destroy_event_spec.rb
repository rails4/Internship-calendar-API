require 'spec_helper'
require 'ssl'
require 'json_response'

describe 'Delete event' do
  include CalendarApp
  let(:do_request) { delete_event }
  it_should_behave_like "HTTPS" do
    it_should_behave_like 'JSON response' do
      context "when user is event's owner" do
        let(:user) { User.create(email: 'user@example.com', password: 'aa') }
        let(:event) { create(:event, owner: user._id) }
        let!(:do_request) { delete_event(id: event._id, token: user.token) }
        subject do
          do_request
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
          let(:do_request) { delete_event }
          let!(:do_request) { delete_event(id: event._id, token: user.token) }
          subject do
            do_request
          end

          it "should return 403 HTTP code" do
            last_response.status.should == 403
          end

          it 'should return error formatted JSON message "Forbidden"' do
            parsed_last_response['message'].should == 'Forbidden'
          end

        end

        context 'when :id param is incorrect' do
          let(:user) { User.create(email: 'user@example.com', password: 'aa') }
          let(:event) { create(:event, owner: user._id) }
          
          let!(:do_request) { delete_event(id: "abc", token: user.token) }
          subject do
            do_request
          end

          it "should return 404 HTTP code" do
            last_response.status.should == 404
          end

          it "should return JSON formatted message {'error': 'Event not found!'}" do
            parsed_last_response["message"].should == "Event not found!"
          end
        end
      end
    end

    private
    def delete_event(params = {})
      delete "/event/#{params[:id]}", params, base_env
    end
  end
