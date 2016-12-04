class CreateSvdParams < ActiveRecord::Migration
  def change
    create_table :svd_params do |t|
      t.string :name
      t.decimal :value
    end
    add_index :svd_params, :name
  end
end
