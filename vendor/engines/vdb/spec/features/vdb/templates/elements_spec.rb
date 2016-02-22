require 'spec_helper'

describe "Vdb/Templates/Elements" do
  let(:section){create(:section)}
  let(:user){create(:section_manager_user, section_id: section.id)}
  before { @user = login_user(user) }
  after { Warden.test_reset! }

  describe "項目追加（語彙データベース）画面" do
    let(:template){create(:template, service: create(:service, section_id: section.id))}
    before do
      visit vdb.new_template_element_path(template_id: template.id)
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("vdb/templates/elements/new"), width: 1440
    end
  end
end
