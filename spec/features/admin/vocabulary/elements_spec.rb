require 'spec_helper'

describe "Vocabularies" do
  before { @user = login_user }
  after { Warden.test_reset! }

  describe "語彙データ検索・一覧表示画面" do
    before do
      create_list(:vocabulary_element_with_values, 5, description: 'ランドマークのリストです')
      visit vocabulary_elements_path
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("admin/vocabulary/elements/index"), width: 1440
    end
  end

  describe "語彙データ基本設定画面" do
    before do
      visit new_vocabulary_element_path
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("admin/vocabulary/elements/new"), width: 1440
    end
  end

  describe "語彙データ編集画面" do
    before do
      v_e = create(:vocabulary_element_with_values, description: 'ランドマークのリストです')
      visit edit_vocabulary_element_path(v_e)
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("admin/vocabulary/elements/edit"), width: 1440
    end
  end

  describe "語彙データ検索・詳細表示画面" do
    before do
      @el = create(:vocabulary_element_with_values)
      visit vocabulary_element_path(@el)
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("admin/vocabulary/elements/show"), width: 1440
    end
  end
end

