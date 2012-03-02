class AddEventsToRecurrences < ActiveRecord::Migration
  def change
    add_column :recurrences, :event_id, :integer
    add_index :recurrences, :event_id
  end
end
