class AddChildPropGoals < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.column(:has_child, :integer)
    end
  end
end
