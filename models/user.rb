class User
  include Mongoid::Document

  field :email, type: String
  field :password, type: String

  validates :email, presence: true,
                    uniqueness: true,
                    format: {
                      with: (/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
                    }
  validates :password, presence: true, confirmation: true
end
