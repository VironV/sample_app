class ChangeDecimalInFactors < ActiveRecord::Migration
  def change
    change_column :user_factors, :value, :decimal, :precision => 10, :scale => 10
    change_column :film_factors, :value, :decimal, :precision => 10, :scale => 10
    change_column :svd_params, :value, :decimal, :precision => 10, :scale => 10
  end
end
