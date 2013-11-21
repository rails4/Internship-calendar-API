class InvalidDateOrder < ArgumentError; end

class Event
  include Mongoid::Document
  has_and_belongs_to_many :users

  has_and_belongs_to_many :users

  has_and_belongs_to_many :users

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
  validate  :date_in_order

  def date_in_order
    raise InvalidDateOrder if end_time && start_time && end_time < start_time
  end
end
