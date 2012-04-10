class CreateTagsVenues < ActiveRecord::Migration
  def change
    create_table :tags_venues, :id => false, :force => true do |t|
	  t.integer :venue_id
      t.integer :tag_id
      t.timestamps
    end
  end
end
