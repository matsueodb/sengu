require 'spec_helper'

describe "Templates::Elements" do
  let(:user){create(:super_user)}
  let(:service){create(:service, section_id: user.section_id)}
  let(:template){create(:template_with_elements, user_id: user.id, service_id: service.id)}
  before { login_as user }
  after { Warden.test_reset! }

  describe "RDFテンプレート作成画面" do
    before do
      visit new_template_element_path(template_id: template.id)
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("templates/elements/new"), width: 1440
    end
  end

  describe "項目編集画面" do
    let(:element){template.elements.first}
    it "スクリーンショットの保存" do
      visit edit_template_element_path(element.id, template_id: template.id)
      page.save_screenshot capture_path("templates/elements/edit"), width: 1440
    end

    context "ネームスペース項目の編集" do
      it "スクリーンショットの保存" do
        create(:element_by_it_line, template_id: template.id, parent_id: element.id)
        visit edit_template_element_path(element.id, template_id: template.id)
        page.save_screenshot capture_path("templates/elements/edit2"), width: 1440
      end
    end
  end

  describe "RDF要素詳細画面" do
    before do
      visit show_elements_template_elements_path(template_id: template.id)
    end

    it "スクリーンショットの保存" do
      first(".show-link").click

      wait_until(0.5){ page.find("#element-show").visible? }
      page.save_screenshot capture_path("templates/elements/show"), width: 1440, height: 1280
    end
  end

  describe "項目一覧画面" do
    before do
      create(:element_by_it_line, template_id: template.id, parent_id: create(:element_by_it_line, template_id: template.id).id)
    end

    it "スクリーンショットの保存" do
      visit show_elements_template_elements_path(template_id: template.id)

      page.save_screenshot capture_path("templates/elements/show_elements"), width: 1440
    end
  end

  describe "項目並び替え機能" do
    it "スクリーンショットの保存" do
      visit show_elements_template_elements_path(template_id: template.id)

      all(:xpath, "//a[@href='#{template_elements_path(template_id: template.id)}']").first.click

      wait_until(0.5){ page.find("#element-show").visible? }
      page.save_screenshot capture_path("templates/elements/change_order"), width: 1440
    end

    it "子項目の詳細ボタン押下時のスクリーンショットの保存" do
      el = template.elements.last
      create_list(:element_by_it_line, 3, template_id: template.id, parent_id: el.id)
      visit show_elements_template_elements_path(template_id: template.id)

      all(:xpath, "//a[@href='#{template_elements_path(id: el.id, template_id: template.id)}']").last.click

      wait_until(0.5){ page.find("#element-show").visible? }
      page.save_screenshot capture_path("templates/elements/change_order2"), width: 1440
    end
  end

  describe "入力プレビュー" do
    it "スクリーンショットの保存" do
      visit show_elements_template_elements_path(template_id: template.id)

      all(:xpath, "//a[@href='#{sample_field_template_records_path(template_id: template.id)}']").first.click

      wait_until(0.5){ page.find(".modal-header").visible? }
      page.save_screenshot capture_path("templates/elements/sample_field"), width: 1440
    end
  end

  describe "項目一括設定画面" do
    before do
      template.elements << create(:only_element, template_id: template.id)
    end

    it "スクリーンショットの保存" do
      visit edit_settings_template_elements_path(template_id: template.id)
      page.save_screenshot capture_path("templates/elements/edit_settings"), width: 1440
    end
  end
end

