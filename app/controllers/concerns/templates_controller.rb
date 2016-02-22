
#
#== Template::templateに関する共通の処理をまとめるコントローラ
#
module Concerns::TemplatesController
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_template
    before_action :template_accessible_check

    add_breadcrumb "I18n.t('shared.top')", "main_app.root_path(id: @template.try(:service_id))", eval: true
  end

private

  #
  #=== params[:template_id]から@templateをセットする。
  #
  def set_template
    @template = Template.find(params[:template_id])
  end

  #
  #=== ログインユーザが@templateがアクセスできるデータ
  #
  def template_accessible_check
    unless @template.data_register?(current_user)
      return redirect_to(main_app.services_path, alert: I18n.t("alerts.can_not_access"))
    end
  end

  #
  #=== ログインユーザが管理者または所属管理者で、@templateのサービスの所属に属するかのチェック
  #
  def template_operator_check
    unless @template.operator?(current_user)
      return redirect_to(main_app.services_path, alert: I18n.t("alerts.can_not_access"))
    end
  end
end
