class AddSomeMoreFieldsToRawEvent < ActiveRecord::Migration
  def change
    remove_column :raw_events, :is_deleted
    add_column :raw_events, :deleted, :boolean
    remove_column :raw_events, :is_submitted
    add_column :raw_events, :submitted, :boolean
  end
end
