class RemoveDescriptionFromWaypoints < ActiveRecord::Migration
  def change
    remove_column :waypoints, :description, :string
  end
end
