class Tag < ActiveRecord::Base
  validates :title, presence:true
  validates_uniqueness_of :title
  validates :description, length: { maximum: 5000 }
end