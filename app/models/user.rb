# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  login              :string(255)      default(""), not null
#  encrypted_password :string(255)      default(""), not null
#  name               :string(255)
#  remarks            :string(255)
#  authority          :integer
#  created_at         :datetime
#  updated_at         :datetime
#  section_id         :integer
#  copyright          :string(255)
#

#
#== ユーザモデル
#
class User < ActiveRecord::Base
  devise :database_authenticatable

  @@authorities = {
    admin: 0, editor: 1, section_manager: 2 # 0: 管理者, 1:編集者, 2:所属管理者
  }.freeze

  cattr_reader :authorities

  has_many :templates, dependent: :destroy
  has_many :template_records, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :user_groups_members, dependent: :destroy
  has_many :user_groups, through: :user_groups_members
  has_many :vocabulary_keywords, class_name: 'Vocabulary::Keyword', dependent: :delete_all
  belongs_to :section

  validates :name, presence: true, length: {maximum: 255}
  validates :login,
    presence: true,
    format: {with: /\A\w[\w\.\-_@]+\z/, if: Proc.new{self.login.present?}},
    uniqueness: {if: :login_changed?}, length: {maximum: 255}
  validates :password,
    presence: {if: :password_required?},
    confirmation: {if: :password_required?},
    length: {within: 6..30, if: Proc.new{self.password.present?}},
    format: {with: /\A[a-zA-Z0-9\-_]+\z/, if: Proc.new{self.password.present?}}
  validates :password_confirmation, presence: {if: Proc.new{self.password.present?}}
  validates :authority, inclusion: {in: @@authorities.values}
  validates :section_id, presence: true
  validates :copyright, length: {maximum: 255}
  validate :validates_change_section_id


  scope :by_section, -> (section_id){where(section_id: section_id)}

  before_update :change_section_destroy_groups

  #
  #=== 運用管理者か？
  #==== 戻り値
  # true: 管理者, false: そのた
  def admin?
    self.authority == User.authorities[:admin]
  end

  #
  #=== データ登録者か？
  #==== 戻り値
  # true: 編集者, false: そのた
  def editor?
    self.authority == User.authorities[:editor]
  end
  #
  #=== 所属管理者か？
  #==== 戻り値
  # true: 管理者, false: そのた
  def section_manager?
    self.authority == User.authorities[:section_manager]
  end

  #
  #=== 管理者か所属管理者か？
  #==== 戻り値
  # true: 管理者か所属管理者, false: そのた
  def manager?
    self.admin? || self.section_manager?
  end

  #
  #=== authorityに対応するラベルを返す
  #==== 戻り値
  # String - 管理者、編集者、所属管理者
  def self.authority_label(value)
    I18n.t("activerecord.attributes.user.authority_label.#{@@authorities.invert[value.to_i]}")
  end

  #
  #=== authorityに対応するラベルを返す
  #==== 戻り値
  # String - 管理者、編集者、所属管理者
  def authority_label
    User.authority_label(self.authority)
  end

  #
  #=== ユーザ更新時にparams[:password]があるかどうかをみて更新
  #==== 引数
  # * params - パラメータ
  # * options - update_attributesに渡すオプション
  def update_with_password!(params, current_user)
    current_user_auth = current_user.authority
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    self.attributes = params
    if current_user_auth == User.authorities[:admin]
    else
      if current_user_auth == User.authorities[:section_manager]
        self.authority == User.authorities[:section_manager] if self.authority == User.authorities[:admin]
      end
    end

    result = self.save!(params)

    clean_up_passwords
    result
  end

  #
  #=== ユーザのデータを引き継ぐ
  # self -> to_userへ
  # 引き継ぐデータは以下とする。
  # * 登録したデータ
  def inherit_data(to_user)
    self.template_records.update_all(user_id: to_user.id)
  end

  #
  #=== 表示できるか？
  # 運用管理者または、所属管理者もしくは、自分
  def accessible?(user)
    return (user.admin? || user.id == self.id || self.section.manager?(user))
  end
  #
  #=== 編集できるか？
  # 運用管理者または、所属管理者もしくは、自分
  def editable?(user)
    accessible?(user)
  end
  #
  #=== 削除できるか？
  # 運用管理者または、所属管理者
  #==== 戻り値
  # * true or false - true: 削除可, false: 削除不可
  def destroyable?(user)
    return false unless (user.admin? || self.section.manager?(user))
    return true
  end

  #
  #=== RDFに関するデータを持っているか？
  # 引き継ぎをしたらfalseになる
  #==== 戻り値
  # * boolean - true: 持っている, false: 持っていない
  def has_rdf_data?
    return self.template_records.exists?
  end

  #=== データ引き継ぎ機能を利用できるか？
  def inherit_data_accessible?(sec)
    return false unless (self.admin? || sec.manager?(self))
    return true
  end

  protected

    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

  private

    #
    #=== 所属を変更するときに、変更前の所属で参加しているグループから削除
    #
    def change_section_destroy_groups
      if self.section_id_changed?
        # 所属変更時
        ug_ids = UserGroup.where(section_id: self.section_id_was).pluck(:id)
        UserGroupsMember.where(user_id: self.id, group_id: ug_ids).destroy_all
      end
    end

    #
    #=== 所属変更のバリデーション
    def validates_change_section_id
      if self.section_id_changed?
        # 前の所属にデータがある場合、変更不可
        if self.has_rdf_data?
          errors.add(:section_id, I18n.t("user.errors.messages.can_not_change_section_because_it_has_data"))
        end
      end
    end
end
