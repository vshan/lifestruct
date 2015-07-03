class Goal < ActiveRecord::Base
  has_many :subgoals, class_name: "Goal",
                      foreign_key: "parent_id"

  belongs_to :parent, class_name: "Goal"

  def self.root_goals
    Goal.where(parent_id: nil)
  end

  def self.leaf_goals
    Goal.where(has_child: nil)
  end

  def self.leaf_unassigned_goals
    Goal.where({has_child: nil, prop: nil})
  end

  def self.assign_goals
    leaf_goals = Goal.leaf_unassigned_goals
    leaf_goals.each do |goal|
      if goal.deadline.nil?
        goal.assign({status: "hard_code"})
      else
        goal.assign({status: "fluid"})
      end
    end
  end

  def assign(properties)
    cur_goal = self
    if properties[:status] == "hard_code"
      goal_map = GoalMap.new
      goal_map.assign_attributes({goal_id: cur_goal.id,
                                  status_id: 2,
                                  in_week: cur_goal.in_week?})
      goal_map.save
    elsif properties[:status] == "fluid"
      cur_goal.find_start_time
    end
    cur_goal.update_attribute(:prop, 1)
  end

  def in_week?
    time = cur_goal.start || cur_goal.deadline
    cur_goal = self
    week_end_date = Date.today + 7
    if time < week_end_date
      1
    else
      0
    end
  end

  private

  def find_start_time
    current_goal = self
    time_alloc = current_goal.timetaken
    deadline = current_goal.deadline
    days_left = Date.today - deadline.to_date
  end
end
