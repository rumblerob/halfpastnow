class AddMoreFieldsToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :url, :string
  end
end
