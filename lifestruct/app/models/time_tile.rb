class TimeTile < ActiveRecord::Base
  def self.by_day(day)
    TimeTile.where(day: day)    
  end
end
