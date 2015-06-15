class AddReferencesToGoals < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.references :parent, index: true
    end
  end
end
