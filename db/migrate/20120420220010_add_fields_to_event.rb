class AddFieldsToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :clicks, :integer
  	add_column :events, :views, :integer
  end
end
