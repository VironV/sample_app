class SVD_param < ActiveRecord::Base
  validates :name,  presence: true, length: { maximum: 250 }
  validates :value, presence: true
end