class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  has_secure_password

  field :email, type: String
  field :password_digest, type: String

  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: (/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i) }
end
