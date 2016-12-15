class User < ActiveRecord::Base
  before_save { email.downcase! }
  before_create :create_remember_token

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6 }
  validates :base_predictor, presence: true

  has_many :preferences, foreign_key: "fan_id", dependent: :destroy
  has_many :users_tags, foreign_key: "user_id", dependent: :destroy
  has_many :ratings, foreign_key: "user_id", dependent: :destroy

  scope :average_rating, ->(user_id) { joins("INNER JOIN ratings ON users.id = ratings.user_id AND users.id=user_id").average("value")}
  scope :rated_movies, ->(user_id) { joins("INNER JOIN ratings ON users.id = ratings.user_id AND users.id=user_id"). select("film_id")}

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
