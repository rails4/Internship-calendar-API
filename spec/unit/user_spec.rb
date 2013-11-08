require 'spec_helper'

describe User do
  it { should have_field(:email).of_type(String) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }

  it { should have_field(:password).of_type(String) } 
  it { should validate_presence_of(:password) }
  it { should validate_confirmation_of(:password) }
end
