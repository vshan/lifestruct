class GoalsController < ApplicationController
  before_filter :set_time_zone

  def set_time_zone
    Time.zone = "Mumbai"    
  end
  def index
    @goals = Goal.all
    @root_goals = Goal.root_goals
  end
  
  def create
    render text: params
    return
    @new_goal = Goal.new
    title = goal_params[:title]
    description = goal_params[:description]
    deadline = stringify_date(goal_params[:"deadline(1i)"], goal_params[:"deadline(2i)"], goal_params[:"deadline(3i)"], goal_params[:"deadline(4i)"], goal_params[:"deadline(5i)"])
    parent_id = goal_params[:parent_id].to_i
    @new_goal.assign_attributes({title: title,
       description: description,
       deadline: deadline,
       parent_id: parent_id
      })
    @new_goal.save
    redirect_to '/home'
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
    params.require(:goal).permit(:title, :"deadline(1i)", :"deadline(2i)", :"deadline(3i)", :"deadline(4i)", :"deadline(5i)", :deadline, :parent_id)
  end

end
