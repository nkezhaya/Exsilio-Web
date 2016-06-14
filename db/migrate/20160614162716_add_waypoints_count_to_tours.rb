class AddWaypointsCountToTours < ActiveRecord::Migration
  def change
    add_column :tours, :waypoints_count, :integer
  end
end
