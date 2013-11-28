require 'spec_helper'
require 'ssl'

describe 'User destroy' do
  include CalendarApp
  let(:do_request) { destroy_user }

  it_should_behave_like "HTTPS" do
    context 'when :token param is correct' do
      let(:user) { create(:user) }
      subject! do
        destroy_user(base_params.merge(token: user.token))
      end

      it "should return  200 HTTP code" do
        last_response.status.should == 200
      end

      it "should return 'The user has been removed' message" do
        parsed_last_response["message"].should == "The user has been removed!"
      end

      it 'response should be in JSON' do
        last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
      end

      it "destroy user from database" do
        expect {
          subject
          }.to change{ User.count }.by(0)
        end
      end

      context "if user doesn't exist any more" do
        let(:user) { create(:user) }
        subject! do
          destroy_user(base_params.merge(token: user.token))
          destroy_user(base_params.merge(token: nil))
        end

        it "should return  403 HTTP code " do
          last_response.status.should == 403
        end

        it "should return error 'Forbidden'" do
          parsed_last_response["message"].should == "Forbidden"
        end

        it 'response should be in JSON' do
          last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
        end
      end

      context "if user doesn't exist" do
        subject! do
          destroy_user(base_params.merge(token: nil))
        end

        it "should return  403 HTTP code " do
          last_response.status.should == 403
        end

        it "should return error 'Forbidden'" do
          parsed_last_response["message"].should == "Forbidden"
        end

        it 'response should be in JSON' do
          last_response.header['Content-Type'].should == 'application/json;charset=utf-8'
        end
      end

      private
      def destroy_user(params=base_params)
        delete "/users", params ,base_env
      end

      def base_params
        {
          token: user.token
        }
      end
    end
  end