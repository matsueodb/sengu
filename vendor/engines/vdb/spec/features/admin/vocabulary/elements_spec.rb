require 'spec_helper'

describe "Admin/Vocabulary/Elements" do
  before { @user = login_user }
  after { Warden.test_reset! }

  describe "語彙データベース検索結果画面", js: true do
    let(:submit) { I18n.t('shared.search') }

    before do
      create(:input_type_line)
      create(:input_type_multi_line)
      create(:input_type_dates)
      create(:input_type_google_location)
      visit vocabulary_elements_path
    end

    it "スクリーンショットの保存" do
      fill_in 'vocabulary_search_name',  with: '曜日'
      click_button submit

      wait_until(0.5){ page.find("#search-result").visible? }
      page.save_screenshot capture_path("admin/vocabulary/elements/search"), width: 1440, height: 1280
    end
  end
end
