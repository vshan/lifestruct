class AddPropToGoals < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.column(:prop, :integer)
    end
  end
end
