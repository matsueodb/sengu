require 'spec_helper'
include Warden::Test::Helpers
describe "Templates::Records" do
  let(:section){create(:section)}
  let(:user){create(:super_user, section_id: section.id)}
  let(:service){create(:service, section_id: section.id)}
  let(:template){create(:template, user_id: user.id, service_id: service.id)}
  let(:tr){create(:tr_with_all_values, template_id: template.id)}

  before do
    login_as user
    [:shimane, :tottori, :okayama, :hiroshima, :yamaguchi].each do |k|
      create(:"pref_#{k}_with_city_and_address")
    end
  end

  describe "入力データ一覧画面" do
    before do
      tr # let call
    end

    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        create(:tr_with_all_values, template_id: template.id)
        visit template_records_path(template_id: template.id)
        page.save_screenshot capture_path("templates/records/index")
      end
    end
  end

  describe "入力データ作成画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        tr # let call
        visit new_template_record_path(template_id: template.id)
        page.save_screenshot capture_path("templates/records/new"), width: 1440
      end
    end

    context "繰り返しの入力" do
      before do
        el = create(:element_by_it_line, template_id: template.id, name: "施設型", multiple_input: true)
        create(:element_by_it_line, template_id: template.id, name: "施設名", parent_id: el.id)
        visit new_template_record_path(template_id: template.id)
      end

      it "スクリーンショットの保存" do
        page.save_screenshot capture_path("templates/records/forms/multiple_input"), width: 1440
      end

      it "フォームを増やした場合の画面のスクリーンショットの保存" do
        first(".add-namespace-form-button").click
        sleep(0.5)
        page.save_screenshot capture_path("templates/records/forms/multiple_input2"), width: 1440
      end
    end

    it "１行入力項目のフォームのスクリーンショットの保存" do
      create(:element_by_it_line, template_id: template.id, name: "施設名", confirm_entry: true)
      visit new_template_record_path(template_id: template.id)
      page.save_screenshot capture_path("templates/records/forms/line"), width: 1440
    end

    it "複数行入力項目のフォームのスクリーンショットの保存" do
      create(:element_by_it_multi_line, template_id: template.id, name: "説明")
      visit new_template_record_path(template_id: template.id)
      page.save_screenshot capture_path("templates/records/forms/multi_line"), width: 1440
    end

    it "日付入力項目のフォームのスクリーンショットの保存" do
      create(:element_by_it_dates, template_id: template.id, name: "イベント日")
      visit new_template_record_path(template_id: template.id)
      page.execute_script('$(".input_datepicker").datepicker("show")')
      wait_until(0.5){ page.find("#ui-datepicker-div").visible? }
      page.save_screenshot capture_path("templates/records/forms/dates"), width: 1440
    end

    it "時間入力項目のフォームのスクリーンショットの保存" do
      create(:element_by_it_times, template_id: template.id, name: "開館時間")
      visit new_template_record_path(template_id: template.id)
      page.save_screenshot capture_path("templates/records/forms/times"), width: 1440
    end

    it "ファイル項目のフォームのスクリーンショットの保存" do
      create(:element_by_it_upload_file, template_id: template.id, name: "資料")
      visit new_template_record_path(template_id: template.id)
      page.save_screenshot capture_path("templates/records/forms/upload_file"), width: 1440
    end

    context "国土地理院位置情報項目の場合" do
      let(:element){create(:element_by_it_kokudo_location, template_id: template.id, name: "住所（国土地理院）")}
      before do
        element
        visit new_template_record_path(template_id: template.id)
      end

      it "フォームのスクリーンショットの保存" do
        page.save_screenshot capture_path("templates/records/forms/kokudo_location"), width: 1440
      end

      it "地図表示のスクリーンショットの保存" do
        fill_in("latitude_#{element.id}_1", with: "35.442593")
        fill_in("longitude_#{element.id}_1", with: "133.066472")
        first(".map-search-modal-button").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/records/forms/kokudo_location2"), width: 1440
      end
    end

    context "OpenStreetMap位置情報項目の場合" do
      let(:element){create(:element_by_it_osm_location, template_id: template.id, name: "住所（OpenStreetMap）")}
      before do
        element
        visit new_template_record_path(template_id: template.id)
      end

      it "フォームのスクリーンショットの保存" do
        page.save_screenshot capture_path("templates/records/forms/osm_location"), width: 1440
      end

      it "地図表示のスクリーンショットの保存" do
        fill_in("latitude_#{element.id}_1", with: "35.442593")
        fill_in("longitude_#{element.id}_1", with: "133.066472")
        first(".map-search-modal-button").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/records/forms/osm_location2"), width: 1440
      end
    end

    context "GoogleMap位置情報項目のフォームの場合" do
      let(:element){create(:element_by_it_google_location, template_id: template.id, name: "住所（GoogleMap）")}
      before do
        element
        visit new_template_record_path(template_id: template.id)
      end

      it "フォームのスクリーンショットの保存" do
        page.save_screenshot capture_path("templates/records/forms/google_location"), width: 1440
      end

      it "地図表示のスクリーンショットの保存" do
        fill_in("latitude_#{element.id}_1", with: "35.442593")
        fill_in("longitude_#{element.id}_1", with: "133.066472")
        first(".map-search-modal-button").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/records/forms/google_location2"), width: 1440
      end
    end

    context "関連先がテンプレートの入力項目" do
      let(:temp){create(:template, service_id: service.id)}
      let(:el){create(:element_by_it_line, template_id: temp.id)}
      before do
        %w(松江城 宍道湖 小泉八雲記念館).each do |name|
          co = create(:element_value_line, value: name)
          create(:element_value, record_id: create(:template_record, template_id: temp.id).id,
            element_id: el.id, content: co, template_id: temp.id)
        end
      end

      context "複数選択（テンプレート）" do
        let(:element){
          create(:element_by_it_checkbox_template,
            name: "施設名", template_id: template.id, source: temp, source_element_id: el.id)
        }

        it "チェックボックスのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_CHECKBOX)
          visit new_template_record_path(template_id: template.id)
          page.save_screenshot capture_path("templates/records/forms/checkbox_template_checkbox"), width: 1440
        end

        context "ポップアップの場合" do
          before do
            element.update!(data_input_way: Element::DATA_INPUT_WAY_POPUP)
            visit new_template_record_path(template_id: template.id)
          end

          it "ポップアップのスクリーンショットの保存" do
            page.save_screenshot capture_path("templates/records/forms/checkbox_template_popup"), width: 1440
          end

          it "関連データの検索画面のスクリーンショットの保存" do
            find("#element#{element.id}_search_btn").click
            wait_until(0.5){ page.find(".modal-header").visible? }
            find("#element-relation-content-search-result_btn").click
            wait_until(0.5){ page.find(".list-group").visible? }
            sleep(2)
            page.save_screenshot capture_path("templates/records/forms/checkbox_template_popup2"), width: 1440
          end
        end
      end

      context "単一選択（テンプレート）" do
        let(:element){
          create(:element_by_it_pulldown_template,
            name: "施設名", template_id: template.id, source: temp, source_element_id: el.id)
        }

        it "プルダウンのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_PULLDOWN)
          visit new_template_record_path(template_id: template.id)
          find("select").click
          page.save_screenshot capture_path("templates/records/forms/pulldown_template_pulldown"), width: 1440
        end

        context "ポップアップの場合" do
          before do
            element.update!(data_input_way: Element::DATA_INPUT_WAY_POPUP)
            visit new_template_record_path(template_id: template.id)
          end

          it "ポップアップのスクリーンショットの保存" do
            page.save_screenshot capture_path("templates/records/forms/pulldown_template_popup"), width: 1440
          end

          it "関連データの検索画面のスクリーンショットの保存" do
            find("#element#{element.id}_search_btn").click
            wait_until(0.5){ page.find(".modal-header").visible? }
            find("#element-relation-content-search-result_btn").click
            wait_until(0.5){ page.find(".list-group").visible? }
            sleep(2)
            page.save_screenshot capture_path("templates/records/forms/pulldown_template_popup2"), width: 1440
          end
        end

        it "ラジオボタンのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_RADIO_BUTTON)
          visit new_template_record_path(template_id: template.id)
          page.save_screenshot capture_path("templates/records/forms/pulldown_template_radio"), width: 1440
        end
      end
    end

    context "関連先が語彙の入力項目" do
      let(:ve){create(:vocabulary_element)}
      before do
        %w(キロ メガ ギガ テラ).each do |name|
          create(:vocabulary_element_value, name: name, element_id: ve.id)
        end
      end

      context "複数選択（語彙）" do
        let(:element){
          create(:element_by_it_checkbox_vocabulary,
            name: "単位", template_id: template.id, source: ve)
        }

        it "チェックボックスのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_CHECKBOX)
          visit new_template_record_path(template_id: template.id)
          page.save_screenshot capture_path("templates/records/forms/checkbox_vocabulary_checkbox"), width: 1440
        end

        context "ポップアップの場合" do
          before do
            element.update!(data_input_way: Element::DATA_INPUT_WAY_POPUP)
            visit new_template_record_path(template_id: template.id)
          end

          it "ポップアップのスクリーンショットの保存" do
            page.save_screenshot capture_path("templates/records/forms/checkbox_vocabulary_popup"), width: 1440
          end

          it "関連データの検索画面のスクリーンショットの保存" do
            find("#element#{element.id}_search_btn").click
            wait_until(0.5){ page.find(".modal-header").visible? }
            find("#element-relation-content-search-result_btn").click
            wait_until(0.5){ page.find(".list-group").visible? }
            sleep(2)
            page.save_screenshot capture_path("templates/records/forms/checkbox_vocabulary_popup2"), width: 1440
          end
        end
      end

      context "単一選択（語彙）" do
        let(:element){
          create(:element_by_it_pulldown_vocabulary,
            name: "単位", template_id: template.id, source: ve)
        }

        it "プルダウンのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_PULLDOWN)
          visit new_template_record_path(template_id: template.id)
          find("select").click
          page.save_screenshot capture_path("templates/records/forms/pulldown_vocabulary_pulldown"), width: 1440
        end

        context "ポップアップの場合" do
          before do
            element.update!(data_input_way: Element::DATA_INPUT_WAY_POPUP)
            visit new_template_record_path(template_id: template.id)
          end

          it "ポップアップのスクリーンショットの保存" do
            page.save_screenshot capture_path("templates/records/forms/pulldown_vocabulary_popup"), width: 1440
          end

          it "関連データの検索画面のスクリーンショットの保存" do
            find("#element#{element.id}_search_btn").click
            wait_until(0.5){ page.find(".modal-header").visible? }
            find("#element-relation-content-search-result_btn").click
            wait_until(0.5){ page.find(".list-group").visible? }
            sleep(2)
            page.save_screenshot capture_path("templates/records/forms/pulldown_vocabulary_popup2"), width: 1440
          end
        end

        it "ラジオボタンのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_RADIO_BUTTON)
          visit new_template_record_path(template_id: template.id)
          page.save_screenshot capture_path("templates/records/forms/pulldown_vocabulary_radio"), width: 1440
        end
      end
    end
  end

  describe "入力データ編集画面" do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        tr # let call
        visit edit_template_record_path(tr.id, template_id: template.id)
        page.save_screenshot capture_path("templates/records/edit"), width: 1440
      end
    end

    it "拡張テンプレートの場合のスクリーンショットの保存" do
      tr # let call
      temp = create(:template, parent_id: template.id, service_id: service.id)
      visit edit_template_record_path(tr.id, template_id: temp.id)
      page.save_screenshot capture_path("templates/records/edit2"), width: 1440
    end

    it "１行入力項目のフォームのスクリーンショットの保存" do
      el = create(:element_by_it_line, template_id: template.id, name: "施設名", confirm_entry: true)
      r = create(:template_record, template_id: template.id)
      create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id, content: create(:element_value_line, value: "松江城"))
      visit edit_template_record_path(id: r.id, template_id: template.id)
      page.save_screenshot capture_path("templates/records/edit_forms/line"), width: 1440
    end

    it "複数行入力項目のフォームのスクリーンショットの保存" do
      el = create(:element_by_it_multi_line, template_id: template.id, name: "説明")
      r = create(:template_record, template_id: template.id)
      create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id, content: create(:element_value_multi_line, value: "松江城\n松江のお城はとても綺麗です。"))
      visit edit_template_record_path(id: r.id, template_id: template.id)
      page.save_screenshot capture_path("templates/records/edit_forms/multi_line"), width: 1440
    end

    it "日付入力項目のフォームのスクリーンショットの保存" do
      el = create(:element_by_it_dates, template_id: template.id, name: "イベント日")
      r = create(:template_record, template_id: template.id)
      create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id, content: create(:element_value_dates, value: "2014-12-24"))
      visit edit_template_record_path(id: r.id, template_id: template.id)

      page.execute_script('$(".input_datepicker").datepicker("show")')
      wait_until(0.5){ page.find("#ui-datepicker-div").visible? }
      page.save_screenshot capture_path("templates/records/edit_forms/dates"), width: 1440
    end

    it "時間入力項目のフォームのスクリーンショットの保存" do
      el = create(:element_by_it_times, template_id: template.id, name: "開館時間")
      r = create(:template_record, template_id: template.id)
      create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id, content: create(:element_value_times, value: DateTime.now))
      visit edit_template_record_path(id: r.id, template_id: template.id)
      page.save_screenshot capture_path("templates/records/edit_forms/times"), width: 1440
    end

    it "ファイル項目のフォームのスクリーンショットの保存" do
      el = create(:element_by_it_upload_file, template_id: template.id, name: "資料")
      r = create(:template_record, template_id: template.id)
      create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id, kind: ElementValue::LABEL_KIND,
        content: create(:element_value_upload_file, value: "テスト画像"))
      file = ActionDispatch::Http::UploadedFile.new({:tempfile => File.new(Rails.root.join('spec', 'files', 'test.txt'))})

      c = build(:element_value_upload_file, value: "test.txt")
      c.temp = file
      create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id, kind: ElementValue::FILE_KIND,
        content: c)


      visit edit_template_record_path(id: r.id, template_id: template.id)
      page.save_screenshot capture_path("templates/records/edit_forms/upload_file"), width: 1440
    end

    context "国土地理院位置情報項目の場合" do
      let(:el){create(:element_by_it_kokudo_location, template_id: template.id, name: "住所（国土地理院）")}

      it "フォームのスクリーンショットの保存" do
        r = create(:template_record, template_id: template.id)
        create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id,
          kind: ElementValue::LATITUDE_KIND,
          content: create(:element_value_kokudo_location, value: "33.12345"))
        create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id,
          kind: ElementValue::LONGITUDE_KIND,
          content: create(:element_value_kokudo_location, value: "133.54321"))
        visit edit_template_record_path(id: r.id, template_id: template.id)
        page.save_screenshot capture_path("templates/records/edit_forms/kokudo_location"), width: 1440
      end
    end

    context "OpenStreetMap位置情報項目の場合" do
      let(:el){create(:element_by_it_osm_location, template_id: template.id, name: "住所（OpenStreetMap）")}

      it "フォームのスクリーンショットの保存" do
        r = create(:template_record, template_id: template.id)
        create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id,
          kind: ElementValue::LATITUDE_KIND,
          content: create(:element_value_osm_location, value: "33.12345"))
        create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id,
          kind: ElementValue::LONGITUDE_KIND,
          content: create(:element_value_osm_location, value: "133.54321"))
        visit edit_template_record_path(id: r.id, template_id: template.id)
        page.save_screenshot capture_path("templates/records/edit_forms/osm_location"), width: 1440
      end
    end

    context "GoogleMap位置情報項目のフォームの場合" do
      let(:el){create(:element_by_it_google_location, template_id: template.id, name: "住所（国土地理院）")}

      it "フォームのスクリーンショットの保存" do
        r = create(:template_record, template_id: template.id)
        create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id,
          kind: ElementValue::LATITUDE_KIND,
          content: create(:element_value_google_location, value: "33.12345"))
        create(:element_value, element_id: el.id, template_id: template.id, record_id: r.id,
          kind: ElementValue::LONGITUDE_KIND,
          content: create(:element_value_google_location, value: "133.54321"))
        visit edit_template_record_path(id: r.id, template_id: template.id)
        page.save_screenshot capture_path("templates/records/edit_forms/google_location"), width: 1440
      end
    end

    context "関連先がテンプレートの入力項目" do
      let(:temp){create(:template, service_id: service.id)}
      let(:el){create(:element_by_it_line, template_id: temp.id)}
      let(:r){create(:template_record, template_id: template.id)}
      let(:relation_trs){
        %w(松江城 宍道湖 小泉八雲記念館).map do |name|
          co = create(:element_value_line, value: name)
          rec = create(:template_record, template_id: temp.id)
          create(:element_value, record_id: rec.id,
            element_id: el.id, content: co, template_id: temp.id)
          rec
        end
      }
      before do
        relation_trs
      end

      context "複数選択（テンプレート）" do
        let(:element){
          create(:element_by_it_checkbox_template,
            name: "施設名", template_id: template.id, source: temp, source_element_id: el.id)
        }

        before do
          id = relation_trs.first.id
          create(:element_value, kind: id, content: create(:element_value_checkbox_template, value: id), element_id: element.id, record_id: r.id, template_id: template.id)
        end

        it "チェックボックスのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_CHECKBOX)
          visit edit_template_record_path(id: r.id, template_id: template.id)
          page.save_screenshot capture_path("templates/records/edit_forms/checkbox_template_checkbox"), width: 1440
        end

        context "ポップアップの場合" do
          before do
            element.update!(data_input_way: Element::DATA_INPUT_WAY_POPUP)
            visit edit_template_record_path(id: r.id, template_id: template.id)
          end

          it "関連データの検索画面のスクリーンショットの保存" do
            find("#element#{element.id}_search_btn").click
            wait_until(0.5){ page.find(".modal-header").visible? }
            find("#element-relation-content-search-result_btn").click
            wait_until(0.5){ page.find(".list-group").visible? }
            sleep(2)
            page.save_screenshot capture_path("templates/records/edit_forms/checkbox_template_popup"), width: 1440
          end
        end
      end

      context "単一選択（テンプレート）" do
        let(:element){
          create(:element_by_it_pulldown_template,
            name: "施設名", template_id: template.id, source: temp, source_element_id: el.id)
        }

        before do
          id = relation_trs.first.id
          create(:element_value, kind: 0, content: create(:element_value_pulldown_template, value: id), template_id: template.id, element_id: element.id, record_id: r.id)
        end

        it "プルダウンのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_PULLDOWN)
          visit edit_template_record_path(id: r.id, template_id: template.id)
          find("select").click
          page.save_screenshot capture_path("templates/records/edit_forms/pulldown_template_pulldown"), width: 1440
        end

        context "ポップアップの場合" do
          before do
            element.update!(data_input_way: Element::DATA_INPUT_WAY_POPUP)
            visit edit_template_record_path(id: r.id, template_id: template.id)
          end

          it "関連データの検索画面のスクリーンショットの保存" do
            find("#element#{element.id}_search_btn").click
            wait_until(0.5){ page.find(".modal-header").visible? }
            find("#element-relation-content-search-result_btn").click
            wait_until(0.5){ page.find(".list-group").visible? }
            sleep(2)
            page.save_screenshot capture_path("templates/records/edit_forms/pulldown_template_popup"), width: 1440
          end
        end

        it "ラジオボタンのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_RADIO_BUTTON)
          visit edit_template_record_path(id: r.id, template_id: template.id)
          page.save_screenshot capture_path("templates/records/edit_forms/pulldown_template_radio"), width: 1440
        end
      end
    end

    context "関連先が語彙の入力項目" do
      let(:ve){create(:vocabulary_element)}
      let(:vevs){
        %w(キロ メガ ギガ テラ).map do |name|
          create(:vocabulary_element_value, name: name, element_id: ve.id)
        end
      }
      let(:r){create(:template_record, template_id: template.id)}
      before do
        vevs
      end

      context "複数選択（語彙）" do
        let(:element){
          create(:element_by_it_checkbox_vocabulary,
            name: "単位", template_id: template.id, source: ve)
        }

        before do
          id = vevs.first.id
          create(:element_value, kind: id, content: create(:element_value_checkbox_vocabulary, value: id), element_id: element.id, record_id: r.id, template_id: template.id)
        end

        it "チェックボックスのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_CHECKBOX)
          visit edit_template_record_path(id: r.id, template_id: template.id)
          page.save_screenshot capture_path("templates/records/edit_forms/checkbox_vocabulary_checkbox"), width: 1440
        end

        context "ポップアップの場合" do
          before do
            element.update!(data_input_way: Element::DATA_INPUT_WAY_POPUP)
            visit edit_template_record_path(id: r.id, template_id: template.id)
          end

          it "関連データの検索画面のスクリーンショットの保存" do
            find("#element#{element.id}_search_btn").click
            wait_until(0.5){ page.find(".modal-header").visible? }
            find("#element-relation-content-search-result_btn").click
            wait_until(0.5){ page.find(".list-group").visible? }
            sleep(2)
            page.save_screenshot capture_path("templates/records/edit_forms/checkbox_vocabulary_popup"), width: 1440
          end
        end
      end

      context "単一選択（語彙）" do
        let(:element){
          create(:element_by_it_pulldown_vocabulary,
            name: "単位", template_id: template.id, source: ve)
        }

        before do
          id = vevs.first.id
          create(:element_value, kind: 0, content: create(:element_value_pulldown_vocabulary, value: id), element_id: element.id, record_id: r.id, template_id: template.id)
        end

        it "プルダウンのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_PULLDOWN)
          visit edit_template_record_path(id: r.id, template_id: template.id)
          find("select").click
          page.save_screenshot capture_path("templates/records/edit_forms/pulldown_vocabulary_pulldown"), width: 1440
        end

        context "ポップアップの場合" do
          before do
            element.update!(data_input_way: Element::DATA_INPUT_WAY_POPUP)
            visit edit_template_record_path(id: r.id, template_id: template.id)
          end

          it "関連データの検索画面のスクリーンショットの保存" do
            find("#element#{element.id}_search_btn").click
            wait_until(0.5){ page.find(".modal-header").visible? }
            find("#element-relation-content-search-result_btn").click
            wait_until(0.5){ page.find(".list-group").visible? }
            sleep(2)
            page.save_screenshot capture_path("templates/records/edit_forms/pulldown_vocabulary_popup"), width: 1440
          end
        end

        it "ラジオボタンのスクリーンショットの保存" do
          element.update!(data_input_way: Element::DATA_INPUT_WAY_RADIO_BUTTON)
          visit edit_template_record_path(id: r.id, template_id: template.id)
          page.save_screenshot capture_path("templates/records/edit_forms/pulldown_vocabulary_radio"), width: 1440
        end
      end
    end

  end

  describe "CSV一括登録画面" do
    let(:template){create(:template_with_elements, user_id: user.id, service_id: service.id)}

    before do
      visit import_csv_form_template_records_path(template_id: template.id)
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("templates/records/import_csv_form"), width: 1440, height: 1280
    end

    after do
      FileUtils.rm_rf Dir[File.join(Settings.files.csv_dir_path, '*')]
    end
  end

  describe "CSV一括登録確認画面" do
    let(:template){create(:template, user_id: user.id, service_id: service.id)}
    let(:submit) { '確認する' }

    before do
      create_list(:only_element, 6, template: template)
      allow_any_instance_of(ImportCSV).to receive(:header_valid).and_return(true)
      visit import_csv_form_template_records_path(template_id: template.id)
      attach_file("import_csv_csv", Rails.root.join('spec', 'files', 'csv', 'standard.csv'))
      click_button submit
    end

    it "スクリーンショットの保存" do
      page.save_screenshot capture_path("templates/records/confirm_import_csv"), width: 1440
    end

    after do
      FileUtils.rm_rf Dir[File.join(Settings.files.csv_dir_path, '*')]
    end
  end

  describe "CSV一括登録完了画面" do
    it "スクリーンショットの保存" do
      visit complete_import_csv_template_records_path(template_id: template.id)
      page.save_screenshot capture_path("templates/records/complete_import_csv"), width: 1440
    end
  end

  describe "検索結果一覧画面（キーワード検索時）" do
    before do
      el = create(:element_by_it_line, template_id: template.id, confirm_entry: true, name: "施設名")
      create(:template_record, values: [create(:element_value, element_id: el.id, content: create(:element_value_line, value: "松江城"))])
      create(:template_record, values: [create(:element_value, element_id: el.id, content: create(:element_value_line, value: "松江城下町"))])
    end

    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit new_template_record_path(template_id: template.id)

        first('input[type="text"]').set("松江 城")
        first(".confirm-entries-modal-button").click

        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/records/search_keyword"), width: 1440, height: 700
      end
    end
  end

  describe "詳細表示画面", js: true do
    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        tr # let call
        visit template_records_path(template_id: template.id)
        first(".show-link").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/records/show")
      end
    end

    context "階層構造＆繰り返し入力がある場合の画面" do
      it "スクリーンショットの保存" do
        record = create(:template_record, template_id: template.id)
        parent = create(:element, name: "施設型", multiple_input: true, template_id: template.id)
        child1 = create(:element_by_it_line, name: "施設_名称", parent_id: parent.id, template_id: template.id)
        child2 = create(:element_by_it_dates, name: "施設_設立日", parent_id: parent.id, template_id: template.id)

        base_attr = {template_id: template.id, record_id: record.id}
        create(:element_value, base_attr.merge(element_id: child1.id, item_number: 1, content: create(:element_value_line, value: "松江城")))
        create(:element_value, base_attr.merge(element_id: child2.id, item_number: 1, content: create(:element_value_dates, value: "2014-01-01")))
        create(:element_value, base_attr.merge(element_id: child1.id, item_number: 2, content: create(:element_value_line, value: "堀川")))
        create(:element_value, base_attr.merge(element_id: child2.id, item_number: 2, content: create(:element_value_dates, value: "1900-01-01")))


        visit template_records_path(template_id: template.id)
        first(".show-link").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/records/show2")
      end
    end

    context "特別な詳細表示のデータのキャプチャ" do
      context "位置情報項目" do
        before do
          record = create(:template_record, template_id: template.id)
          element = create(:element_by_it_osm_location, name: "住所", template_id: template.id)

          create(:element_value,
            template_id: template.id, record_id: record.id,
            element_id: element.id,
            item_number: 1,
            kind: ElementValue::KINDS[:osm_location][:latitude],
            content: create(:element_value_osm_location_lat)
          )
          create(:element_value,
            template_id: template.id, record_id: record.id,
            element_id: element.id,
            item_number: 1,
            kind: ElementValue::KINDS[:osm_location][:longitude],
            content: create(:element_value_osm_location_lon)
          )
          visit template_records_path(template_id: template.id)
          first(".show-link").click
          wait_until(0.5){ page.find(".modal-header").visible? }
        end

        it "スクリーンショットの保存" do
          page.save_screenshot capture_path("templates/records/show3")
        end

        it "地図表示のスクリーンショットの保存" do
          first(".map-modal-button").click
          wait_until(0.5){ page.find("#canvas").visible? }
          page.save_screenshot capture_path("templates/records/show3-1")
        end
      end

      context "単一選択項目、複数選択項目" do
        before do
          record = create(:template_record, template_id: template.id)
          ve = create(:vocabulary_element, name: "設備")

          value1 = create(:vocabulary_element_value, element_id: ve.id, name: "トイレ").id
          value2 = create(:vocabulary_element_value, element_id: ve.id, name: "AED").id
          value3 = create(:vocabulary_element_value, element_id: ve.id, name: "スロープ").id

          element = create(:element_by_it_checkbox_vocabulary, name: "設備", template_id: template.id, source: ve)

          create(:element_value,
            template_id: template.id, record_id: record.id,
            element_id: element.id,
            item_number: 1,
            kind: ElementValue::KINDS[:osm_location][:latitude],
            content: create(:element_value_checkbox_vocabulary, value: value1)
          )
          create(:element_value,
            template_id: template.id, record_id: record.id,
            element_id: element.id,
            item_number: 1,
            kind: ElementValue::KINDS[:osm_location][:latitude],
            content: create(:element_value_checkbox_vocabulary, value: value2)
          )

          visit template_records_path(template_id: template.id)
          first(".show-link").click
          wait_until(0.5){ page.find(".modal-header").visible? }
        end

        it "スクリーンショットの保存" do
          page.save_screenshot capture_path("templates/records/show4")
        end

        it "参照データの表示のスクリーンショットの保存" do
          first(".display_relation_contents_button").click
          wait_until(0.5){ page.find("#display_relation_contents-pagination").visible? }
          page.save_screenshot capture_path("templates/records/show4-1")
        end
      end
    end
  end

  describe "データ入力ヘルプ画面" do
    let(:el){create(:element_by_it_line, template_id: template.id,
        description: "施設名の項目です。",
        required: true, unique: true, data_example: "松江城", name: "施設")}
    context "初期表示の場合" do
      before do
        el
      end

      it "スクリーンショットの保存" do
        visit new_template_record_path(template_id: template.id)
        first(".template_help_link").click
        wait_until(0.5){ page.find(".popover-title").visible? }
        page.save_screenshot capture_path("templates/records/element_description"), width: 1440
      end
    end
  end

  describe "関連データ検索フォーム表示" do
    let(:source){create(:template)}
    let(:source_el){create(:element_by_it_line, template_id: source.id)}
    let(:el){create(:element_by_it_checkbox_template, source: source, source_element_id: source_el.id,
        template_id: template.id, data_input_way: Element::DATA_INPUT_WAY_POPUP)}

    before do
      el
      %w(松江城).each do |val|
          create(:template_record, template_id: source.id,
            values: [create(:element_value, element_id: source_el.id, template_id: source.id,
                content: create(:element_value_line, value: val))])
        end
    end

    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit new_template_record_path(template_id: template.id)
        find("#element#{el.id}_search_btn").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/records/element_relation_search_form"), width: 1440
      end
    end
  end

  describe "関連データ検索結果表示画面" do
    let(:source){create(:template)}
    let(:source_el){create(:element_by_it_line, template_id: source.id)}

    context "複数選択項目の場合" do
      let(:el){create(:element_by_it_checkbox_template, name: "施設", source: source, source_element_id: source_el.id,
          template_id: template.id, data_input_way: Element::DATA_INPUT_WAY_POPUP)}

      before do
        el
        %w(松江城 松江城下町 県立美術館 八重垣神社 熊野大社 風土記の丘).each do |val|
          create(:template_record, template_id: source.id,
            values: [create(:element_value, element_id: source_el.id, template_id: source.id,
                content: create(:element_value_line, value: val))])
        end
      end

      context "初期表示の場合" do
        it "スクリーンショットの保存" do
          visit new_template_record_path(template_id: template.id)
          find("#element#{el.id}_search_btn").click
          wait_until(0.5){ page.find(".modal-header").visible? }
          find("#element-relation-content-search-result_btn").click
          wait_until(0.5){ page.find(".list-group").visible? }
          sleep(2)
          page.save_screenshot capture_path("templates/records/element_relation_search"), width: 1440, height: 700
        end
      end
    end

    context "単一選択項目の場合" do
      let(:el){create(:element_by_it_pulldown_template, name: "施設", source: source, source_element_id: source_el.id,
          template_id: template.id, data_input_way: Element::DATA_INPUT_WAY_POPUP)}

      before do
        el
        %w(松江城 松江城下町 県立美術館 八重垣神社 熊野大社 風土記の丘).each do |val|
          create(:template_record, template_id: source.id,
            values: [create(:element_value, element_id: source_el.id, template_id: source.id,
                content: create(:element_value_line, value: val))])
        end
      end

      context "初期表示の場合" do
        it "スクリーンショットの保存" do
          visit new_template_record_path(template_id: template.id)
          find("#element#{el.id}_search_btn").click
          wait_until(0.5){ page.find(".modal-header").visible? }
          find("#element-relation-content-search-result_btn").click
          wait_until(0.5){ page.find(".list-group").visible? }
          sleep(2)
          page.save_screenshot capture_path("templates/records/element_relation_search2"), width: 1440, height: 700
        end
      end
    end
  end

  describe "関連データ表示画面" do
    let(:source){create(:template)}
    let(:source_el){create(:element_by_it_line, template_id: source.id)}
    let(:el){create(:element_by_it_checkbox_template, name: "施設", source: source, source_element_id: source_el.id, display: true,
        template_id: template.id, data_input_way: Element::DATA_INPUT_WAY_POPUP)}

    let(:trs){
      %w(松江城 松江城下町 県立美術館 八重垣神社 熊野大社 風土記の丘).map do |val|
        create(:template_record, template_id: source.id,
          values: [create(:element_value, element_id: source_el.id, template_id: source.id,
              content: create(:element_value_line, value: val))])
      end
    }

    let(:tr){
      create(:template_record, template_id: template.id,
        values: [
          create(:element_value, element_id: el.id, template_id: template.id, kind: trs[0].id, content: create(:element_value_checkbox_template, value: trs[0].id)),
          create(:element_value, element_id: el.id, template_id: template.id, kind: trs[2].id, content: create(:element_value_checkbox_template, value: trs[2].id)),
          create(:element_value, element_id: el.id, template_id: template.id, kind: trs[4].id, content: create(:element_value_checkbox_template, value: trs[4].id))
        ]
      )
    }

    before do
      tr
    end

    context "初期表示の場合" do
      it "スクリーンショットの保存" do
        visit template_records_path(template_id: template.id)
        first(".display_relation_contents_button").click
        wait_until(0.5){ page.find(".modal-header").visible? }
        page.save_screenshot capture_path("templates/records/display_relation_contents"), width: 1440
      end
    end
  end
end

