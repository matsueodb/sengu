require 'spec_helper'
include Warden::Test::Helpers
describe "Templates::Settings" do
  let(:section){create(:section)}
  let(:service){create(:service, section_id: section.id)}
  let(:user){create(:super_user, section_id: section.id)}
  let(:template){create(:template, user_id: user.id, service_id: service.id)}
  before do
    login_as user
    create(:tr_with_all_values, template_id: template.id)
    Element.update_all(template_id: template.id)
  end


  describe "登録内容確認設定" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit set_confirm_entries_template_settings_path(template_id: template.id)
        page.save_screenshot capture_path("templates/settings/set_confirm_entries"), width: 1440
      end
    end
  end
end

