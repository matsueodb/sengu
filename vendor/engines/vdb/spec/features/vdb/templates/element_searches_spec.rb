require 'spec_helper'
# NOTE: 本テスト実行時に、以下のファイルが読み込まれていない状態だったので強制的に読みこませる
require File.join(Vdb::Engine.root, "lib/sengu/vdb/response")

describe "Vdb/Templates/ElementSearches" do
  let(:section){create(:section)}
  let(:user){create(:section_manager_user, section_id: section.id)}
  before { @user = login_user(user) }
  after { Warden.test_reset! }

  describe "項目追加（語彙データベース）画面検索" do
    let(:template){create(:template, service: create(:service, section_id: section.id))}
    before do
      InputType::TYPE_HUMAN_NAME.each do |k, v|
        create(:"input_type_#{k}")
      end
      # REF: spec/lib/sengu/response/element_item_spec.rb
      stub_const("Sengu::VDB::Response::ElementItem::LINE_TYPE", InputType.find_line)
      stub_const("Sengu::VDB::Response::ElementItem::VOCABULARY_TYPE", InputType.find_pulldown_vocabulary)
      create(:vocabulary_keyword,
        name: "人型",
        content: "人名 名前 住民",
        category: "人、住民",
        scope: 1,
        user_id: create(:super_user).id
      )
      visit vdb.new_template_element_path(template_id: template.id)
    end

    it "スクリーンショットの保存" do
      find("option[value='人、住民']").click
      first(".template-element-search-submit").click

      wait_until(0.5){ page.first("#result > div.well").try(:visible?) }

      page.save_screenshot capture_path("vdb/templates/element_searches/find"), width: 1440
    end
  end
end
