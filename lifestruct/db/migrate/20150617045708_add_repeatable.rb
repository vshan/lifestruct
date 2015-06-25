class AddRepeatable < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.column(:repeatable, :integer)
    end
  end
end
