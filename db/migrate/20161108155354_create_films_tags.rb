class CreateFilmsTags < ActiveRecord::Migration
  def change
    create_table :films_tags do |t|
      t.integer :film_id
      t.integer :tag_id
      t.timestamps
    end
    add_index :films_tags, :film_id
    add_index :films_tags, :tag_id
  end
end
