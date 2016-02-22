#
#== 所属管理機能
#
class UserMaintenance::SectionsController < UserMaintenance::ApplicationController
  SHOW_LIST_PER = 5
  before_action :authenticate_user!
  before_action :set_section, only: [:show, :edit, :update, :destroy]
  before_action :creatable_check, only: [:new, :create]
  before_action :editable_check, only: [:edit, :update]
  before_action :displayable_check, only: [:show]
  before_action :destroyable_check, only: [:destroy]

  add_breadcrumb I18n.t("user_maintenance.sections.index.title"), :sections, except: [:index]

  #=== 所属一覧
  #
  # GET /user_maintenance/sections/
  #
  # 全ての所属を一覧表示する画面
  #link:../captures/user_maintenance/sections/index.png
  def index
    if current_user.admin?
      @sections = Section.page(params[:page]).order("id")
    else
      # 管理者以外は詳細画面を表示
      @section = current_user.section
      show
      return render "show"
    end
  end

  #=== 所属詳細
  #
  # GET /user_maintenance/sections/1
  #
  # 選択した所属に登録されているユーザを表示
  #link:../captures/user_maintenance/sections/show.png
  def show
    @users = @section.users.page(params[:user_page]).per(SHOW_LIST_PER).order("id")
    @user_groups = @section.user_groups.includes(:user_groups_members).page(params[:group_page]).per(SHOW_LIST_PER)
  end

  #=== 所属作成画面
  #
  # GET /user_maintenance/sections/new
  #
  # 所属を作成する画面
  #link:../captures/user_maintenance/sections/new.png
  def new
    @section = Section.new
  end

  #=== 所属作成処理
  #
  # POST /user_maintenance/sections/
  #
  # 所属の作成処理
  def create
    @section = Section.new(section_params)
    if @section.save
      return redirect_to section_path(@section), notice: t("notices.create_after")
    else
      render "new"
    end
  end

  #=== 所属編集画面
  #
  # GET /user_maintenance/sections/1/edit
  #
  # 選択した所属を編集する画面
  #link:../captures/user_maintenance/sections/edit.png
  def edit
  end

  #=== 所属更新処理
  #
  # PATCH /user_maintenance/sections/1
  #
  # 所属の更新処理
  def update
    if @section.update(section_params)
      return redirect_to section_path(@section), notice: t("notices.update_after")
    else
      render "edit"
    end
  end

  #=== 所属削除
  #
  # DELETE /user_maintenance/sections/1
  #
  # 所属の削除処理
  def destroy
    unless @section.destroyable?
      return redirect_to sections_path, alert: t(".can_not_destroy")
    end
    @section.destroy
    return redirect_to sections_path, notice: t("notices.destroy_after")
  end

  private

  #
  #=== params[:id]から@sectionをセット
  #
  def set_section
    @section = Section.find(params[:id])
  end

  #
  #=== permit params[:section]
  #
  def section_params
    params.require(:section).permit(:name, :copyright)
  end

  #
  #=== 作成権限があるか？
  def creatable_check
    unless current_user.admin?
      return redirect_to sections_path, alert: I18n.t("alerts.can_not_create")
    end
  end

  #
  #=== 更新権限があるか？
  def editable_check
    if !current_user.admin? && !@section.manager?(current_user)
      return redirect_to sections_path, alert: I18n.t("alerts.can_not_edit")
    end
  end

  #
  #=== 閲覧できるか？
  def displayable_check
    unless @section.displayable?(current_user)
      return redirect_to sections_path, alert: I18n.t("alerts.can_not_access")
    end
  end

  #
  #=== 削除できるか？
  def destroyable_check
    unless current_user.admin?
      return redirect_to sections_path, alert: I18n.t("alerts.can_not_destroy")
    end
  end
end
