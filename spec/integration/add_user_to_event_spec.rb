require 'spec_helper'
require 'ssl'

describe 'Add users to event' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:do_request) { add_user_to_event }
    
    context 'when user is not signed in should return status 403 and "Forbidden" JSON message when' do
      let(:user) { create(:user) }
      let(:event) { create(:event, owner: user.id) }
      it 'params are valid' do
        add_user_to_event(event_id: event.id, user_id: user.id)
        last_response.status.should == 403
        parsed_last_response["message"].should == "Forbidden"
      end

      it 'user param missing' do
        add_user_to_event(event_id: event.id)
        last_response.status.should == 403
        parsed_last_response["message"].should == "Forbidden"
      end

      it 'event param missing' do
        add_user_to_event(user_id: user.id)
        last_response.status.should == 403
        parsed_last_response["message"].should == "Forbidden"
      end
    end

    context 'when user is signed in' do
      context 'and params are invalid because of' do
        let(:user) { create(:user) }
        let(:event) { create(:event, owner: user.id) }
        it 'missing user and event params should return 400 HTTP code and "Invalid params" JSON message' do
          add_user_to_event(base_params.merge(token: user.token))
          last_response.status.should == 400
          parsed_last_response['message'].should == 'Invalid params'
        end

        it 'missing user param should return 400 HTTP code and "Invalid params" JSON message' do
          add_user_to_event(base_params.merge(token: user.token, event_id: event.id))
          last_response.status.should == 400
          parsed_last_response['message'].should == 'Invalid params'
        end

        it 'missing event param should return 400 HTTP code and "Invalid params" JSON message' do
          add_user_to_event(base_params.merge(token: user.token, user_id: user.id))
          last_response.status.should == 400
          parsed_last_response['message'].should == 'Invalid params'
        end

        it 'sended event is not found should return 404 HTTP code and "Not found" JSON message' do
          add_user_to_event(base_params.merge(token: user.token, user_id: user.id, event_id: '1243'))
          parsed_last_response['message'].should == 'Not found'
          last_response.status.should == 404
        end
      end

      context 'and params are valid' do
        let(:user_for_event) { create(:user) }
        let(:event) { create(:event, owner: user_for_event.id) }

        subject do
          add_user_to_event(base_params.merge(
            token: user_for_event.token, event_id: event.id, user_id: user.id ))
        end

        it 'should return 200 HTTP code' do
          subject
          last_response.status.should == 200
        end

        it 'should return JSON response with { message: "Successfully added!" }' do
            subject
            parsed_last_response['message'].should == 'Successfully added!'
        end

        it 'should add user to event' do
          expect {
            subject
            }.to change { event.reload.users.count }.by(1)
        end

        context 'and when event is private only event owner can add user to it' do
          let(:another_event) { create(:event, owner: '12345') }
            
          it 'and return code 403 HTTP and JSON "AccessDenied" when not event owner sent request' do
            add_user_to_event(base_params.merge(
            token: user_for_event.token, event_id: another_event.id, user_id: user.id )
            )
            last_response.status.should == 403
            parsed_last_response['message'].should == 'AccessDenied'
          end
        end

        context 'and when event is public everyone can add user to it' do
          let(:event){ create(:event, private: false, owner: 'fake_id')}
           
          it 'should return 200 HTTP code' do
            subject
            last_response.status.should == 200
          end

          it 'should add every user' do
            expect {
              subject
            }.to change { event.reload.users.count }.by(1)
          end

          it 'should return JSON response with { message: "Successfully added!" }' do
            subject
            parsed_last_response['message'].should == 'Successfully added!'
          end
        end

        context 'and when user has been already added to event' do
          let(:user_for_event) { create(:user) }
          let(:user2) { create(:user, email: "now@example.com") }
          let(:event) { create(:event, owner: user_for_event.id) }
        
          subject do
            event.users << user_for_event
            add_user_to_event(
              base_params.merge(
                token: user_for_event.token, event_id: event.id, user_id: user_for_event.id
              )
            )
          end

          it 'should return 403 HTTP code' do
            subject
            last_response.status.should == 403
          end

          it 'should return JSON with { message: "User already added" } ' do
            subject
            parsed_last_response['message'].should == 'User already added'
          end
        end

        context 'and when event has passed' do
          new_time = Time.local(2012, 5, 8, 12, 0, 0)
          let(:past_event) { create(:event,
                              owner: user_for_event.id,
                              start_time: DateTime.parse('2012-05-01'),
                              end_time: DateTime.parse('2012-05-06')
                            ) }

          subject do
            Timecop.travel(new_time)
            add_user_to_event(base_params.merge(
            token: user_for_event.token, event_id: past_event.id, user_id: user_for_event.id)
            )
          end

          it 'should return JSON response with { message: "Cannot add user to an event that has passed" }' do
            subject
            parsed_last_response['message'].should == 'Cannot add user to an event that has passed'
          end

          it 'should return 400 HTTP code' do
            subject
            last_response.status.should == 400
          end

          it 'should not add user to an event' do
            expect {
              subject
            }.not_to change { event.reload.users.count }.by(1)
          end
        end

        context "and when event hasn't passed" do
          new_time = Time.local(2012, 5, 3, 10, 1, 1)
          let(:user2) { create(:user, email: "some@example.com") }
          let(:present_event) { create(:event,
                              owner: user_for_event.id,
                              start_time: DateTime.parse('2012-05-01'),
                              end_time: DateTime.parse('2012-05-06')
                            ) }
          subject do
            Timecop.travel(new_time)
            add_user_to_event(base_params.merge(
            token: user_for_event.token, event_id: present_event.id, user_id: user2.id)
            )
          end

          it 'should return 200 HTTP code' do
            subject
            last_response.status.should == 200
          end

          it 'should return JSON response with { message: "Successfully added!" }' do
            subject
            parsed_last_response['message'].should == 'Successfully added!'
          end

          it 'should add user to an event' do
            expect {
              subject
            }.to change{ present_event.reload.users.count }.by(1)
          end
        end
      end
    end
  end

  private
  def add_user_to_event(params=base_params)
    post '/add_user_to_event', params, base_env
  end

  def base_params
    {
      event_id: nil,
      user_id: nil,
      token: nil
    }
  end
end