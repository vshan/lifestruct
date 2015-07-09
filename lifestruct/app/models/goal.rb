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
      displaced_goals = Goal.free_time_between(cur_goal.start, cur_goal.end)
      goal_map = GoalMap.new
      goal_map.assign_attributes({goal_id: cur_goal.id,
                                  status_id: 2,
                                  in_week: cur_goal.in_week?})
      goal_map.save
      cur_goal.update_attribute(:prop, 1)
      displaced_goals.each {|goal| goal.assign({status: "fluid"})}
    elsif properties[:status] == "fluid"
      if properties[:date_range]
        goal_start_time = cur_goal.find_start_time(properties[:date_range])
      else
        goal_start_time = cur_goal.find_start_time
      end
      goal_map = GoalMap.new
      goal_map.assign_attributes({goal_id: cur_goal.id,
                                  status_id: 3,
                                  in_week: cur_goal.in_week?})
      goal_map.save
      cur_goal.prop = 1
      cur_goal.start = goal_start_time
      cur_goal.end = (goal_start_time.to_time + ((cur_goal.timetaken)*60)).to_datetime
      cur_goal.save
    end
  end

  def in_week?
    cur_goal = self
    time = cur_goal.start || cur_goal.deadline
    week_end_date = Date.today + 7
    if time.to_date < week_end_date
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

  def find_start_time(date_arr = nil)
    current_goal = self
    time_alloc = current_goal.timetaken
    if date_arr
      date_array = date_arr.to_a
    else
      date_array = (Date.today..current_goal.deadline.to_date).to_a
    end
    
    req_date = current_goal.find_suitable_date(date_array)
    free_space_avail = current_goal.free_space_on?(req_date)
    unless free_space_avail[0]
      if date_array.delete(req_date)
        req_date = current_goal.find_suitable_date(date_array)
        free_space_avail = current_goal.free_space_on?(req_date)
      else
        swap_goal = GoalMap.all.map {|g_m| g_m.goal}.select {|g| date_array.contain?(g.start.to_date) && g.deadline > current_goal.deadline && g.timetaken >= time_alloc}.take(1)
        start_time_goal = swap_goal.start
        swap_goal.unassign_fluid_goal!
        swap_goal.assign({status: "fluid", date_range: (current_goal.deadline..swap_goal.deadline)})
        return start_time_goal
      end
    end
    return free_space_avail[1]
  end

  def unassign_fluid_goal!
    cur_goal = self
    cur_goal.start = nil
    cur_goal.end = nil
    cur_goal.prop = nil
    cur_goal.goal_map.destroy
    cur_goal.save
  end

  def self.free_time_between(start_time, end_time)
    selected_goals = GoalMap.all.map {|g_m| g_m.goal}.select do |g| 
      (((g.start >= start_time) && (g.end <= end_time)) || ((g.start >= start_time) && (g.start <= end_time)) || ((g.end >= start_time) && (g.end <= end_time)) || ((g.start < start_time) && (g.end > end_time))) && (!g.deadline.nil?)
    end
    selected_goals.each do |goal|
      goal.unassign_fluid_goal!
    end
    selected_goals
  end

  def all_reps_in_bw(start_date, fin_date)
    goals = []
    cur_goal = self
    rep_codes = cur_goal.decode_rep_string
    (start_date..fin_date).each do |date|
      case date.strftime("%a")
      when "Mon"
        if rep_codes.include?(1)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time})
        end
      when "Tue"
        if rep_codes.include?(2)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time})
        end
      when "Wed"
        if rep_codes.include?(3)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time})
        end
      when "Thu"
        if rep_codes.include?(4)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time})
        end
      when "Fri"
        if rep_codes.include?(5)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time})
        end
      when "Sat"
        if rep_codes.include?(6)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time})
        end
      when "Sun"
        if rep_codes.include?(7)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time})
        end
      end
    end
    goals
  end

  def decode_rep_string
    cur_goal = self
    rep_codes = []
    rep_stat = cur_goal.repeatable.to_s
    rep_stat.each_char do |rep|
      rep_codes.push(rep.to_i)
    end
    rep_codes
  end

  def make_proxy_for(date)
    cur_goal = self
    rep_codes = cur_goal.decode_rep_string

    day_name = date.strftime("%a")
    
    puts rep_codes.inspect

    code = 0

    case day_name
    when "Mon"
      code = 1  
    when "Tue"
      code = 2
    when "Wed"
      code = 3
    when "Thu"
      code = 4
    when "Fri"
      code = 5
    when "Sat"
      code = 6
    when "Sun"
      code = 7
    end
    
    puts code
    st_time = nil
    en_time = nil
    puts rep_codes.include?(code)
    if rep_codes.include?(code)
      (cur_goal.start.to_datetime..(cur_goal.start.to_datetime + 7)).to_a.each_with_index do |dt, index|
        puts dt
        puts index
        if dt.to_date == date
          st_time = dt
          en_time = (cur_goal.end.to_datetime + index) 
          break
        end
      end
    end

    puts st_time
    puts en_time
    
    return Goal.new({:start => st_time, :end => en_time, :id => cur_goal.id, :title => cur_goal.title, :description => cur_goal.description}) if st_time && en_time
  end

  def free_space_on?(date)
    cur_goal = self
    req_time = cur_goal.timetaken
    #goals = GoalMap.all.map {|g_m| g_m.goal }.select { |g|  (g.start.to_date..g.end.to_date).to_a.include?(date) }.sort_by {|g| g.start }
    goals = []
    GoalMap.all.map {|gm| gm.goal}.each do |goal|
      if (goal.start.to_date..goal.end.to_date).to_a.include?(date)
        goals.push(goal)
      end
      puts "STARTED MAKING PROXY FOR #{goal.title}!!!"
      rep_goal = goal.make_proxy_for(date)
      puts "PROXY MADE: #{rep_goal.start if rep_goal} #{rep_goal.end if rep_goal}!!"
      puts "PROXY FINDING ENDED FOR #{goal.title}!!!"
      if !rep_goal.nil?
        if (rep_goal.start.to_date..rep_goal.end.to_date).to_a.include?(date)
          goals.push(rep_goal)
        end
      end
    end

    goals.sort_by(&:start)


    puts goals.inspect
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
    while (current_goal.number_of_siblings_on(date_array[index%date_size]) >= current_goal.number_of_siblings_on(date_array[(index+1)%date_size]))
      index += 1
    end
    date_array[index%date_size]
  end
end
