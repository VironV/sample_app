class AddIndexToTagsTitle < ActiveRecord::Migration
  def change
    add_index :tags, :title
  end
end
