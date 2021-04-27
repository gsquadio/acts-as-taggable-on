if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddUuidToTags < ActiveRecord::Migration[4.2]; end
else
  class AddUuidToTags < ActiveRecord::Migration; end
end
AddUuidToTags.class_eval do
  def self.up
    add_column ActsAsTaggableOn.tags_table, :uuid, :uuid

    # Don't update existing tags directly in the migration since this can be a very long blocking
    # task that can disrupt application deployments / provisioning. Use an ad-hoc call to
    # ActsAsTaggableOn::Tag.populate_uuids when ready instead
  end

  def self.down
    remove_column ActsAsTaggableOn.tags_table, :uuid
  end
end
