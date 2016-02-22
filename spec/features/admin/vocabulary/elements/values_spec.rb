require 'spec_helper'

describe "Vocabularies/Elements/Values" do
  before { login_user }
  after { Warden.test_reset! }

  before do
    @element = create(:vocabulary_element_with_values)
  end

  describe "語彙データ内容設定・追加画面" do
    before do
      visit new_vocabulary_element_value_path(@element)
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("admin/vocabulary/elements/values/new"), width: 1440
    end
  end

  describe "語彙データ内容設定・編集画面" do
    before do
      visit edit_vocabulary_element_value_path(@element, @element.values.first)
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("admin/vocabulary/elements/values/edit"), width: 1440
    end
  end
end

