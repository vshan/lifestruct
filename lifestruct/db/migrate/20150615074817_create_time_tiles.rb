class CreateTimeTiles < ActiveRecord::Migration
  def change
    create_table :time_tiles do |t|
      t.time :start
      t.time :end
      t.integer :status
      t.integer :goal_id
      t.date :day

      t.timestamps
    end
  end
end
