class RemoveTestfieldFromOccurrences < ActiveRecord::Migration
  def up
    remove_column :occurrences, :testfield
  end

  def down
    add_column :occurrences, :testfield, :string
  end
end
