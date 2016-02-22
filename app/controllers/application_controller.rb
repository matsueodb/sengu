class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private

  #
  #=== 運用管理者以外の場合はトップページへリダイレクト
  #
  def admin_required
    unless user_signed_in? && current_user.admin?
      return redirect_to(root_path, alert: I18n.t("alerts.can_not_access"))
    end
  end

  #
  #=== 運用管理者、所属管理者以外はトップページへリダイレクト
  #
  def manager_required
    unless user_signed_in? && current_user.manager?
      return redirect_to(root_path, alert: I18n.t("alerts.can_not_access"))
    end
  end
end
