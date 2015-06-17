class CreateGoalLogs < ActiveRecord::Migration
  def change
    create_table :goal_logs do |t|
      t.string :title
      t.text :description
      t.integer :goal_id
      t.datetime :start
      t.datetime :end
      t.text :category

      t.timestamps
    end
  end
end
