require 'spec_helper'
include Warden::Test::Helpers
describe "UserMaintenance::Sections" do
  let(:section){create(:section)}
  let(:user){create(:super_user)}
  
  before do
    login_as user
  end

  describe "所属一覧画面" do
    before do
      10.times do
        create(:section)
      end
    end

    context "運用管理者の場合" do
      it "スクリーンショットの保存" do
        visit sections_path
        page.save_screenshot capture_path("user_maintenance/sections/index"), width: 1440
      end
    end

    context "運用管理者以外の場合" do
      it "スクリーンショットの保存" do
        login_as create(:section_manager_user)
        visit sections_path
        page.save_screenshot capture_path("user_maintenance/sections/index2"), width: 1440
      end
    end
  end

  describe "所属詳細画面" do
    before do
      10.times do
        create(:editor_user, section_id: section.id)
        create(:user_group, section_id: section.id)
      end
    end

    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit section_path(section.id)
        page.save_screenshot capture_path("user_maintenance/sections/show"), width: 1440
      end
    end

    context "ログインユーザがデータ登録者の場合" do
      it "スクリーンショットの保存" do
        login_as create(:editor_user, section_id: section.id)
        visit section_path(section.id)
        page.save_screenshot capture_path("user_maintenance/sections/show2"), width: 1440
      end
    end
  end

  describe "ユーザ作成画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit new_section_path
        page.save_screenshot capture_path("user_maintenance/sections/new"), width: 1440
      end
    end
  end

  describe "ユーザ編集画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit edit_section_path(section.id)
        page.save_screenshot capture_path("user_maintenance/sections/edit"), width: 1440
      end
    end
  end
end
