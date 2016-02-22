require 'spec_helper'
include Warden::Test::Helpers
describe "Admin::RegularExpressions" do
  let(:user){create(:super_user)}
  let(:regular_expression){create(:regular_expression)}
  before do
    login_as user
    regular_expression
  end

  describe "正規表現マスタ一覧画面" do
    before do
      create_list(:regular_expression, 5, editable: false)
      create_list(:regular_expression, 6)
    end

    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit regular_expressions_path
        page.save_screenshot capture_path("admin/regular_expressions/index")
      end
    end
  end

  describe "正規表現マスタ作成画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit new_regular_expression_path
        page.save_screenshot capture_path("admin/regular_expressions/new")
      end
    end
  end

  describe "正規表現マスタ編集画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit edit_regular_expression_path(regular_expression.id)
        page.save_screenshot capture_path("admin/regular_expressions/edit")
      end
    end
  end

  describe "正規表現マスタ詳細表示画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit regular_expressions_path
        all(:xpath, "//a[@href='#{regular_expression_path(regular_expression)}']").first.click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot(capture_path("admin/regular_expressions/show"), width: 1440)
      end
    end
  end
end
