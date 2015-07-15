class AddBlacklistToGoalMaps < ActiveRecord::Migration
  def change
    add_column :goal_maps, :blacklist, :string
  end
end
