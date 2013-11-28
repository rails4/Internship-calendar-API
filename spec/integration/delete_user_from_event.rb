require 'spec_helper'
require 'ssl'

describe 'Delete user from event' do
  include CalendarApp
  let(:do_request) { delete_user_from_event }

  it_should_behave_like "HTTPS" do
    context "when user is signed in " do
      let(:user) { create(:user) }
      let(:event) { create(:event, owner: user.id) }
      subject! do
        event.users << user
        delete_user_from_event(base_params.merge(token: user.token, event_id: event.id, email: user.email))
      end

      it 'response should be in JSON' do
        subject
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it "should return 200 HTTP code" do
        subject
        last_response.status.should == 200
      end

      it "should return JSON formatted message {'message': 'User has been removed from event'}" do
        subject
        parsed_last_response["message"].should == "User has been removed from event"
      end

      it "should delete user from event from database" do
        expect {
          subject
          }.to change{ event.users.count }.by(0)
      end

      context 'for valid params' do
        let(:user2) { create(:user, email: "now@example.com") }
      
        it 'should return 200 HTTP code' do
          event.users << user2
          subject
          last_response.status.should == 200
        end

        it 'should add 2 users to event and remove one' do
          expect {
            event.users << user2  
            subject
          }.to change { event.reload.users.count }.by(1)
        end

        it 'id unremoved user should match with user2.id ' do 
            event.users << user2         
            event.reload.users.last.id.should == user2.id
        end
      end

      context 'for invalid params' do
        context 'User not exist in base nor in event' do
          subject! do
            delete_user_from_event(base_params.merge(token: user.token, event_id: event.id, email: nil))
          end

          it 'response should be in JSON' do
            subject
            last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
          end

          it "should return 404 HTTP code" do
            subject
            last_response.status.should == 404
          end

          it "should return JSON formatted message {'message': 'User in event not found!'}" do
            parsed_last_response["message"].should == "User in event not found!"
          end
        end

        context 'User exist in base but not in event' do
          let(:user2) { create(:user, email: "now@example.com") }
          subject! do
            delete_user_from_event(base_params.merge(token: user.token, event_id: event.id, email: user2.email))
          end

          it 'response should be in JSON' do
            subject
            last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
          end

          it "should return 404 HTTP code" do
            subject
            last_response.status.should == 404
          end

          it "should return JSON formatted message {'message': 'User in event not found!'}" do
            subject
            parsed_last_response["message"].should == "User in event not found!"
          end
        end
      end
    end
  end   

  private
  def delete_user_from_event(params = base_params)
    delete '/event/users/', params, base_env
  end

  def base_params
    {
      email: nil,
      event_id: nil,
      token: nil
    }
  end
end