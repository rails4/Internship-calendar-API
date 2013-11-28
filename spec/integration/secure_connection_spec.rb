require 'spec_helper'

describe 'Create event' do
  include CalendarApp

  context 'without ssl' do
    it "should return 400 HTTP code" do
      #subject.status.should == 400
    end
  end
end