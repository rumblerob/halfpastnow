class AddMoreToEvents < ActiveRecord::Migration
  def change
    add_column :events, :latitude, :float
    add_column :events, :longitude, :float
    add_column :events, :location, :string
  end
end
