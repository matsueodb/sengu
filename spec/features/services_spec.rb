require 'spec_helper'

describe "Service" do
  before { @user = login_user }
  after { Warden.test_reset! }

  describe "サービス一覧画面" do
    before do
      services = create_list(:service, 10, section_id: @user.section_id)
      create_list(:template, 11, user: @user, service: services.first)
      visit services_path
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("services/index"), width: 1440, height: 1280
    end
  end

  describe "サービス詳細画面" do
    before do
      services = create_list(:service, 10, section_id: @user.section_id)
      create_list(:template, 11, user: @user, service: services.first)
      visit services_path
      first(".service-name").click
      wait_until(0.5){ page.find("#service-info").visible? }
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("services/show"), width: 1440, height: 1280
    end
  end

  describe "サービス作成画面" do
    before do
      visit new_service_path
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("services/new")
    end
  end

  describe "サービス編集画面" do
    let(:service) { create(:service, section_id: @user.section_id) }

    before do
      visit edit_service_path(service)
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("services/edit")
    end
  end
end
