class RemoveDetailsFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :latitude
    remove_column :events, :longitude
    remove_column :events, :location
    remove_column :events, :date
    remove_column :events, :time
    remove_column :events, :image_url
  end

  def down
    add_column :events, :image_url, :string
    add_column :events, :time, :time
    add_column :events, :date, :date
    add_column :events, :location, :string
    add_column :events, :longitude, :float
    add_column :events, :latitude, :float
  end
end
