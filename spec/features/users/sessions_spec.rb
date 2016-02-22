require 'spec_helper'

describe "Users::Sessions" do
  describe "ログイン画面" do
    before do
      visit new_user_session_path
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("users/sessions/new")
    end
  end
end
