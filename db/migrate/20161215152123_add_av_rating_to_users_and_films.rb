class AddAvRatingToUsersAndFilms < ActiveRecord::Migration
  def change
    add_column :users, :base_predictor, :decimal, :precision => 20, :scale => 10
    add_column :films, :base_predictor, :decimal, :precision => 20, :scale => 10
  end
end
