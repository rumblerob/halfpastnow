class RawVenue < ActiveRecord::Base
	has_many :raw_events, :class_name => "RawEvent"
	belongs_to :venue
end
