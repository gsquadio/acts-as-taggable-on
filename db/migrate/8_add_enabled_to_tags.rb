if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddEnabledToTags < ActiveRecord::Migration[4.2]; end
else
  class AddEnabledToTags < ActiveRecord::Migration; end
end
AddEnabledToTags.class_eval do
  def self.up
    add_column ActsAsTaggableOn.tags_table, :enabled, :boolean, default: true
  end

  def self.down
    remove_column ActsAsTaggableOn.tags_table, :enabled
  end
end
