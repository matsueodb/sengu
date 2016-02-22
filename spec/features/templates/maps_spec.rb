require 'spec_helper'
include Warden::Test::Helpers
describe "Templates::Maps" do
  let(:section){create(:section)}
  let(:user){create(:super_user, section_id: section.id)}
  let(:service){create(:service, section_id: section.id)}
  let(:template){create(:template, user_id: user.id, service_id: service.id)}
  before do
    template
    login_as user
    create(:template, user_id: user.id)
    create(:template, user_id: user.id)
  end

  describe "地図表示画面" do
    let(:link_label){I18n.t("shared.show")}
    
    before do
      tr = build(:template_record, template_id: template.id)
      lon = create(:element_value_google_location_lon)
      lat = create(:element_value_google_location_lat)

      el = create(:element_by_it_google_location, display: true, template_id: template.id)
      ev1 = create(:element_value, content: lon, template_id: template.id, element_id: el.id, kind: 1)
      ev2 = create(:element_value, content: lat, template_id: template.id, element_id: el.id, kind: 2)
      tr.values << ev1
      tr.values << ev2
      tr.save!
    end
    
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit template_records_path(template_id: template.id)
        first(".map-modal-button").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        sleep(10)
        page.save_screenshot capture_path("templates/maps/display"), width: 1440, height: 700
      end
    end
  end
  
  describe "地図から位置情報検索画面" do
    before do
      [:shimane, :tottori, :okayama, :hiroshima, :yamaguchi].each do |k|
        create(:"pref_#{k}_with_city_and_address")
      end

      create(:tr_with_all_values, template_id: template.id)
      Element.update_all(template_id: template.id, display: true)
    end
    
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit new_template_record_path(template_id: template.id)
        first(".address_btn").click
        sleep(1)
        first(".map-search-modal-button").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        sleep(2)
        page.save_screenshot capture_path("templates/maps/display_search"), width: 1440
      end
    end
  end
end
