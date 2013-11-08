class Event
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :category, type: String
  field :subcategory, type: String
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :city, type: String
  field :address, type: String
  field :country, type: String
  field :private, type: Boolean

  validates :name, presence: true
  validates :description, presence: true
  validates :category, presence: true
  validates :subcategory, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :city, presence: true
  validates :address, presence: true
  validates :country, presence: true
  validates :private, inclusion: { in: [true, false] }
end