#
#== ユーザグループに登録するユーザを選択する画面
#
class UserGroupsMemberSearch
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :user_group, :user, :login, :user_group_id

  validates :login, presence: true
  validate :validate_user
  
  before_validation :set_user_from_login, :set_user_group_from_user_group_id

  # ユーザが登録済み？
  def user_registered?
    if @user_registered.blank?
      if self.user_group.user_groups_members.where(user_id: self.user.id).exists?
        @user_registered = "true"
      else
        @user_registered = "false"
      end
    end

    return @user_registered == "true"
  end

  private

    # self.loginからユーザを検索
    def set_user_from_login
      self.user = User.find_by(login: self.login) if self.login
    end

    # self.user_group_idからUserGroupをセット
    def set_user_group_from_user_group_id
      self.user_group = UserGroup.find(self.user_group_id) if self.user_group_id
    end

    # self.userの検証
    def validate_user
      if self.user.blank?
        # loginに該当するユーザがいない場合
        errors.add(:user, I18n.t("activemodel.errors.user_groups_member_search.user.blank")) if self.login.present?
      else
        if self.user_group.try(:section_id) == self.user.section_id
          errors.add(:user, I18n.t("activemodel.errors.user_groups_member_search.login.same_section"))
        end
      end
    end
end
