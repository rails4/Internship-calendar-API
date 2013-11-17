require 'spec_helper'

describe 'Create event' do
  include CalendarApp

  context 'when there is no params' do
    before do
      create_event(nil)
    end

    subject { last_response }

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
      before do
        create_event(base_params.merge(
                    start_time: parsed_date("13/11/2013 10:01"),
                    end_time: parsed_date("13/11/2013 10:00"))
                    )
      end

      subject { last_response }

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
      before do
        create_event(base_params.merge(
                    start_time: nil,
                    end_time: parsed_date("13/11/2013 10:00"))
                    )
      end

      subject { last_response }

      it "should return 400 HTTP code" do
        subject.status.should == 400
      end

      it "should return message" do
        parsed_last_response["message"].should == "Validation failed: blank params"
      end
    end
  end

  context 'when event was successfully created' do
    before do
      create_event
    end

    subject { last_response }

    it "should return 200 HTTP code" do
      subject.status.should == 200
    end

    it "response should be in JSON" do
      subject.header['Content-Type'].should == 'application/json;charset=utf-8'
    end

    it "should save event into database" do
      expect {
        create_event
      }.to change { Event.count }.by(1)
    end

    it "should return message" do
      parsed_last_response["message"].should == "Event was successfully created"
    end
  end

  def create_event(params=base_params)
    post '/event', params
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
      private: false
    }
  end
end
