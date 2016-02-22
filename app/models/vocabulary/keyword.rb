# == Schema Information
#
# Table name: vocabulary_keywords
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  content    :text
#  user_id    :integer
#  scope      :integer          default(2)
#  created_at :datetime
#  updated_at :datetime
#  category   :text
#

class Vocabulary::Keyword < ActiveRecord::Base
  WHOLE = :whole
  INDIVIDUAL = :individual

  # キーワードの適用範囲
  SCOPES = {
    WHOLE      => 1, # 全体
    INDIVIDUAL => 2  # 自ユーザ
  }

  belongs_to :user

  validates :content, presence: true
  validates :user_id,
    presence: true,
    uniqueness: {
      scope: [:name]
    }
  validates :scope,
    presence: true,
    numericality: true,
    inclusion: {
      in: SCOPES.values
    }
  validate :scope_permission_valid

  scope :search_by_keyword, ->(keyword, user_id) {
    by_scope(user_id).
    where('content LIKE ?',
          "%#{keyword}%"
    )
  }

  scope :search_by_category, ->(category, user_id) {
    by_scope(user_id).
    where('category LIKE ?',
          "%#{category}%"
    )
  }

  scope :by_scope, ->(user_id) {
    where('(scope = ?) OR (scope = ? AND user_id = ?)',
          SCOPES[WHOLE],
          SCOPES[INDIVIDUAL],
          user_id
    )
  }

  SCOPES.each do |key, val|
    define_method("#{key}?") do
      self.scope == val
    end
  end

  def scope_human_name
    I18n.t("activerecord.attributes.vocabulary/keyword.scopes.#{self.scope}_title")
  end

  def self.categories(user_id)
    by_scope(user_id).order(:id).pluck(:category).map{ |c| c.nil? ? [] : c.split }.flatten.uniq
  end

private

   #
   #=== 管理者のみ全体の適用を認める
   #
   def scope_permission_valid
     errors.add(:scope, I18n.t('errors.messages.invalid')) if self.whole? && !self.user.try(:admin?)
   end
end
