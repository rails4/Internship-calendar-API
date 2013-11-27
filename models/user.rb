class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  has_and_belongs_to_many :events
  has_secure_password

  field :email, type: String
  field :password_digest, type: String
  field :token
  field :password_reset_token, type: String
  field :password_reset_sent_at, type: DateTime

  before_create :tokenize

  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: (/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i) }

  def password_reset
    self.password_reset_token = Digest::MD5.hexdigest([email, Time.now].join)
    self.password_reset_sent_at = Time.now
    self.save!
    Pony.mail(
      to: self.email,
      from: 'admin@calendar.shelly-app.com',
      subject: 'Password reset link from Calendar',
      body: "Reset link: #{self.password_reset_token}"
    )
  end

  def tokenize
    self.token = Digest::MD5.hexdigest([email, password_digest].join)
  end
end
