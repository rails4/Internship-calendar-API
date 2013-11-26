shared_examples_for "HTTPS" do
  let(:base_env) { {'HTTPS' => 'on'} }

  context "without https enabled" do
    let(:base_env) { {} }

    it "should reject non-https requests" do
      do_request
      last_response.status.should == 403
      last_response.body.should be_blank
    end
  end
end
