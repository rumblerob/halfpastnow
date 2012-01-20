class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :image_url
      t.decimal :price
      t.date :date
      t.time :time

      t.timestamps
    end
  end
end
