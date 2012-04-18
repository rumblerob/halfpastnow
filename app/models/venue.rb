class Venue < ActiveRecord::Base
  has_and_belongs_to_many :tags
  has_many :events, :dependent => :destroy
  has_many :raw_venues
  accepts_nested_attributes_for :events, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true

  def raw_events (params = {})

  	return (self.raw_venues.collect do |raw_venue| 
  		raw_venue.raw_events.select do |raw_event| 
  			raw_event.submitted == params[:submitted] && raw_event.deleted == params[:deleted] 
  		end
  	end).flatten.compact
  end
end
