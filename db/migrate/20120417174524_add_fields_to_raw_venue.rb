class AddFieldsToRawVenue < ActiveRecord::Migration
  def change
    add_column :raw_venues, :raw_id, :string
    add_column :raw_venues, :from, :string
    add_column :raw_venues, :venue_id, :integer
    remove_column :raw_venues, :name2
    add_index  :raw_venues, :venue_id
  end
end
