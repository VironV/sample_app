class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer :favfilm_id
      t.integer :fan_id

      t.timestamps
    end
    add_index :preferences, :fan_id
    add_index :preferences, :favfilm_id
  end
end
