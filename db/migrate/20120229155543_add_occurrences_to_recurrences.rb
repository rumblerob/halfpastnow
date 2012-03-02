class AddOccurrencesToRecurrences < ActiveRecord::Migration
  def change
    add_column :occurrences, :recurrence_id, :integer
    add_index :occurrences, :recurrence_id
  end
end
