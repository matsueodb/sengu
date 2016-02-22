#
#== ユーザ管理
#
class UserMaintenance::Sections::UsersController < UserMaintenance::Sections::ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_index_breadcrumbs, except: [:index]
  before_action :set_user_list, only: [:index, :new, :edit]
  before_action :set_form_assigns, only: [:new, :edit]
  before_action :creatable_check, only: [:new, :create]
  before_action :accessible_check, only: [:show, :edit, :update]
  before_action :destroyable_check, only: [:destroy]
  before_action :inherit_data_accessible_check, only: [:inherit_data, :inherit_data_form]

  #=== ユーザ一覧
  #
  # GET /sections/1/users/
  #
  # 登録されているユーザの一覧を表示する画面
  #link:../captures/user_maintenance/sections/users/index.png
  def index
    # indexのアクセス制限はUserMaintenance::Sections::ApplicationControllerでかかる内容のみ
    if request.xhr?
      render partial: "list", locals: {users: @users}
    end
  end

  #=== ユーザ詳細 Ajax
  #
  # GET /sections/1/users/1
  #
  # ユーザの詳細表示モーダル画面
  #link:../captures/user_maintenance/sections/users/show.png
  def show
  end

  #=== ユーザ作成画面
  #
  # GET /sections/1/users/new
  #
  # ユーザの新規登録画面
  #link:../captures/user_maintenance/sections/users/new.png
  def new
    @user = User.new(authority: User.authorities[:editor], section_id: @section.id)
  end

  #=== ユーザ作成処理
  #
  # POST /sections/1/users/
  #
  # ユーザの登録処理を行う機能
  def create
    @user = User.new
    @user.attributes = user_params
    unless current_user.admin?
      # ログインユーザが管理者以外のユーザは所属は現在の所属
      @user.section_id = @section.id
      if current_user.section_manager? # 所属管理者
        # 管理者は選べない（本来、画面からは選べない）
        @user.authority = User.authorities[:section_manager] if @user.authority == User.authorities[:admin]
      end
    end

    if @user.save
      return redirect_to section_users_path(section_id: @section.id), notice: t("devise.users.user.signed_up")
    else
      set_user_list
      set_form_assigns
      return render "new"
    end
  end

  #=== ユーザ編集画面
  #
  # GET /sections/1/users/1/edit
  #
  # ユーザの編集画面
  #link:../captures/user_maintenance/sections/users/edit.png
  def edit
  end

  #=== ユーザ更新処理
  #
  # PATCH /sections/1/users/1/
  #
  # ユーザの更新を行う機能
  def update
    begin
      ActiveRecord::Base.transaction do
        @user.update_with_password!(user_params, current_user)
        if @user.id == current_user.id
          # パスワード変更時にログアウトされるため
          sign_in(@user, bypass: true)
        end
        return redirect_to section_users_path(section_id: @section.id), notice: t("devise.users.user.updated")
      end
    rescue
      set_form_assigns
      set_user_list
      return render "edit"
    end
  end

  #=== ユーザ削除処理
  #
  # DELETE /sections/1/users/1/
  #
  # ユーザの削除を行う機能
  def destroy
    current_id = current_user.id
    if @user.has_rdf_data?
      return redirect_to section_users_path(section_id: @section.id), alert: t(".failed_has_rdf_data")
    end
    @user.destroy
    flash[:notice] = t(".complete")

    if current_id != params[:id].to_i
      return redirect_to(section_users_path(section_id: @section.id))
    else
      return redirect_to new_user_session_path
    end
  end

  #=== ユーザデータの引き継ぎ画面
  #
  # GET /sections/1/users/inherit_data_form
  #
  # ユーザが登録したオープンデータ情報を他のユーザに引き継ぐ画面
  #link:../captures/user_maintenance/sections/users/inherit_data_form.png
  def inherit_data_form
    @users = @section.users.order("id")
  end

  #
  #=== データの引き継ぎ処理
  #
  # POST /sections/1/users/inherit_data
  #
  # ユーザが登録したオープンデータ情報を他のユーザに引き継ぐ処理を行う機能
  def inherit_data
    if params[:from_id] == params[:to_id]
      @error_message = t(".the_same_user_has_been_set")
      inherit_data_form
      return render "inherit_data_form"
    end

    @user_from = User.find(params[:from_id])
    @user_to = User.find(params[:to_id])

    unless (@user_from.section_id == @section.id && @user_to.section_id == @section.id)
      return redirect_to(inherit_data_form_section_users_path(section_id: @section.id), alert: t(".invalid_parameter"))
    end

    begin
      ActiveRecord::Base.transaction do
        @user_from.inherit_data(@user_to)
        return redirect_to section_users_path(section_id: @section.id), notice: t(".complete")
      end
    rescue => e
      return redirect_to section_users_path(section_id: @section.id), alert: t(".failed")
    end
  end

  #
  #=== パスワード編集画面
  #
  # GET /sections/1/users/edit_password
  #
  # ログインユーザのパスワードを変更する画面
  #link:../captures/user_maintenance/sections/users/edit_password.png
  def edit_password
  end

  #
  #=== パスワード更新
  #
  # PATCH /sections/1/users/update_password
  def update_password
    if current_user.update(update_password_params)
      sign_in(current_user, bypass: true)
      return redirect_to(section_users_path(section_id: @section.id), notice: t(".success"))
    else
      render "edit_password"
    end
  end

private

  #=== params[:id]から@userをセット
  def set_user
    @user = @section.users.find(params[:id])
  end

  #=== @usersのセット
  def set_user_list
    @users = @section.users.page(params[:page]).includes(:section).order("id")
  end

  #=== permit params[:user]
  def user_params
    base_keys = [:name, :password, :password_confirmation, :remarks, :authority, :copyright]
    base_keys << :login if @user.new_record?
    if current_user.admin? # mass assignment
      # 管理者のときに権限を変更できるように
      base_keys << :section_id
    end
    params.require(:user).permit(base_keys)
  end

  #=== permit params[:user]
  def update_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  #=== フォームで使用するインスタンス変数のセット
  def set_form_assigns
    @sections = Section.all
  end

  #=== パンくずのセット
  def set_index_breadcrumbs
    add_breadcrumb I18n.t("user_maintenance.sections.users.index.title", section_name: @section.name), section_users_path(section_id: @section.id)
  end

  #=== アクセス出来るか
  def accessible_check
    unless @user.accessible?(current_user)
      return redirect_to section_users_path(section_id: @section.id), alert: t("alerts.can_not_access")
    end
  end

  #=== 削除できるか？
  def destroyable_check
    unless @user.destroyable?(current_user)
      return redirect_to section_users_path(section_id: @section.id), alert: t("alerts.can_not_access")
    end
  end

  #=== データ引き継ぎ機能を利用出来るか？
  def inherit_data_accessible_check
    unless current_user.inherit_data_accessible?(@section)
      return redirect_to section_users_path(section_id: @section.id), alert: t("alerts.can_not_access")
    end
  end

  #=== ログインユーザがユーザの作成権限をもっているか？
  def creatable_check
    unless @section.addable_user?(current_user)
      return redirect_to sections_path, alert: I18n.t("alerts.can_not_create")
    end
  end
end
