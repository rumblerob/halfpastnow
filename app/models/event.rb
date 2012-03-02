class Event < ActiveRecord::Base
  belongs_to :venue
  has_many :occurrences, :dependent => :destroy
  accepts_nested_attributes_for :occurrences, :allow_destroy => true

  
  define_index do
        indexes title, :sortable => true
        indexes description
        indexes venue.name
  end

    
end
