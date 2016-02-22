require 'spec_helper'
include Warden::Test::Helpers
describe "UserMaintenance::Sections::Users" do
  let(:section){create(:section)}
  let(:user){create(:section_manager_user, section_id: section.id)}
  let(:editor_user){create(:editor_user, section_id: section.id)}
  before do
    login_as user
    editor_user
  end

  describe "ユーザ一覧画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit section_users_path(section_id: section.id)
        page.save_screenshot capture_path("user_maintenance/sections/users/index"), width: 1440
      end
    end
  end

  describe "ユーザ詳細画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit section_users_path(section_id: section.id)
        all(:xpath, "//a[@href='#{section_user_path(editor_user, section_id: section.id)}']").first.click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("user_maintenance/sections/users/show"), width: 1440, height: 700
      end
    end
  end

  describe "ユーザ作成画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit new_section_user_path(section_id: section.id)
        page.save_screenshot capture_path("user_maintenance/sections/users/new"), width: 1440
      end
    end
  end

  describe "ユーザ編集画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit edit_section_user_path(user.id, section_id: section.id)
        page.save_screenshot capture_path("user_maintenance/sections/users/edit"), width: 1440
      end
    end
  end

  describe "ユーザ引き継ぎ機能画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit inherit_data_form_section_users_path(section_id: section.id)
        page.save_screenshot(capture_path("user_maintenance/sections/users/inherit_data_form"), width: 1440)
      end
    end
  end

  describe "パスワード変更画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit edit_password_section_users_path(section_id: section.id)
        page.save_screenshot(capture_path("user_maintenance/sections/users/edit_password"), width: 1440)
      end
    end
  end
end
