class CreateFactors < ActiveRecord::Migration
  def change
    create_table :factors do |t|
      t.string :name
    end
  end
end
