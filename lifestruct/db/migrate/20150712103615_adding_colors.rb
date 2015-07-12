class AddingColors < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.column(:background_color, :string)
      t.column(:border_color, :string)
    end
  end
end
