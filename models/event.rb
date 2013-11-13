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
  validate  :dates_in_order

  def dates_in_order
    if end_time != nil && start_time != nil
      DateTime.parse(start_time.to_s) rescue errors.add(:start_time, "wrong format of date")
      DateTime.parse(end_time.to_s) rescue errors.add(:end_time, "wrong format of date")
      errors.add(:start_time, "must be before or equal end time") if end_time < start_time
    end
  end
        
  def self.coordinates(city, address)
    Geocoder.coordinates("#{city}, #{address}")
  end
end
