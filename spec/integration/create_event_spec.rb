require 'spec_helper'

describe 'Create event' do
  include CalendarApp

  it "should return 400 HTTP code for invalid params" do
    create_event(nil)
    last_response.status.should == 400
  end

  it "should return 400 HTTP code for invalid params" do
    create_event(base_params.merge(
                start_time: parsed_date("13/11/2013 10:01"),
                end_time: parsed_date("13/11/2013 10:00"))
                )
    last_response.status.should == 400
  end

  it "should return 200 HTTP code for valid params" do
    create_event
    last_response.status.should == 200
  end

  it "should save event into database" do
    expect {
      create_event
    }.to change{ Event.count }.by(1)
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
