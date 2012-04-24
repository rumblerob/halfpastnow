class AddFieldsToVenue < ActiveRecord::Migration
  def change
  	add_column :venues, :clicks, :integer
  	add_column :venues, :views, :integer
  end
end
