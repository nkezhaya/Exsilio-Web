class SaveAll < ActiveRecord::Migration
  def change
    User.all.each(&:save)
    Tour.all.each(&:save)
  end
end
