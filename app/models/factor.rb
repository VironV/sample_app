class Factor < ActiveRecord::Base
  validates :name,  presence: true, length: { maximum: 250 }
  validates_uniqueness_of :name

  has_many :user_factors, foreign_key: "user_factor_id"
  has_many :film_factors, foreign_key: "film_factor_id"
end