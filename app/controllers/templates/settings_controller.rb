#
#== データ入力設定機能
#
class Templates::SettingsController < ApplicationController
  include Concerns::TemplatesController
  before_action :template_operator_check

  #=== 登録内容確認設定
  #
  # GET /templates/1/settings/set_confirm_entries
  #
  # 「登録内容を確認する」ボタンを設置する項目を設定する画面
  #link:../captures/templates/settings/set_confirm_entries.png
  def set_confirm_entries
    @elements = @template.inputable_elements{|e|e.where(template_id: @template.id)}.select{|e|e.input_type.line?}.sort_by(&:id)
  end

  #
  #=== 登録内容確認設定処理
  #
  # POST /templates/1/settings/update_set_confirm_entries
  # 「登録内容を確認する」ボタンを設置する機能
  def update_set_confirm_entries
    begin
      Element.transaction do
        elements = @template.inputable_elements{|e|e.where(template_id: @template.id)}.select{|e|e.input_type.line?}.sort_by(&:id)
        element_ids = elements.map(&:id)
        not_selected_ids = element_ids - params[:element_ids].to_a
        Element.where("elements.id IN (?)", not_selected_ids).update_all(confirm_entry: false)
        Element.where("elements.id IN (?)", params[:element_ids].to_a).update_all(confirm_entry: true)
      end
    rescue
      return redirect_to(set_confirm_entries_template_settings_path(template_id: @template.id), alert: t(".failed"))
    end
    return redirect_to(set_confirm_entries_template_settings_path(template_id: @template.id), notice: t(".success"))
  end
end
