class AddPhoneNumberToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :phonenumber, :string
  end
end
