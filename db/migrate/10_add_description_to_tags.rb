if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddDescriptionToTags < ActiveRecord::Migration[4.2]; end
else
  class AddDescriptionToTags < ActiveRecord::Migration; end
end
AddDescriptionToTags.class_eval do
  def self.up
    add_column ActsAsTaggableOn.tags_table, :description, :text
  end

  def self.down
    remove_column ActsAsTaggableOn.tags_table, :description
  end
end
