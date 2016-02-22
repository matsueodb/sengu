#
#== ユーザメンテナンスの所属以下親コントローラ
#
class UserMaintenance::Sections::ApplicationController < UserMaintenance::ApplicationController
  before_action :set_section
  before_action :section_accessible_check
  before_action :set_breadcrumbs

private

  #
  #=== params[:section_id]から@sectionをセットする。
  #
  def set_section
    @section = Section.find(params[:section_id])
  end

  #
  #=== ログインユーザが@sectionがアクセスできるデータ
  #
  def section_accessible_check
    unless @section.displayable?(current_user)
      return redirect_to(root_path, alert: I18n.t("alerts.can_not_access"))
    end
  end

  #
  #=== 所属詳細、所属一覧へのパンくず設定
  #
  def set_breadcrumbs
    add_breadcrumb I18n.t("user_maintenance.sections.index.title"), sections_path
    add_breadcrumb I18n.t("user_maintenance.sections.show.title", section_name: @section.name), section_path(@section.id)
  end
end
