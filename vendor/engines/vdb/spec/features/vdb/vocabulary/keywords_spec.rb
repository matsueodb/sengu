require 'spec_helper'

describe "Vdb/Vocabularies/Keywords" do
  before { @user = login_user }
  after { Warden.test_reset! }

  before do
    create(:input_type_line)
    create(:input_type_multi_line)
    create(:input_type_dates)
    create(:input_type_google_location)
  end

  describe "語彙キーワード設定トップ画面" do
    before do
      create_list(:vocabulary_keyword, 5, user_id: @user.id)
      visit vdb.vocabulary_keywords_path
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("vdb/vocabulary/keywords/index"), width: 1440, height: 1280
    end
  end

  describe "語彙キーワード詳細画面" do
    before do
      create_list(:vocabulary_keyword, 5, user_id: @user.id)
      visit vdb.vocabulary_keywords_path
    end

    it "スクリーンショットの保存" do
      first(".show-vocabulary-keyword").click

      wait_until(0.5){ page.find("#vocabulary-keyword-show").visible? }
      page.save_screenshot capture_path("vdb/vocabulary/keywords/show"), width: 1440, height: 1280
    end
  end

  describe "語彙検索結果画面" do
    let(:submit) { I18n.t('shared.search') }

    before do
      create_list(:vocabulary_keyword, 5, user_id: @user.id)
      visit vdb.vocabulary_keywords_path
    end

    it "スクリーンショットの保存" do
      fill_in 'template_element_search_name',  with: "人型"
      click_button(I18n.t('shared.search'))

      wait_until(0.5){ page.find("#vdb-response").visible? }
      page.save_screenshot capture_path("vdb/vocabulary/keywords/search"), width: 1440, height: 1280
    end
  end

  describe "語彙キーワード編集画面" do
    let(:submit) { I18n.t('shared.search') }

    before do
      create_list(:vocabulary_keyword, 5, user_id: @user.id)
      visit vdb.vocabulary_keywords_path
    end

    it "スクリーンショットの保存" do
      first(".edit-vocabulary-keyword").click

      wait_until(0.5){ page.find("#vocabulary-keyword-configure").visible? }
      page.save_screenshot capture_path("vdb/vocabulary/keywords/configure"), width: 1440, height: 1280
    end
  end
end
