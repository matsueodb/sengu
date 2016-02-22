# == Schema Information
#
# Table name: services
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  section_id  :integer
#

class Service < ActiveRecord::Base
  paginates_per 10

  has_many :templates, foreign_key: :service_id, class_name: "Template", dependent: :destroy
  has_many :extensions, -> {where("parent_id IS NOT NULL")}, foreign_key: :service_id, class_name: "Template"

  belongs_to :user
  belongs_to :section

  # ユーザの所属のサービスもしくは、ユーザが参加している、グループに割り当てられているテンプレートのサービス
  scope :displayables, -> (user) {
    s_ids = Template.joins(user_group: :user_groups_members)
                    .where("user_groups_members.user_id = ?", user.id)
                    .pluck(:service_id).uniq
    where("section_id = ? OR id IN (?)", user.section_id, s_ids).order(:id)
  }

  scope :search_by_keyword, -> (keyword) {
    where('name LIKE ? OR description LIKE ?',  "%#{keyword}%", "%#{keyword}%")
  }

  validates :name,
    presence: true,
    length: { maximum: 255 }
  validates :section_id, presence: true

  #=== selfにテンプレートを追加できるか？
  # サービスの所属内の管理者および所属管理者
  #==== 引数
  # * user - ユーザインスタンス
  #==== 戻り値
  # * boolean - true: 追加可能, false: 追加不可
  def addable_template?(user)
    self.section_id == user.section_id && user.manager?
  end

  #
  #=== サービスの編集、削除ができるユーザか？
  # ユーザの所属の管理するサービスでかつ、管理者か所属管理者
  #==== 戻り値
  # * true or false
  def operator?(user)
    self.section_id == user.section_id && user.manager?
  end

  def managed_by?(section)
    self.section_id == section.id
  end
end
