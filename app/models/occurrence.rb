class Occurrence < ActiveRecord::Base
  belongs_to :event
  belongs_to :recurrence
end
