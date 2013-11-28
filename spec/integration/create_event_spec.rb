require 'spec_helper'
require 'ssl'

describe 'Create event' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:do_request) { create_event }

    context 'when there is no params' do
      subject! do
        create_event({token: user.token})
        last_response
      end

      it "should return 400 HTTP code" do
        subject.status.should == 400
      end

      it "response should be in JSON" do
        subject.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it "should return message" do
        parsed_last_response["message"].should == "Validation failed: blank params"
      end
    end

    context "when create event failed" do
      context "for end_time less than start_time" do
        subject! {
          create_event(
            base_params.merge(
              start_time: parsed_date("13/11/2013 10:01"),
              end_time: parsed_date("13/11/2013 10:00"))
          )
          last_response
        }

        it "should return 400 HTTP code" do
          subject.status.should == 400
        end

        it "should return message" do
          parsed_last_response["message"].should == "Invalid date: end date is earlier than start date"
        end

        it "response should be in JSON" do
          subject.header['Content-Type'].should == 'application/json;charset=utf-8'
        end
      end

      context 'for start date is nil' do
        subject! {
          create_event(
            base_params.merge(
              start_time: nil,
              end_time: parsed_date("13/11/2013 10:00"))
          )
          last_response
        }
        it "should return 400 HTTP code" do
          subject.status.should == 400
        end

        it "should return message" do
          parsed_last_response["message"].should == "Validation failed: blank params"
        end
      end
    end

    context 'when event was successfully created' do
      subject {
        create_event
        last_response
      }

      it "should return 200 HTTP code" do
        subject.status.should == 200
      end

      it "response should be in JSON" do
        subject.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it "should save event into database" do
        expect {
          subject
        }.to change { Event.count }.by(1)
      end

      it "should return message" do
        subject
        parsed_last_response["message"].should == "Event was successfully created"
      end
    end

    context "Event can belongs to users" do
      let(:event) { Event.create!(base_params) }

      it "shoudl allow for adding user to event" do
        user = create_user
        event.users << user
        event.reload.users.first.should == user
      end

      it "should allow for accessing event through user" do
        user = create_user
        event.users << user
        user.reload.events.first.should == event
      end
    end
  end

  private
  def create_event(params=base_params)
    post '/event', params, base_env
  end

  def create_user
    User.create!(email: "user@example.com", password: "asd")
  end

  def base_params
    {
      name: "Party Rock!",
      description: "Awesome Party With Chicks ;D",
      category: "party",
      subcategory: "alcohol",
      start_time: parsed_date("20/11/2013 22:00"),
      end_time: parsed_date("21/11/2013 9:00"),
      city: "New York",
      address: "35th, Ave",
      country: "America",
      private: false,
      owner: 'fake_id',
      token: user.token
    }
  end
end