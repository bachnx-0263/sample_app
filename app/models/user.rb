class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_save :downcase_email

  validates :email, presence: true,
            length: {
              minimum: Settings.models.user.digits.length_20,
              maximum: Settings.models.user.digits.length_40
            },
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :name, presence: true,
            length: {maximum: Settings.models.user.digits.length_10}
  validates :password, presence: true,
            length: {minimum: Settings.models.user.digits.length_6},
            if: :password

  has_secure_password

  private

  def downcase_email
    email.downcase!
  end
end
