class AddCityAndStateToWaypoints < ActiveRecord::Migration
  def change
    add_column :waypoints, :city, :string
    add_column :waypoints, :state, :string
  end
end
