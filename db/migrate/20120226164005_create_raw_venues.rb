class CreateRawVenues < ActiveRecord::Migration
  def change
    create_table :raw_venues do |t|
      t.string :name
      t.string :address
      t.string :address2
      t.string :city
      t.integer :zip
      t.string :state_code
      t.string :phone
      t.float :latitude
      t.float :longitude
      t.integer :rating
      t.integer :review_count
      t.text :categories
      t.text :neighborhoods

      t.timestamps
    end
  end
end
