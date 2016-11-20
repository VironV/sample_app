class CreateUsersTags < ActiveRecord::Migration
  def change
    create_table :users_tags do |t|
      t.integer :user_id
      t.integer :tag_id
      t.integer :count
      t.timestamps
    end
    add_index :users_tags, :user_id
    add_index :users_tags, :tag_id
  end
end
