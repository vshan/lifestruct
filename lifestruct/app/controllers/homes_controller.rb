class HomesController < ApplicationController
  def show
    @goals = Goal.all
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @goal = Goal.new(goal_params)
    @goal.save
    redirect_to '/home'
  end

  private

  def goal_params
    params.require(:goal).permit(:title, :description, :deadline)
  end
end
