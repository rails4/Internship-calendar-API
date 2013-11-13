require 'spec_helper'

describe 'Status' do
  include CalendarApp

  it "should return 200 OK" do
    get '/status'
    last_response.status.should == 200
    last_response.body.should == 'OK'
  end
end
