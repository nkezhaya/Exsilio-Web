class CreateWaypoints < ActiveRecord::Migration
  def change
    create_table :waypoints do |t|
      t.integer :tour_id
      t.integer :position
      t.string :name
      t.string :description

      t.timestamps null: false
    end
    add_index :waypoints, :tour_id
    add_index :waypoints, :position
  end
end
