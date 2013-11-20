require 'spec_helper'

describe 'Status' do
  include CalendarApp

  it "should return 200 OK" do
    get '/status'
    last_response.status.should == 200
    parsed_last_response.should == { 'message' => 'OK' }
  end
end