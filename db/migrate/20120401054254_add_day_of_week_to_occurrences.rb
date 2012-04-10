class AddDayOfWeekToOccurrences < ActiveRecord::Migration
  def change
    add_column :occurrences, :day_of_week, :integer
  end
end