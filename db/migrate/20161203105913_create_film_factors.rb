class CreateFilmFactors < ActiveRecord::Migration
  def change
    #drop_table :film_factors
    create_table :film_factors do |t|
      t.integer :film_id
      t.integer :factor_id
      t.decimal :value
    end
    add_index :film_factors, :film_id
    add_index :film_factors, :factor_id
  end
end
