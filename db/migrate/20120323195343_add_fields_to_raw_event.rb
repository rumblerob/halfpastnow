class AddFieldsToRawEvent < ActiveRecord::Migration
  def change
    add_column :raw_events, :submitted, :boolean
    add_column :raw_events, :deleted, :boolean
  end
end
