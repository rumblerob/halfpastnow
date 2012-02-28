class AddName2ToRawVenues < ActiveRecord::Migration
  def change
    add_column :raw_venues, :name2, :string
  end
end
