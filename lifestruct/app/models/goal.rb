class Goal < ActiveRecord::Base
  has_many :subgoals, class_name: "Goal",
                      foreign_key: "parent_id"

  belongs_to :parent, class_name: "Goal"

  has_one :goal_map

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
      return 1
    else
      return 0
    end
  end

  def number_of_siblings_on(date)
    cur_goal_paren = self.parent_id
    sibling_count = 0
    goal_parens = GoalMap.all.map{|g_m| g_m.goal}.select {|g| g.start.to_date == date }.map {|g| g.parent_id}
    goal_parens.each do |paren|
      if paren == cur_goal_paren
        sibling_count += 1
      end
    end
    sibling_count
  end

  def find_start_time
    current_goal = self
    time_alloc = current_goal.timetaken
    deadline = current_goal.deadline
    date_array = (Date.today..deadline.to_date).to_a
    
    req_date = current_goal.find_suitable_date(date_array)
    free_space_avail = current_goal.free_space_on?(req_date)
    unless free_space_avail[0]
      if date_array.delete(req_date)
        req_date = current_goal.find_suitable_date(date_array)
        free_space_avail = current_goal.free_space_on?(req_date)
      else
        # NO DAYS ARE FREE.
        # FIND FIRST FREE SPACE
        # SWAP
      end
    end
    free_space_avail[1]
  end

  def free_time_between(start_time, end_time)
    GoalMap.all.map {|g_m| g_m.goal}.select do |g| 
      (((g.start >= start_time) && (g.end <= end_time)) || ((g.start >= start_time) && (g.start <= end_time)) || ((g.end >= start_time) && (g.end <= end_time)) || ((g.start < start_time) && (g.end > end_time))) 
    end.each {|g| #g.assign }
    }
  end

  def free_space_on?(date)
    cur_goal = self
    req_time = cur_goal.timetaken
    goals = GoalMap.all.map {|g_m| g_m.goal }.select {|g| g.start.to_date == date }
    index = 0
    goal_len = goals.length
    if goal_len == 0
      return true, date.to_datetime.change(offset: "+0530")
    elsif goal_len == 1
      if (goals[0].end > ((date + 1).to_datetime.change(offset: "+0530")))
        return false, nil
      else
        return ((((date + 1).to_datetime.change(offset: "+0530")).to_time - (goals[0].end).to_time)/60 >= req_time), goals[0].end
      end
    end

    if ((goals[0].start).to_time - (date).to_datetime.change(offset: "+0530").to_time)/60 >= req_time
      return true, date.to_datetime.change(offset: "+0530")
    end
      
    while ((goals[index+1].start.to_time - goals[index].end.to_time)/60 < req_time )
      if (index == (goal_len - 2))
        if ((goals[index+1].end) > ((date + 1).to_datetime.change(offset: "+0530")))
          return false, nil
        else
          return ((((date + 1).to_datetime.change(offset: "+0530")).to_time - (goals[index+1].end).to_time)/60 >= req_time), goals[index+1].end
        end
      end
      index += 1
    end
    return true, goals[index].end
  end

  def find_suitable_date(date_array)
    current_goal = self
    index = 0
    date_size = date_array.length
    while (current_goal.number_of_siblings_on(date_array[index%date_size]) > current_goal.number_of_siblings_on(date_array[(index+1)%date_size]))
      index += 1
    end
    date_array[index%date_size]
  end
end
