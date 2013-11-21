class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  has_and_belongs_to_many :events
  has_secure_password
  has_and_belongs_to_many :events
  field :email, type: String
  field :password_digest, type: String
  field :token

  before_create :tokenize

  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: (/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i) }

  def tokenize
    self.token = Digest::MD5.hexdigest([email, password_digest].join)
  end
end
