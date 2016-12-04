class Film_factor < ActiveRecord::Base
  belongs_to :film,  class_name: "Film"
  belongs_to :factor, class_name: "Factor"

  validates :film_id,  presence: true
  validates :factor_id,  presence: true
  validates :value,  presence: true

  validates_uniqueness_of :film_id, :scope => [:factor_id]
end