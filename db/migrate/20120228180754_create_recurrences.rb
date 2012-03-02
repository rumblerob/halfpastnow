class CreateRecurrences < ActiveRecord::Migration
  def change
    create_table :recurrences do |t|
      t.integer :interval	#daily, weekly, monthly (day of week), monthly(day of week)
      t.integer :every_other
      t.integer :day_of_week
      t.integer :day_of_month
      t.integer :week_of_month
      t.date :range_start
      t.date :range_end
      t.datetime :start
      t.datetime :end
      t.timestamps
    end
  end
end
