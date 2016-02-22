# == Schema Information
#
# Table name: sections
#
#  id        :integer          not null, primary key
#  name      :string(255)
#  copyright :string(255)
#

#
#== 所属
#
class Section < ActiveRecord::Base
  has_many :users
  has_many :user_groups
  has_many :services

  validates :name,
    presence: true,
    length: {maximum: 255},
    uniqueness: true
  validates :copyright,
    length: {maximum: 255}

  #=== 削除できるか判定
  #
  #==== 戻り値
  # * boolean
  def destroyable?
    !self.users.exists?
  end

  #=== 編集出来るユーザか？
  #
  #==== 戻り値
  # * boolean
  def editable?(user)
    user.admin? || self.manager?(user)
  end

  #=== ユーザを追加出来るユーザか？
  #
  #==== 戻り値
  # * boolean
  def addable_user?(user)
    user.admin? || self.manager?(user)
  end

  #=== グループを追加出来るユーザか？
  #
  #==== 戻り値
  # * boolean
  def addable_user_group?(user)
    user.admin? || self.manager?(user)
  end

  #=== 所属管理者か判定
  #
  #==== 戻り値
  # * boolean
  def manager?(user)
    self.id == user.section_id && user.section_manager?
  end

  #=== 閲覧出来るかを判定
  #
  #==== 戻り値
  # * boolean
  def displayable?(user)
    user.admin? || self.id == user.section_id
  end
end
