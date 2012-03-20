class Occurrence < ActiveRecord::Base
  belongs_to :event
  belongs_to :recurrence
  # validates :start, :presence => true
  # validates :end, :presence => true
end
