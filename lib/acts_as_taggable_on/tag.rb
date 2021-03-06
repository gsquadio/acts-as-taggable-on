# encoding: utf-8
module ActsAsTaggableOn
  class Tag < ::ActiveRecord::Base
    self.table_name = ActsAsTaggableOn.tags_table

    ### ASSOCIATIONS:

    has_many :taggings, dependent: :destroy, class_name: '::ActsAsTaggableOn::Tagging'

    ### CALLBACKS:

    before_create :ensure_uuid

    ### VALIDATIONS:

    validates_presence_of :name
    validates_uniqueness_of :name, if: :validates_name_uniqueness?, case_sensitive: true
    validates_length_of :name, maximum: 255

    # monkey patch this method if don't need name uniqueness validation
    def validates_name_uniqueness?
      true
    end

    ### SCOPES:
    scope :most_used, ->(limit = 20) { order('taggings_count desc').limit(limit) }
    scope :least_used, ->(limit = 20) { order('taggings_count asc').limit(limit) }
    scope :with_categories, ->(categories , enabled = true) { where(category: categories, enabled: enabled) }

    def self.named(name)
      if ActsAsTaggableOn.strict_case_match
        where(["name = #{binary}?", as_8bit_ascii(name)])
      else
        where(['LOWER(name) = LOWER(?)', as_8bit_ascii(unicode_downcase(name))])
      end
    end

    def self.named_any(list)
      clause = list.map { |tag|
        sanitize_sql_for_named_any(tag).force_encoding('BINARY')
      }.join(' OR ')
      where(clause)
    end

    def self.named_like(name)
      clause = ["name #{ActsAsTaggableOn::Utils.like_operator} ? ESCAPE '!'", "%#{ActsAsTaggableOn::Utils.escape_like(name)}%"]
      where(clause)
    end

    def self.named_like_any(list)
      clause = list.map { |tag|
        sanitize_sql(["name #{ActsAsTaggableOn::Utils.like_operator} ? ESCAPE '!'", "%#{ActsAsTaggableOn::Utils.escape_like(tag.to_s)}%"])
      }.join(' OR ')
      where(clause)
    end

    def self.for_context(context)
      joins(:taggings).
        where(["#{ActsAsTaggableOn.taggings_table}.context = ?", context]).
        select("DISTINCT #{ActsAsTaggableOn.tags_table}.*")
    end

    ### CLASS METHODS:

    def self.find_or_create_with_like_by_name(name)
      if ActsAsTaggableOn.strict_case_match
        self.find_or_create_all_with_like_by_name([name]).first
      else
        named_like(name).first || create(name: name)
      end
    end

    def self.find_or_create_all_with_like_by_name(*list, category: nil)
      list = Array(list).flatten

      return [] if list.empty?

      existing_tags = named_any(list)
      list.map do |tag_name|
        begin
          tries ||= 3
          comparable_tag_name = comparable_name(tag_name)
          existing_tag = existing_tags.find { |tag| comparable_name(tag.name) == comparable_tag_name }
          existing_tag || create(name: tag_name, category: category)
        rescue ActiveRecord::RecordNotUnique
          if (tries -= 1).positive?
            ActiveRecord::Base.connection.execute 'ROLLBACK'
            existing_tags = named_any(list)
            retry
          end

          raise DuplicateTagError.new("'#{tag_name}' has already been taken")
        end
      end
    end

    def self.update_name(tag_name, id)
      tag = ActsAsTaggableOn::Tag.find_by(id: id)
      if tag.present?
        tag.name = tag_name
        tag.save
      end
    end

    def self.disable(id)
      tag = ActsAsTaggableOn::Tag.find_by(id: id)
      if tag.present?
        tag.enabled = false
        tag.save
      end
    end

    def self.enable(id)
      tag = ActsAsTaggableOn::Tag.find_by(id: id)
      if tag.present?
        tag.enabled = true
        tag.save
      end
    end

    def self.populate_uuids
      missing_uuid_query = ActsAsTaggableOn::Tag.where(uuid: nil)
      missing_uuid_count = missing_uuid_query.count

      missing_uuid_query.each_with_index do |tag, i|
        uuid = SecureRandom.uuid
        tag.update(uuid: uuid)

        p "(#{i + 1} / #{missing_uuid_count}) Tag '#{tag.name}': UUID is now #{uuid}!"
      end
    end

    ### INSTANCE METHODS:

    def ==(object)
      super || (object.is_a?(Tag) && name == object.name)
    end

    def to_s
      name
    end

    def count
      read_attribute(:count).to_i
    end

    private

    def ensure_uuid
      self.uuid = SecureRandom.uuid if self.uuid.blank?
    end

    class << self

      private

      def comparable_name(str)
        if ActsAsTaggableOn.strict_case_match
          str
        else
          unicode_downcase(str.to_s)
        end
      end

      def binary
        ActsAsTaggableOn::Utils.using_mysql? ? 'BINARY ' : nil
      end

      def as_8bit_ascii(string)
        string.to_s.mb_chars
      end

      def unicode_downcase(string)
        as_8bit_ascii(string).downcase
      end

      def sanitize_sql_for_named_any(tag)
        if ActsAsTaggableOn.strict_case_match
          sanitize_sql(["name = #{binary}?", as_8bit_ascii(tag)])
        else
          sanitize_sql(['LOWER(name) = LOWER(?)', as_8bit_ascii(unicode_downcase(tag))])
        end
      end
    end
  end
end
