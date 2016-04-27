class AddImageToWaypoints < ActiveRecord::Migration
  def change
    add_attachment :waypoints, :image
  end
end
