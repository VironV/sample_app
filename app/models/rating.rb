class Rating < ActiveRecord::Base
  belongs_to :film,  class_name: "Film"
  belongs_to :user, class_name: "User"

  validates :film_id, presence:true
  validates :user_id, presence:true
  validates :value, presence:true, :inclusion => 1..10
  validates_uniqueness_of :film_id, :scope => [:user_id]
end