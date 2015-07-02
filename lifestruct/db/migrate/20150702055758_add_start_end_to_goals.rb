class AddStartEndToGoals < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.column(:start, :datetime)
      t.column(:end, :datetime)
    end
  end
end
