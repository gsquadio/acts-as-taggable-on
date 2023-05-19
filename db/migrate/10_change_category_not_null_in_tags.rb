if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class ChangeCatergoryNotNullInTags < ActiveRecord::Migration[4.2]; end
else
  class ChangeCatergoryNotNullInTags < ActiveRecord::Migration; end
end
ChangeCatergoryNotNullInTags.class_eval do
  def self.up
    change_column_null ActsAsTaggableOn.tags_table, :category, false
  end

  def self.down
    change_column_null ActsAsTaggableOn.tags_table, :category, true
  end
end
