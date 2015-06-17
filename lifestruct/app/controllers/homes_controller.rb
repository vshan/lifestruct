class HomesController < ApplicationController
  def show
    @a = "Testing Test"
    @dates = next_seven_days(Date.today)
    @goals = Goal.all
  end

  def create
    @new_goal = Goal.new(goal_params)
    @new_goal.save
    redirect_to '/home'
  end

  private

  def next_seven_days(date)
    dates = []
    7.times do |num|
      dates.push(date + num)
    end
    dates
  end

  def goal_params
    params.require(:goal).permit(:title, :description, :deadline)
  end
end
