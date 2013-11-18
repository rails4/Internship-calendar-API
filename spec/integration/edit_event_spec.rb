require 'spec_helper'

describe 'Edit event' do
  include CalendarApp
  def setup
	Event.create(
	  name: "name1",
      description: "dsc1",
      category: "test_category",
      subcategory: "test_subcategory",
      start_time: parsed_date("20/11/2013 22:00"),
      end_time: parsed_date("21/11/2013 9:00"),
      city: "New York",
      address: "35th, Ave",
      country: "America",
      private: false
	)
  end
  
  it "should return 400 HTTP code for nil params" do
    edit_event(nil)
    last_response.status.should == 400
  end
  
  it "should return 400 HTTP code for missing id parameter" do
    edit_event(nil)
    last_response.status.should == 400
  end

  it "should return 400 HTTP code for end_time less than start_time" do
    edit_event(base_params.merge(
                start_time: parsed_date("13/11/2013 10:01"),
                end_time: parsed_date("13/11/2013 10:00"))
                )
    last_response.status.should == 400
  end

  it "should return 400 HTTP code for one nil date" do
    edit_event(base_params.merge(
                start_time: nil,
                end_time: parsed_date("13/11/2013 10:00"))
                )
    last_response.status.should == 400
  end

  it "should return 200 HTTP code for valid params" do
    edit_event
    last_response.status.should == 200
  end

  it "should save event into database" do
    expect {
      create_event
    }.to change{ Event.count }.by(1)
  end

  def edit_event(params=base_params)
    put '/event', params
  end

  def base_params
    {
      name: "Example event name ",
      description: "Example event description",
      category: "test_category",
      subcategory: "test_subcategory",
      start_time: parsed_date("20/11/2013 22:00"),
      end_time: parsed_date("21/11/2013 9:00"),
      city: "New York",
      address: "35th, Ave",
      country: "America",
      private: false
    }
  end
end
