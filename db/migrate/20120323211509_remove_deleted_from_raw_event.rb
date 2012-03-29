class RemoveDeletedFromRawEvent < ActiveRecord::Migration
  def change
    remove_column :raw_events, :deleted
    add_column :raw_events, :is_deleted, :boolean
    remove_column :raw_events, :submitted
    add_column :raw_events, :is_submitted, :boolean
  end
end
