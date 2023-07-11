class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_save :downcase_email
  before_create :create_activation_digest

  validates :email, presence: true,
            length: {
              minimum: Settings.models.user.digits.length_20,
              maximum: Settings.models.user.digits.length_40
            },
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :name, presence: true
  validates :password, presence: true,
            length: {minimum: Settings.models.user.digits.length_6},
            if: :password, allow_nil: true

  has_secure_password

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"

    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_columns remember_digest: User.digest(remember_token)
  end

  def forget
    update_column :remember_digest, nil
  end

  def send_mail_active
    UserMailer.account_activation(self).deliver_now
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
