class GoalsController < ApplicationController
  def index
    @goals = Goal.all
    @root_goals = Goal.root_goals
  end
  
  def create
    @new_goal = Goal.new
    title = goal_params[:title]
    description = goal_params[:description]
    deadline = goal_params[:deadline]
    parent_id = goal_params[:parent_id].to_i
    @new_goal.assign_attributes({title: title,
       description: description,
       deadline: deadline,
       parent_id: parent_id
      })
    @new_goal.save
    redirect_to '/home'
  end

  def calendar
    @current_date = Date.today
    @current_date = @current_date.strftime('%a %d %b %Y')

    @current_goals = TimeTile.by_day(@current_date)

    if @current_goals.length == 0
      assign_goals
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
    params.require(:goal).permit(:title, :description, :deadline, :parent_id)
  end

end
