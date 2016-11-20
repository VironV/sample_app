class AddIndexToFilmsTitleDirectorYear < ActiveRecord::Migration
  def change
    add_index :films, :title
    add_index :films, :director
    add_index :films, :year
    add_index :films, [:title,:director,:year], unique: true
  end
end
