class RemoveDesc < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.remove(:desc)
    end
  end
end
