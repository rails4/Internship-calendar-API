require 'spec_helper'

describe User do
  it { should have_and_belong_to_many(:events) }
  it { should have_field(:email).of_type(String) }
  it { should have_field(:password_digest).of_type(String) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_format_of(:email).to_allow("calendar@calendar.com").not_to_allow("foo bar") }
end
