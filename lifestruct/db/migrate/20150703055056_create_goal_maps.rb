class CreateGoalMaps < ActiveRecord::Migration
  def change
    create_table :goal_maps do |t|
      t.integer :goal_id
      t.integer :status_id
      t.integer :in_week

      t.timestamps
    end
  end
end
