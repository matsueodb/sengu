#
#== ユーザメンテナンスの親コントローラ
#
class UserMaintenance::ApplicationController < ApplicationController
  add_breadcrumb I18n.t("shared.top"), :root
  before_action :authenticate_user!
end
