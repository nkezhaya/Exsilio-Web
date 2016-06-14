class AddLatitudeAndLongitudeToTours < ActiveRecord::Migration
  def change
    add_column :tours, :latitude, :decimal, precision: 9, scale: 6
    add_column :tours, :longitude, :decimal, precision: 9, scale: 6

    add_index :tours, :latitude
    add_index :tours, :longitude
  end
end
