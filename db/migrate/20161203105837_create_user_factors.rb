class CreateUserFactors < ActiveRecord::Migration
  def change
    create_table :user_factors do |t|
      t.integer :user_id
      t.integer :factor_id
      t.decimal :value
    end
    add_index :user_factors, :user_id
    add_index :user_factors, :factor_id
  end
end
