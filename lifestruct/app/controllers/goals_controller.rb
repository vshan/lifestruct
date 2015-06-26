class GoalsController < ApplicationController
  def index
    @goals = Goal.all
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

  private

  def goal_params
    params.require(:goal).permit(:title, :description, :deadline, :parent_id)
  end

end
