class AddTagsToTags < ActiveRecord::Migration
  def change
	add_index  :tags, :parent_tag_id
  end
end
