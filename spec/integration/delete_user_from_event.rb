require 'spec_helper'
require 'ssl'

describe 'Delete user from event' do
  include CalendarApp
  let(:do_request) { delete_user_from_event }

  it_should_behave_like "HTTPS" do
    context 'when user is not event owner' do
      context 'for valid params' do
        let(:user_owner) { create(:user) }
        let(:user_test) {create(:user, email: 'test@example.com') }
        let(:event) { create(:event, owner: user_owner.id) }

        subject do
          event.users << user_test
          delete_user_from_event(base_params.merge(
            token: user_test.token, event_id: event.id, email: user_test.email))
        end

        it 'response should be in JSON' do
          subject
          last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
        end

        it "should return 200 HTTP code" do
          subject
          last_response.status.should == 200
        end

        it "should return JSON formatted message 'User has been removed from event'" do
          subject
          parsed_last_response["message"].should == "User has been removed from the event"
        end

        it "should remove user from event users list" do
          expect {
            subject
          }.to change{ event.users.count }.by(1)
        end
      end

      context 'for invalid params' do
        let(:user_owner) { create(:user) }
        let(:user_test) {create(:user, email: 'test@example.com') }
        let(:event) { create(:event, owner: user_owner.id) }

        subject do
          event.users << user_test
          delete_user_from_event(base_params.merge(
            token: user_test.token, event_id: event.id, email: 'invalid@example.com'))
        end

        it 'response should be in JSON' do
          subject
          last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
        end

        it "should return 403 HTTP code" do
          subject
          last_response.status.should == 403
        end

        it "should return JSON formatted message 'Forbidden'" do
          subject
          parsed_last_response["message"].should == "Forbidden"
        end
      end
    end

    context "when user is signed in " do
      let(:user) { create(:user) }
      let(:event) { create(:event, owner: user.id) }
      subject! do
        event.users << user
        delete_user_from_event(base_params.merge(token: user.token, event_id: event.id, email: user.email))
      end

      it 'response should be in JSON' do
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it "should return 200 HTTP code" do
        last_response.status.should == 200
      end

      it "should return JSON formatted message {'message': 'User has been removed from event'}" do
        parsed_last_response["message"].should == "User has been removed from the event"
      end

      it "should delete user from event from database" do
        expect {
          subject
        }.to change{ event.users.count }.by(0)
      end

      context 'for valid params' do
        let(:user) { create(:user) }
        let(:user2) { create(:user, email: "now@example.com") }
        let(:event) { create(:event, owner: user.id) }

        it 'should return 200 HTTP code' do
          event.users << user2
          subject
          last_response.status.should == 200
        end

        it 'should add user to event' do
          expect {
            event.users << user2
            subject
          }.to change { event.reload.users.count }.by(1)
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
