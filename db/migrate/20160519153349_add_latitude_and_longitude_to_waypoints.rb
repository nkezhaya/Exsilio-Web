class AddLatitudeAndLongitudeToWaypoints < ActiveRecord::Migration
  def change
    add_column :waypoints, :latitude, :decimal, precision: 9, scale: 6
    add_column :waypoints, :longitude, :decimal, precision: 9, scale: 6
  end
end
