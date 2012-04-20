class Occurrence < ActiveRecord::Base
  belongs_to :event
  belongs_to :recurrence
  # validates :start, :presence => true
  # validates :end, :presence => true

  def create
    self.day_of_week = (start ? start.to_date.wday : nil)
    super
  end

  def update
    self.day_of_week = (start ? start.to_date.wday : nil)
    super
  end
end
