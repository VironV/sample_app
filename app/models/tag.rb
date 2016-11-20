class Tag < ActiveRecord::Base
  validates :title, presence:true
  validates :description, length: { maximum: 5000 }
end