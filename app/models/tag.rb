class Tag < ActiveRecord::Base
  belongs_to :parent_tag, :class_name => "Tag"
  has_and_belongs_to_many :events
  has_and_belongs_to_many :venues
end
