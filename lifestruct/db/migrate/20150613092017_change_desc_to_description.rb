class ChangeDescToDescription < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.text :description
    end
  end
end
