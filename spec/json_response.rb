shared_examples_for "response in JSON" do
  it 'response should be in JSON' do
  	do_request
    last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
  end
end