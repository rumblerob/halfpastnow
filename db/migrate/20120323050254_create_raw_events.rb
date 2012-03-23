class CreateRawEvents < ActiveRecord::Migration
  def change
    create_table :raw_events do |t|
      t.string :title
      t.text :description
      t.datetime :start
      t.datetime :end
      t.float :latitude
      t.float :longitude
      t.string :venue_name
      t.string :venue_address
      t.string :venue_city
      t.string :venue_state
      t.string :venue_zip
      t.string :url
      t.string :raw_id
      t.string :from

      t.timestamps
    end
  end
end
