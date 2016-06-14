class AddTotalTimeInSecondsToTours < ActiveRecord::Migration
  def change
    add_column :tours, :total_time_in_seconds, :integer, default: 0
  end
end
