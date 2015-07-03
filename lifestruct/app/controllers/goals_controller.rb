class GoalsController < ApplicationController

  def index
    @goals = Goal.all
    @root_goals = Goal.root_goals
  end
  
  def create
    #render text: params
    #return
    @new_goal = Goal.new
    title = goal_params[:title]
    description = goal_params[:description]
    deadline = stringify_date(goal_params[:"deadline(1i)"], goal_params[:"deadline(2i)"], goal_params[:"deadline(3i)"], goal_params[:"deadline(4i)"], goal_params[:"deadline(5i)"])
    starttime = stringify_date(goal_params[:"starttime(1i)"], goal_params[:"starttime(2i)"], goal_params[:"starttime(3i)"], goal_params[:"starttime(4i)"], goal_params[:"starttime(5i)"])
    endtime =  stringify_date(goal_params[:"endtime(1i)"], goal_params[:"endtime(2i)"], goal_params[:"endtime(3i)"], goal_params[:"endtime(4i)"], goal_params[:"endtime(5i)"]) 
    repeatable = goal_params[:repeatable].to_i
    hardcode_time = goal_params[:hardcode_time].to_i
    monday_stat = goal_params[:repeat1]
    tuesday_stat = goal_params[:repeat2]
    wednesday_stat = goal_params[:repeat3]
    thursday_stat = goal_params[:repeat4]
    friday_stat = goal_params[:repeat5]
    saturday_stat = goal_params[:repeat6]
    sunday_stat = goal_params[:repeat7]
    month_stat = goal_params[:repeat8]
    all_stats = [monday_stat, tuesday_stat, wednesday_stat, thursday_stat, friday_stat, saturday_stat, sunday_stat, month_stat]
    parent_id = goal_params[:parent_id]

    if parent_id.empty?
      parent_id = nil
    else
      parent_id = parent_id.to_i
      Goal.find(parent_id).update_attribute(:has_child, 1)
    end

    if hardcode_time == 1
      deadline = nil
    else
      starttime = nil
      endtime = nil
      time_alloc = goal_params[:allocate_minutes]
    end

    repeat_stat = nil
    if repeatable == 1
      rep_string = ""
      all_stats.each_with_index do |stat, index|
        if stat == "1"
          rep_string += (index + 1).to_s
        end
      end
      repeat_stat = rep_string.to_i
    end

    @new_goal.assign_attributes({title: title,
       description: description,
       deadline: deadline,
       start: starttime,
       repeatable: repeat_stat,
       :end => endtime,
       parent_id: parent_id,
       timetaken: time_alloc
      })
    @new_goal.save
    redirect_to goals_path
  end

  def stringify_date(year, month, day, hour, min)
    datetime = "#{year}-#{month}-#{day} #{hour}:#{min}"
  end

  def calendar
    @current_date = Date.today
    @current_date = @current_date.strftime('%a %d %b %Y')

    @current_goals = TimeTile.by_day(@current_date)

    if @current_goals.length == 0
      TimeTile.assign_goals(@current_date)
    else
      print_goals
    end 
  end

  def show_subgoals
    goal_parent_id = params[:parentid]
    @ul_con = "#ul-parent-#{goal_parent_id}"
    @show_sg_icn_path = "#show-parent-#{goal_parent_id} i"
    @subgoals = Goal.find(goal_parent_id).subgoals
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def goal_params
    params.require(:goal).permit(:allocate_minutes, :title, :description, :"deadline(1i)", :"deadline(2i)", :"deadline(3i)", :"deadline(4i)", :"deadline(5i)", :"starttime(1i)", :"starttime(2i)", :"starttime(3i)", :"starttime(4i)", :"starttime(5i)", :"endtime(1i)", :"endtime(2i)", :"endtime(3i)", :"endtime(4i)", :"endtime(5i)", :repeatable, :hardcode_time, :repeat1, :repeat2, :repeat3, :repeat4, :repeat5, :repeat6, :repeat7, :repeat8, :deadline, :parent_id)
  end

end
