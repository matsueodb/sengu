# == Schema Information
#
# Table name: user_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  section_id :integer
#

class UserGroup < ActiveRecord::Base
  has_many :user_groups_members, foreign_key: :group_id, class_name: UserGroupsMember, dependent: :destroy
  has_many :users, through: :user_groups_members
  has_many :templates
  belongs_to :section

  validates :name,
    presence: true,
    length: {maximum: 255}
  validates :section_id, presence: true

  #
  #=== 引数で渡したユーザがグループのメンバーか？
  #==== 戻り値
  # * true: メンバー, false: メンバーではない
  def member?(user)
    user_groups_members.where("user_id = ?", user.id).exists?
  end

  #
  #=== selfに関連するテンプレートがあるか？
  #==== 戻り値
  # * true: あり, false: なし
  def has_template?
    self.templates.exists?
  end

  #
  #=== selfが削除可能か？
  #==== 戻り値
  # * true: 可, false: 不可
  def destroyable?
    !has_template?
  end
end
