class Goal < ActiveRecord::Base
  has_many :subgoals, class_name: "Goal",
                      foreign_key: "parent_id"

  belongs_to :parent, class_name: "Goal"

  has_one :goal_map

  attr_accessor :pick_color, :repeat1, :repeat2, :repeat3, :repeat4, :repeat5, :repeat6, :repeat7, :repeat8, :hardcode_time, :starttime, :endtime, :allocate_minutes

  @FLUID = "fluid"
  @FIXED = "hard_code"

  class << self
    attr_reader :FLUID, :FIXED
  end

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
        goal.assign(status: Goal.FIXED)
      else
        goal.assign(status: Goal.FLUID)
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
        goal_start_time = cur_goal.find_start_time(*properties[:date_range])
      else
        goal_start_time = cur_goal.find_start_time(DateTime.now, cur_goal.deadline.to_datetime)
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

  def find_start_time(datet_start, datet_end)
    current_goal = self
    time_alloc = current_goal.timetaken
    #date_array = (datet_start.to_date..datet_end.to_date).to_a

    datet_array = (datet_start.to_datetime..datet_end.to_datetime).to_a
    datet_len = datet_array.length

    datet_slices = []

    datet_array.each_with_index do |datet, index|
      if index == (datet_len - 1)
        datet_slices << [datet, datet_end]
      else
        datet_slices << [datet, datet_array[(index+1)%(datet_len)]]
      end
    end

    puts "CHECKPOINT 1"
    req_date = current_goal.find_suitable_date(datet_slices)
    puts "CHECKPOINT 3"

    @rel_goals = []

    GoalMap.all.map {|gm| gm.goal}.each do |goal|
      if (((goal.start >= datet_start) && (goal.end <= datet_end)) || ((goal.start >= datet_start) && (goal.start <= datet_end)) || ((goal.end >= datet_start) && (goal.end <= datet_end)) || ((goal.start < datet_start) && (goal.end > datet_end)))
        @rel_goals << goal
      end
      if goal.repeatable
        (datet_start.to_date..datet_end.to_date).to_a.uniq.each do |date|
          rep_goal = goal.make_proxy_for(date)
          @rel_goals << rep_goal if rep_goal
        end
      end
    end

    free_space_avail = current_goal.free_space_on?(*req_date)
    unless free_space_avail[0]
      if datet_slices.delete(req_date)
        req_date = current_goal.find_suitable_date(datet_slices)
        free_space_avail = current_goal.free_space_on?(*req_date)
      else
        swap_goal = GoalMap.all.map {|g_m| g_m.goal}.select {|g| date_array.contain?(g.start.to_date) && g.deadline > current_goal.deadline && g.timetaken >= time_alloc}.take(1)
        start_time_goal = swap_goal.start
        swap_goal.unassign_fluid_goal!
        swap_goal.assign({status: Goal.FLUID, date_range: [current_goal.deadline, swap_goal.deadline]})
        return start_time_goal
      end
    end
    return free_space_avail[1]
  end


  def free_space_on?(datet_start, datet_end)
    cur_goal = self
    req_time = cur_goal.timetaken

    goals = @rel_goals.select {|g| (((g.start >= datet_start) && (g.end <= datet_end)) || ((g.start >= datet_start) && (g.start <= datet_end)) || ((g.end >= datet_start) && (g.end <= datet_end)) || ((g.start < datet_start) && (g.end > datet_end)))}

    goals = goals.sort_by(&:start)

    index = 0
    goal_len = goals.length
    if goal_len == 0
      return true, datet_start
    elsif goal_len == 1
      if (goals[0].end > datet_end)
        return false, nil
      else
        return ((datet_end.to_time - goals[0].end.to_time)/60 >= req_time), goals[0].end
      end
    end

    if ((goals[0].start).to_time - datet_start.to_time)/60 >= req_time
      return true, datet_start
    end
      
    while ((goals[index+1].start.to_time - goals[index].end.to_time)/60 < req_time )
      if (index == (goal_len - 2))
        if ((goals[index+1].end) > datet_end)
          return false, nil
        else
          return ((datet_end.to_time - (goals[index+1].end).to_time)/60 >= req_time), goals[index+1].end
        end
      end
      index += 1
    end
    return true, goals[index].end
  end

  def find_suitable_date(datet_slices)
    current_goal = self
    index = 0
    date_size = datet_slices.length
    puts "CHECKPOINT 2"
    while (current_goal.number_of_siblings_on(*datet_slices[index%date_size]) > current_goal.number_of_siblings_on(*datet_slices[(index+1)%date_size]))
      index += 1
    end
    datet_slices[index%date_size]
  end


  def number_of_siblings_on(datet_start, datet_end)
    cur_goal_paren = self.parent_id
    sibling_count = 0
    goal_parens = GoalMap.all.map{|g_m| g_m.goal}.select {|g| ((g.start >= datet_start) && (g.start <= datet_end)) }.map {|g| g.parent_id}
    goal_parens.each do |paren|
      if paren == cur_goal_paren
        sibling_count += 1
      end
    end
    sibling_count
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
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time, background_color: cur_goal.background_color, border_color: cur_goal.border_color})
        end
      when "Tue"
        if rep_codes.include?(2)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time, background_color: cur_goal.background_color, border_color: cur_goal.border_color})
        end
      when "Wed"
        if rep_codes.include?(3)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time, background_color: cur_goal.background_color, border_color: cur_goal.border_color})
        end
      when "Thu"
        if rep_codes.include?(4)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time, background_color: cur_goal.background_color, border_color: cur_goal.border_color})
        end
      when "Fri"
        if rep_codes.include?(5)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time, background_color: cur_goal.background_color, border_color: cur_goal.border_color})
        end
      when "Sat"
        if rep_codes.include?(6)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time, background_color: cur_goal.background_color, border_color: cur_goal.border_color})
        end
      when "Sun"
        if rep_codes.include?(7)
          start_time = (cur_goal.start.to_datetime + (date - cur_goal.start.to_date).to_i)
          end_time = (cur_goal.end.to_datetime + (date - cur_goal.end.to_date).to_i)
          goals << Goal.new({id: cur_goal.id, title: cur_goal.title, description: cur_goal.description, start: start_time, :end => end_time, background_color: cur_goal.background_color, border_color: cur_goal.border_color})
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

  def decode_to_string(arr)
    hash_decode = {1 => "Mon",
                   2 => "Tue",
                   3 => "Wed",
                   4 => "Thu",
                   5 => "Fri",
                   6 => "Sat",
                   7 => "Sun",
                   8 => "Month"}
    arr.map {|d| hash_decode[d]}
  end

  def make_proxy_for(date)
    cur_goal = self
    rep_codes = cur_goal.decode_rep_string
    day_name = date.strftime("%a")
    if decode_to_string(rep_codes).include?(day_name)
      st_time = cur_goal.start.to_datetime.change(day: date.day)
      en_time = (st_time.to_time + (cur_goal.timetaken)*60).to_datetime
    end
    return Goal.new({:start => st_time, :end => en_time, :id => cur_goal.id, :title => cur_goal.title, :description => cur_goal.description}) if st_time && en_time
  end


end
