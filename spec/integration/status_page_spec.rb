require 'spec_helper'
require 'ssl'

describe 'Status' do
  include CalendarApp

  it_should_behave_like "HTTPS" do
    let(:do_request) { get_status }

    it "should return 200 OK" do
      get_status
      last_response.status.should == 200
      parsed_last_response.should == { 'message' => 'OK' }
    end
  end
  private
  def get_status(params = {})
    get '/status', params, base_env
  end
end