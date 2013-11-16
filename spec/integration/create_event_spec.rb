require 'spec_helper'

describe 'Create event' do
  include CalendarApp

  context 'when try create event with nil params' do
    before do
      create_event(nil)
    end

    subject { last_response }

    it "should return 400 HTTP" do
      subject.status.should == 400
    end 
    
    it "should return json" do
      subject.header['Content-Type'].should == 'application/json;charset=utf-8'
    end 
  end

  context 'when event not successfully created' do
    before do
      create_event(base_params.merge(
                  start_time: parsed_date("13/11/2013 10:01"),
                  end_time: parsed_date("13/11/2013 10:00"))
                  )
    end

    subject { last_response }

    it "should return 400 HTTP code for end_time less than start_time" do
      subject.status.should == 400
    end

    it "should return error 'Invalid Date Order' for invalid order date" do
      parsed_last_response["error"].should == "Invalid Date: end date is earlier than start date"
    end

    it "should return json" do
      subject.header['Content-Type'].should == 'application/json;charset=utf-8'
    end
  end

  context 'when event not successfully created' do
    before do
      create_event(base_params.merge(
                  start_time: nil,
                  end_time: parsed_date("13/11/2013 10:00"))
                  )
    end

    subject { last_response }

    it "should return 400 HTTP code for one nil date" do
      subject.status.should == 400
    end

    it "should return error 'Validation failed' for nil one of date" do
      parsed_last_response["error"].should == "Validation failed"
    end
  end

  context 'when event successfully created' do
    before do 
      create_event
    end

    subject { last_response }

    it "should return 200 HTTP code for valid params" do
      subject.status.should == 200
    end

    it "should return json" do
      subject.header['Content-Type'].should == 'application/json;charset=utf-8'
    end

    it "should save event into database" do
      Event.count.should == 1
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
