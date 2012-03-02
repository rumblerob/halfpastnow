class Interval
  DAY = 0
  WEEK = 1
  MONTH = 2
end

class Recurrence < ActiveRecord::Base
  has_many :occurrences, :dependent => :destroy

  def gen_occurrences
    counter_time = (range_start && range_start.to_date.to_time > Date.today.to_time) ? range_start.to_date.to_time : Date.today.to_time
    until_time = (range_end && range_end.to_time < Time.now.advance(:years => 1)) ? range_end.to_time : Time.now.advance(:years => 1)
    
    #initial occurrence
    if(day_of_week && week_of_month)
      occurrence_this_month = counter_time.beginning_of_month.advance(:weeks => week_of_month, :days => (day_of_week - counter_time.beginning_of_month.wday)%7)
      counter_time_next_month = counter_time.advance(:months => 1)
      occurrence_next_month = counter_time_next_month.beginning_of_month.advance(:weeks => week_of_month, :days => (day_of_week - counter_time_next_month.beginning_of_month.wday)%7)
      counter_time = (counter_time.mday > occurrence_this_month.mday) ? occurrence_next_month : occurrence_this_month
    elsif(day_of_week)
      counter_time.advance(:days => (day_of_week - counter_time.wday)%7)
    elsif(day_of_month)
      if(counter_time.mday > day_of_month)
	counter_time.advance(:days => (day_of_month - counter_time.mday))
      elsif(counter_time.mday < day_of_month)
	counter_time.advance(:months => 1, :days => (counter_time.mday - day_of_month))
      end
    end
    
    while (counter_time.to_date <= until_time.to_date)
      #build new occurrence
      #TODO: make this work for things that don't start and end on the same day
      start_datetime = counter_time.advance(:hours => self.start.to_time.hour, :minutes => self.start.to_time.min)
      end_datetime = counter_time.advance(:hours => self.end.to_time.hour, :minutes => self.end.to_time.min)
      occurrences.build(:start => start_datetime, :end => end_datetime, :event_id => self.event_id)
      
      #find next occurrence time
      if(day_of_week && week_of_month)
	counter_time_next_month = counter_time.advance(:months => 1)
	counter_time = counter_time_next_month.beginning_of_month.advance(:weeks => week_of_month, :days => (day_of_week - counter_time_next_month.beginning_of_month.wday)%7)
      elsif(day_of_week)
	counter_time = counter_time.advance(:weeks => (every_other || 0) + 1)
      elsif(day_of_month)
	#TODO: make this work for 29th, 30th, 31st in all cases
	counter_time = counter_time.advance(:months => (every_other || 0) + 1)
      else
	counter_time = counter_time.advance(:days => (every_other || 0) + 1)
      end
    end
    
    self.save
  end
end
