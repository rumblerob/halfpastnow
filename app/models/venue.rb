class Venue < ActiveRecord::Base
  has_many :events, :dependent => :destroy
  accepts_nested_attributes_for :events, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true
end
