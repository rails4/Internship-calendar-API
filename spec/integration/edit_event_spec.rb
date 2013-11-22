require 'spec_helper'

describe 'Edit event' do
  include CalendarApp
  
  before(:all) {
    @current_user = user
    @token = @current_user.token
  }

  before(:each) {
    event = Event.create(
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
    event.users << @current_user
    #event.save
    @event_id = event.id
  }

  context 'when request params doesnt have any params' do
    before(:all) { edit_event(id: nil) }
    it 'should return data in JSON' do
      last_response.header['Content-type'].should == "application/json;charset=utf-8"
    end
    it 'should return HTTP 400' do
      last_response.status.should == 403
    end
    it 'should return error message' do
      parsed_last_response['message'].should == 'Forbidden'
    end
  end

  context 'when request params doesnt have valid id' do
    before(:all) { edit_event(id: 'not-existed-id', token: @token) }
    it 'should return data in JSON' do
      #puts "CURRENT USER: #{@current_user}"
      #puts "TOKEN: #{@token}"
      #puts "TOKEN FROM CU: #{@current_user.token}"
      #puts "USER BY TOKEN : #{User.find_by(token: @token])}"
      last_response.header['Content-type'].should == "application/json;charset=utf-8"
    end
    it 'should return HTTP 404' do
      last_response.status.should == 404
    end
    it 'should return error message' do
      parsed_last_response['message'].should == 'Event not found'
    end
  end
  
  context "when edit event failed" do
    before(:all) {
      puts
      puts "CU TOKEN: #{@current_user.token}"
      puts "TOKEN: #{@token}"
      puts "TOKEN FROM DB: #{(User.find_by(token: @token)).token}"
      puts
    }
    context "for end_time less than start_time" do
      subject! {
        edit_event(
          base_params.merge(
            id: @event_id,
            token: @token,
            start_time: parsed_date("13/11/2013 10:01"),
            end_time: parsed_date("13/11/2013 10:00"))
        )
        #puts "EVENT ID: #{@event_id}"        
        #puts "CURRENT USER: #{@current_user}"
        #puts "USER BY TOKEN : #{User.find_by(token: @token)}"
        #puts "ALL USERS: #{User.find()}"
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
        edit_event(
          base_params.merge(
            start_time: nil,
            end_time: parsed_date("13/11/2013 10:00"))
          )
        #last_response
      }
      it "should return 400 HTTP code" do
        subject.status.should == 400
      end
      it "should return message" do
        parsed_last_response["message"].should == "Validation failed: blank params"
      end
    end
  end

  context 'when event was successfully edited' do
    subject {
      edit_event
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
      parsed_last_response["message"].should == "Event updated successfully"
    end
  end
  
  def edit_event(params=base_params)
    put "/event/#{params[:id]}", params
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
      private: false,
      owner: @token
    }
  end
end
