class User_factor < ActiveRecord::Base
  belongs_to :user,  class_name: "User"
  belongs_to :factor, class_name: "Factor"

  validates :user_id,  presence: true
  validates :factor_id,  presence: true
  validates :value,  presence: true

  validates_uniqueness_of :user_id, :scope => [:factor_id]
end