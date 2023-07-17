class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  scope :newest, ->{order created_at: :desc}
  scope :by_user_id, ->(id){where user_id: id}
  validates :content, presence: true,
                      length: {maximum: Settings.models.post.digits.length_140}
  validates :image, content_type: {in: %w(image/jpeg image/gif image/png),
                                   message: I18n.t("image.invalid")},
                    size: {less_than: 5.megabytes,
                           message: I18n.t("image.size_invalid")}

  # Returns a resized image for display.
  def display_image
    image.variant(resize_to_limit: [Settings.image.size_500,
                                    Settings.image.size_500])
  end
end
