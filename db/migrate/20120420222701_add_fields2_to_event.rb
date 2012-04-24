class AddFields2ToEvent < ActiveRecord::Migration
  def change
  	change_column :events, :clicks, :integer, :default => 0
  	change_column :events, :views, :integer, :default => 0
  end
end
