class AddingPriority < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.column(:priority, :integer)
    end
  end
end
