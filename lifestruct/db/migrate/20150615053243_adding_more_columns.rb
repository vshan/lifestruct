class AddingMoreColumns < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.column(:progress, :float)
      t.column(:timetaken, :float)
      t.column(:deadline, :datetime)
    end
  end
end
