class Preference < ActiveRecord::Base
  belongs_to :fan,  class_name: "User"
  belongs_to :favfilm, class_name: "Film"
  validates :fan_id, presence:true, :null=>false
  validates :favfilm_id, presence:true, :null => false
end