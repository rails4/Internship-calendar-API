require 'spec_helper'
require 'ssl'

describe 'Add users to event' do
  include CalendarApp
  let(:do_request) { add_user_to_event }

  it_should_behave_like "HTTPS" do
    context 'when user is not signed in' do

      subject { add_user_to_event }

      it "should return 403 HTTP code" do
        subject
        last_response.status.should == 403
      end

      it "should return error message" do
        subject
        parsed_last_response["message"].should == "Forbidden"
      end
    end

    context 'when user is signed in' do

      subject { add_user_to_event(base_params.merge(token: user.token)) }

      context 'for invalid params' do

        it 'should return 400 HTTP code' do
          subject
          last_response.status.should == 400
        end

        it 'should return JSON response with { message: "Invalid params" }' do
          subject
          parsed_last_response['message'].should == 'Invalid params'
        end
      end

      context 'for valid params' do
        let(:user_for_event) { create(:user) }
        let(:event) { create(:event, owner: user_for_event.id) }

        subject { add_user_to_event(base_params.merge(token: user_for_event.token, event_id: event.id, user_id: user_for_event.id )) }

        it 'should return 200 HTTP code' do
          subject
          last_response.status.should == 200
        end

        it 'should add user to event' do
          expect {
            subject
          }.to change { event.reload.users.count }.by(1)
        end

        context 'should allow only event owner to add users to event' do 
          it 'should return 200 HTTP code' do
            subject
            last_response.status.should == 200
          end
        end

        context 'should not allow only event owner to add users to event' do
          let(:event) { create(:event, owner: '12345') }
          
          it 'should return 403 HTTP code' do
            subject
            last_response.status.should == 403
          end

          it 'should return JSON response with { message: "AcessDenided" }' do
            subject
            parsed_last_response['message'].should == 'AccessDenied'
          end
        end
        context 'when event is public' do
          let(:event){ create(:event, private: false)}
           
          it 'should add user to public event' do
            expect {
              subject
            }.to change { event.reload.users.count }.by(1)
          end  

          it 'should return 200 HTTP code' do
            subject
            last_response.status.should == 200
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