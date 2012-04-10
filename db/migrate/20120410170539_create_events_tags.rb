class CreateEventsTags < ActiveRecord::Migration
  def change
    create_table :events_tags, :id => false, :force => true do |t|
	  t.integer :event_id
      t.integer :tag_id
	  t.timestamps
    end
  end
end
