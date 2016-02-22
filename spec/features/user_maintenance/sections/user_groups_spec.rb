require 'spec_helper'
include Warden::Test::Helpers
describe "UserMaintenance::Sections::UserGroups" do
  let(:section){create(:section)}
  let(:user){create(:section_manager_user, section: section)}
  let(:user_group){create(:user_group, section_id: section.id)}
  
  before do
    login_as user
    13.times{create(:user_group, section_id: section.id).users << user}
  end

  describe "ユーザグループ一覧画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit section_user_groups_path(section_id: section.id)
        page.save_screenshot capture_path("user_maintenance/sections/user_groups/index"), width: 1440
      end
    end
  end

  describe "ユーザグループ作成画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit new_section_user_group_path(section_id: section.id)
        page.save_screenshot capture_path("user_maintenance/sections/user_groups/new"), width: 1440
      end
    end
  end

  describe "ユーザグループのユーザ一覧画面" do
    before do
      13.times{user_group.users << create(:editor_user, section_id: section.id)}
    end
    
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit user_list_section_user_group_path(user_group.id, section_id: section.id)
        page.save_screenshot capture_path("user_maintenance/sections/user_groups/user_list"), width: 1440
      end
    end
  end

  describe "ユーザグループのテンプレート一覧画面" do
    before do
      13.times{create(:template, user_group_id: user_group.id)}
    end

    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit template_list_section_user_group_path(user_group.id, section_id: section.id)
        page.save_screenshot capture_path("user_maintenance/sections/user_groups/template_list"), width: 1440
      end
    end
  end
  
  describe "ユーザグループ編集画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit edit_section_user_group_path(user_group.id, section_id: section.id)
        page.save_screenshot capture_path("user_maintenance/sections/user_groups/edit"), width: 1440
      end
    end
  end

  describe "ユーザグループ詳細表示画面" do
    before do
      13.times do
        user_group.users << create(:editor_user, section_id: section.id)
        create(:template, user_group_id: user_group.id)
      end
    end
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit section_user_group_path(user_group.id, section_id: section.id)
        page.save_screenshot(capture_path("user_maintenance/sections/user_groups/show"), width: 1440)
      end
    end
  end

  describe "ユーザグループメンバー設定画面" do
    let(:login){create(:editor_user, section_id: create(:section).id).login}

    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit set_member_section_user_group_path(user_group, section_id: section.id)
        page.save_screenshot(capture_path("user_maintenance/sections/user_groups/set_member"), width: 1440)
      end
    end

    context "検索後の場合" do
      it "スクリーンショットの保存" do
        visit set_member_section_user_group_path(user_group, section_id: section.id)

        fill_in("login_form", with: login)
        first(".btn-success").click

        wait_until(0.5){ page.find("#new_user_groups_member_search").visible? }

        page.save_screenshot(capture_path("user_maintenance/sections/user_groups/set_member2"), width: 1440)
      end
    end
  end
end
