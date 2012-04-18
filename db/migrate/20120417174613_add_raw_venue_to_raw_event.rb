class AddRawVenueToRawEvent < ActiveRecord::Migration
  def change
    add_column :raw_events, :raw_venue_id, :integer
    add_index  :raw_events, :raw_venue_id
  end
end
