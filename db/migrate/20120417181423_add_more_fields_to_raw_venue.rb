class AddMoreFieldsToRawVenue < ActiveRecord::Migration
  def change
    add_column :raw_venues, :url, :string
    add_column :raw_venues, :description, :text
  end
end
