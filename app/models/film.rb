class Film < ActiveRecord::Base
  validates :title,  presence: true, length: { maximum: 250 }
  validates :director,  presence: true, length: { maximum: 100 }
  validates :year,  presence: true
  validates_uniqueness_of :title, :scope => [:director,:year]


  has_many :preferences, foreign_key: "favfilm_id", dependent: :destroy
  has_many :films_tags, foreign_key: "film_id", dependent: :destroy
  has_many :ratings, foreign_key: "film_is", dependent: :destroy
end