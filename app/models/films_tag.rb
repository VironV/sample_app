class Films_tag < ActiveRecord::Base
  belongs_to :film,  class_name: "Film"
  belongs_to :tag, class_name: "Tag"
  validates :film_id, presence:true
  validates :tag_id, presence:true
end