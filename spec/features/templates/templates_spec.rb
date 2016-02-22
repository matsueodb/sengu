require 'spec_helper'
include Warden::Test::Helpers
describe "Templates::Templates" do
  let(:section){create(:section)}
  let(:service){create(:service, section_id: section.id)}
  let(:user){create(:super_user, section_id: section.id)}
  let(:template){create(:template, user_id: user.id, service_id: service.id)}
  before do
    template
    login_as user
    create(:template, user_id: user.id)
    create(:template, user_id: user.id)
  end

  describe "テンプレート作成画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit new_template_path(service_id: service.id)
        page.save_screenshot capture_path("templates/templates/new"), width: 1440
      end
    end

    context "拡張テンプレートの作成の場合" do
      it "スクリーンショットの保存" do
        visit new_template_path(parent_id: template.id)
        page.save_screenshot capture_path("templates/templates/new2"), width: 1440
      end
    end
  end

  describe "テンプレート編集画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit edit_template_path(template.id)
        page.save_screenshot capture_path("templates/templates/edit"), width: 1440
      end
    end
  end

  describe "拡張時のデータ選択" do
    let(:child){create(:template, parent_id: template.id, service_id: service.id)}
    let(:line){create(:element_by_it_line, template_id: template.id)}
    let(:ev){create(:vocabulary_element_with_values)}
    let(:temp_source){create(:template, service_id: service.id)}
    let(:source_el){create(:element_by_it_line, template_id: temp_source.id)}
    
    before do
      line
      create(:element_by_it_multi_line, template_id: template.id)
      create(:element_by_it_dates, template_id: template.id)
      create(:element_by_it_times, template_id: template.id)

      %w(松江城 県立美術館 小泉八雲記念館).each do |name|
        create(:element_value,
          record_id: create(:template_record, template_id: temp_source.id).id,
          template_id: temp_source.id,
          element_id: source_el.id,
          content: create(:element_value_line, value: name))
      end

      [:checkbox_template, :pulldown_template].each do |key|
        [0, Element::DATA_INPUT_WAY_POPUP].each do |way|
          create(:"element_by_it_#{key}", template_id: template.id, source: temp_source, source_element_id: source_el.id, data_input_way: way)
        end
      end
      [:checkbox_vocabulary, :pulldown_vocabulary].each do |key|
        [0, Element::DATA_INPUT_WAY_POPUP].each do |way|
          create(:"element_by_it_#{key}", template_id: template.id, source: ev, data_input_way: way)
        end
      end
    end
    
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit data_select_upon_extension_form_template_path(child.id)
        page.save_screenshot capture_path("templates/templates/data_select_upon_extension_form"), width: 1440
      end
    end

    context "プレビュー" do
      before do
        tr = create(:template_record, template_id: template.id)
        c = create(:element_value_line, value: "松江城")
        create(:element_value, template_id: template.id, element_id: line.id, record_id: tr.id, content: c)
      end
      
      it "スクリーンショットの保存" do
        visit data_select_upon_extension_form_template_path(child.id)
        first(".select_data_upon_extension_preview-btn").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/templates/data_select_upon_extension_preview"), width: 1440
      end
    end
  end

  describe "拡張時のデータ選択 関連データの検索ポップアップ画面" do
    let(:child){create(:template, parent_id: template.id, service_id: service.id)}
    let(:ve){create(:vocabulary_element)}
    let(:el){create(:element_by_it_checkbox_vocabulary, template: template, source: ve, data_input_way: Element::DATA_INPUT_WAY_POPUP)}

    before do
      child
      el
    end
    
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit data_select_upon_extension_form_template_path(child.id)
        first("#element#{el.id}_search_btn").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/templates/element_relation_search_form"), width: 1440
      end
    end
  end

  describe "拡張時のデータ選択 関連データの検索ポップアップ画面検索後" do
    let(:child){create(:template, parent_id: template.id, service_id: service.id)}
    let(:ve){create(:vocabulary_element_with_values)}
    let(:el){create(:element_by_it_checkbox_vocabulary, template: template, source: ve, data_input_way: Element::DATA_INPUT_WAY_POPUP)}

    before do
      child
      el
    end

    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit data_select_upon_extension_form_template_path(child.id)
        first("#element#{el.id}_search_btn").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        first("#element-relation-content-search-result_btn").click
        wait_until(0.5){ page.find(".list-group").visible? }
        page.save_screenshot capture_path("templates/templates/element_relation_search"), width: 1440
      end
    end
  end

  describe "テンプレートの並び替え画面" do
    before do
      create_list(:template, 5, service_id: service.id)
    end
    
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit change_order_form_templates_path(service_id: service.id)
        page.save_screenshot capture_path("templates/templates/change_order_form")
      end
    end

  end
end
