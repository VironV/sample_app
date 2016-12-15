class AddDefaultValueToPredictors < ActiveRecord::Migration
  def change
    change_column :users, :base_predictor, :decimal, :precision => 20, :scale => 10, :default => 0
    change_column :films, :base_predictor, :decimal, :precision => 20, :scale => 10, :default => 0
  end
end
