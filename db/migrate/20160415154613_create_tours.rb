class CreateTours < ActiveRecord::Migration
  def change
    create_table :tours do |t|
      t.integer :user_id
      t.string :name
      t.string :description

      t.timestamps null: false
    end
    add_index :tours, :user_id
  end
end
