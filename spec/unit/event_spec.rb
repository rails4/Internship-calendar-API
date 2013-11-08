require 'spec_helper'

describe Event do
  it { should have_field(:name).of_type(String) }
  it { should validate_presence_of(:name) }
  it { should have_field(:description).of_type(String) }
  it { should validate_presence_of(:description) }
  it { should have_field(:category).of_type(String) }
  it { should validate_presence_of(:category) }
  it { should have_field(:subcategory).of_type(String) }
  it { should validate_presence_of(:subcategory) }
  it { should have_field(:start_time).of_type(DateTime) }
  it { should validate_presence_of(:start_time) }
  it { should have_field(:end_time).of_type(DateTime) }
  it { should validate_presence_of(:end_time) }
  it { should have_field(:city).of_type(String) }
  it { should validate_presence_of(:city) }
  it { should have_field(:address).of_type(String) }
  it { should validate_presence_of(:address) }
  it { should have_field(:country).of_type(String) }
  it { should validate_presence_of(:country) }
  it { should have_field(:private).of_type(Boolean) }
  it { should validate_inclusion_of(:private).to_allow([true, false]) }
end