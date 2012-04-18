class RawEvent < ActiveRecord::Base
	belongs_to :raw_venue, :class_name => "RawVenue"
end
