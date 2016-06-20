class AddPublishedToTours < ActiveRecord::Migration
  def change
    add_column :tours, :published, :boolean, default: false
    add_index :tours, :published
  end
end
