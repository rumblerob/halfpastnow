class AddTestfieldToOccurrences < ActiveRecord::Migration
  def change
    add_column :occurrences, :testfield, :string
  end
end
