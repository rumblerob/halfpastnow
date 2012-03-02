class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name
      t.text :description
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.integer :zip
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
