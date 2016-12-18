class Film < ActiveRecord::Base
  validates :title,  presence: true, length: { maximum: 250 }
  validates :director,  presence: true, length: { maximum: 100 }
  validates :year,  presence: true
  validates :base_predictor, presence: true
  validates_uniqueness_of :title, :scope => [:director,:year]


  has_many :preferences, foreign_key: "favfilm_id", dependent: :destroy
  has_many :ratings, foreign_key: "film_id", dependent: :destroy

  scope :average_rating, ->(user_id) { joins("INNER JOIN ratings ON users.id = ratings.user_id AND users.id=user_id").average("value")}
  scope :average_rating, ->(film_id) { joins("INNER JOIN ratings ON films.id = ratings.film_id AND films.id=film_id").average("value")}
end