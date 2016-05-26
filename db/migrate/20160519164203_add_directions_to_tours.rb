class AddDirectionsToTours < ActiveRecord::Migration
  def change
    add_column :tours, :directions, :jsonb
  end
end
