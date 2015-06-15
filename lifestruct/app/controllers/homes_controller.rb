class HomesController < ApplicationController
  def show
    @a = "Testing Test"
    @dates = next_seven_days(Date.new(2015,6,30))
  end

  private

  def next_seven_days(date)
    dates = []
    7.times do |num|
      dates.push(date + num)
    end
    dates
  end
end
