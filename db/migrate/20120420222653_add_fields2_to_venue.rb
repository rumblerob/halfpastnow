class AddFields2ToVenue < ActiveRecord::Migration
  def change
  	change_column :venues, :clicks, :integer, :default => 0
  	change_column :venues, :views, :integer, :default => 0
  end
end
