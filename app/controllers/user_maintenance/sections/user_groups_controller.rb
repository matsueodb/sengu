#
#== ユーザグループ管理
#
class UserMaintenance::Sections::UserGroupsController < UserMaintenance::Sections::ApplicationController
  SHOW_LIST_PER = 5
  before_action :set_user_group, only: [:show, :edit, :update, :destroy, :user_list, :template_list,
      :set_member, :update_set_member, :search_member, :destroy_member]

  # パンくず
  before_action :set_index_breadcrumbs, except: [:index]
  before_action :set_show_breadcrumbs, only: [:edit, :update, :set_member, :update_set_member, :user_list, :template_list]

  before_action :set_user_group_list, only: [:index, :new, :edit]
  
  before_action :accessible_check

  #=== ユーザグループ管理
  #
  # GET: /user_maintenance/sections/1/user_groups
  #
  # ユーザグループの一覧表示を行う画面
  #link:../captures/user_maintenance/sections/user_groups/index.png
  def index
  end

  #=== ユーザグループ詳細
  #
  # GET: /user_maintenance/sections/1/user_groups/1
  #
  # ユーザグループに登録されているユーザを
  # モーダルにて表示する画面
  #link:../captures/user_maintenance/sections/user_groups/show.png
  def show
    @users = @user_group.users.page(params[:page]).per(SHOW_LIST_PER).order("id")
    @templates = @user_group.templates.page(params[:page]).per(SHOW_LIST_PER).order("id")
  end

  #=== ユーザグループのメンバー一覧
  #
  # GET: /user_maintenance/sections/1/user_groups/1/user_list
  #
  # showにて表示されているメンバー一覧
  #link:../captures/user_maintenance/sections/user_groups/user_list.png
  def user_list
    @users = @user_group.users.order("id").page(params[:page])
  end

  #=== ユーザグループのテンプレート一覧
  #
  # GET: /user_maintenance/sections/1/user_groups/1/template_list
  #
  # showにて表示されているテンプレート一覧
  #link:../captures/user_maintenance/sections/user_groups/template_list.png
  def template_list
    @templates = @user_group.templates.page(params[:page])
  end

  #=== ユーザグループ作成
  #
  # GET: /user_maintenance/sections/1/user_groups/new
  #
  # ユーザグループの作成を行う画面
  #link:../captures/user_maintenance/sections/user_groups/new.png
  def new
    @user_group = UserGroup.new
  end

  #=== ユーザグループ作成処理
  #
  # POST: /user_maintenance/sections/1/user_groups
  #
  # ユーザグループの作成処理
  def create
    @user_group = UserGroup.new(user_group_params)
    @user_group.section_id = @section.id

    if @user_group.save
      return redirect_to section_user_group_path(@user_group, section_id: @section.id), notice: t("notices.create_after")
    else
      set_user_group_list
      render 'new'
    end
  end

  #=== ユーザグループ編集
  #
  # GET: /user_maintenance/sections/1/user_groups/1/edit
  #
  # ユーザグループの編集画面を表示する機能
  #link:../captures/user_maintenance/sections/user_groups/edit.png
  def edit
  end

  #=== ユーザグループ更新処理
  #
  # PATCH: /user_maintenance/sections/1/user_groups/1/
  #
  # ユーザグループの更新処理を行う機能
  def update
    @user_group.attributes = user_group_params

    if @user_group.save
      redirect_to section_user_group_path(@user_group, section_id: @section.id), notice: t("notices.update_after")
    else
      set_user_group_list
      render 'edit'
    end
  end

  #=== ユーザグループ削除処理
  #
  # DELETE: /user_maintenance/sections/1/user_groups/1/
  #
  # ユーザグループの削除を行う機能
  # テンプレートがある場合は削除できない
  def destroy
    if @user_group.destroyable?
      flash[:notice] = t(".success")
      @user_group.destroy
      return redirect_to section_user_groups_path(section_id: @section.id)
    else
      flash[:alert] = t(".failed")
      return redirect_to section_user_group_path(@user_group, section_id: @section.id)
    end
  end

  #=== ユーザグループ設定画面
  #
  # GET: /user_maintenance/sections/1/user_groups/1/set_member
  #
  # 作成したユーザグループに対してユーザメンバーを設定する画面
  #link:../captures/user_maintenance/sections/user_groups/set_member.png
  def set_member
    @users = @user_group.users
    @user_groups_member_search = UserGroupsMemberSearch.new(user_group_id: @user_group.id)
  end

  #=== ユーザグループ メンバー検索処理
  #
  # POST: /user_maintenance/sections/1/user_groups/1/search_member
  def search_member
    @user_groups_member_search = UserGroupsMemberSearch.new(user_groups_member_search_params.merge(user_group_id: @user_group.id))
  end


  #=== ユーザグループ設定画面
  #
  # POST: /user_maintenance/sections/1/user_groups/1/update_set_member
  #
  # 作成したユーザグループに対してユーザメンバーの設定処理をおこなう機能
  def update_set_member
    @user_groups_member_search = UserGroupsMemberSearch.new(user_groups_member_search_params)
    if @user_groups_member_search.valid?
      ugm = UserGroupsMember.new(group_id: @user_group.id, user_id: @user_groups_member_search.user.id)
      if ugm.valid?
        ugm.save
        return redirect_to(set_member_section_user_group_path(@user_group, section_id: @section.id), notice: t(".success"))
      end
    end
    # error
    return redirect_to(set_member_section_user_group_path(@user_group, section_id: @section.id), alert: t(".failed"))
  end

  #=== ユーザグループからユーザの削除
  #
  # DELETE: /user_maintenance/sections/1/user_groups/1/destroy_member
  #
  # グループに登録したユーザをグループから削除する機能
  def destroy_member
    ugm = @user_group.user_groups_members.find_by(user_id: params[:user_id])
    if ugm
      ugm.destroy
    end
    return redirect_to(user_list_section_user_group_path(@user_group, section_id: @section.id), notice: t(".success"))
  end

private

  #=== params[:id]から@user_groupをセット
  def set_user_group
    @user_group = @section.user_groups.find(params[:id])
  end

  #=== @user_groupsのセット
  def set_user_group_list
    @user_groups = @section.user_groups.page(params[:page]).order("id")
  end

  #=== アクセス制限チェック
  def accessible_check
    unless current_user.admin? || @section.manager?(current_user)
      return redirect_to section_path(@section.id), alert: t("alerts.can_not_access")
    end
  end

  #=== permit params[:user_group]
  def user_group_params
    params.require(:user_group).permit(:name)
  end

  #=== permit params[:user_groups_member_search]
  def user_groups_member_search_params
    params.require(:user_groups_member_search).permit(:login, :user_group_id)
  end

  #=== ユーザグループ一覧へのパンくず
  def set_index_breadcrumbs
    add_breadcrumb I18n.t("user_maintenance.sections.user_groups.index.title", section_name: @section.name), section_user_groups_path(section_id: @section.id)
  end

  #=== ユーザグループ詳細へのパンくず
  def set_show_breadcrumbs
    add_breadcrumb(
      I18n.t("user_maintenance.sections.user_groups.show.title", section_name: @section.name, group_name: @user_group.name),
      section_user_group_path(@user_group, section_id: @section.id)
    )
  end
end

