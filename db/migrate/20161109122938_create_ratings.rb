class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :film_id
      t.integer :user_id
      t.integer :value
      t.timestamps
    end
    add_index :ratings, :film_id
    add_index :ratings, :user_id
  end
end
