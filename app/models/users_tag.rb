class Users_tag < ActiveRecord::Base
  belongs_to :user,  class_name: "User"
  belongs_to :tag, class_name: "Tag"
  validates :user_id, presence:true
  validates :tag_id, presence:true
  validates :count, presence:true
  validates_uniqueness_of :user_id, :scope => [:tag_id]
end