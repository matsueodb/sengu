#
#== 管理機能共通コントローラ
#
module Concerns::AdminController
  extend ActiveSupport::Concern

  included do
    add_breadcrumb "I18n.t('shared.top')", "main_app.root_path", eval: true
    before_action :authenticate_user!
    before_action :admin_required
  end
end
