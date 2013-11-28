require 'spec_helper'

describe 'Delete user from event' do
  include CalendarApp

   context "user " do
  	let(:user) { create(:user) }
  	let(:event) { create(:event) }
	    subject! do
	    	event.owner = user._id
	    	event.save
	    	event.users << user
	    	delete_user_from_event(base_params)
	    end
        
    it 'response should be in JSON' do
      last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
    end
  
    it "should return 200 HTTP code" do
      last_response.status.should == 200
    end

    it "should return JSON formatted message {'message': 'User has been removed from event'}" do
      parsed_last_response["message"].should == "User has been removed from event"
    end

    it "should delete user from event from database" do
      expect {
        subject
      }.to change{ event.users.count }.by(0)
    end
  end

  context "user " do
  
  	let(:event) { create(:event) }
	    subject! do

	    	puts event.users.count
	    	Mongoid.purge!
	    	
	    	# event.owner = user._id
	    	# event.save
	    	# event.users << user
	    	event.users << create(:user, email: "cos_#{rand(100)}@email.com")
	    	puts event.users.count
	    	# puts event.reload.users.to_a
		    # delete_user_from_event(base_params)
	    end

   

    it "should delete user from event from database" do
     User.count.should == 2
     subject 
     User.count.should == 2
    end
  end  

  private
  def delete_user_from_event(params = base_params)
    delete '/event/users/', params
  end

  def base_params
    {
    	email: user.email,
    	id: event.id,
      token: user.token
    }
  end
end