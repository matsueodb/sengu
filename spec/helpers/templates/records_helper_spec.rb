require 'spec_helper'

describe Templates::RecordsHelper do
  describe "#options_for_select_with_prefs" do
    let(:shimane){create(:pref_shimane)}
    let(:tottori){create(:pref_tottori)}
    let(:prefs){[shimane, tottori]}

    it "第一引数prefsの都道府県をもとにoptionタグを返すこと" do
      result = %Q(<option value="#{shimane.id}">#{shimane.name}</option>\n<option value="#{tottori.id}">#{tottori.name}</option>)
      expect(helper.options_for_select_with_prefs(prefs)).to eq(result)
    end

    it "第二引数に渡した値がselectedになること" do
      result = %Q(<option selected="selected" value="#{shimane.id}">#{shimane.name}</option>\n<option value="#{tottori.id}">#{tottori.name}</option>)
      expect(helper.options_for_select_with_prefs(prefs, shimane.id)).to eq(result)
    end
  end

  describe "#options_for_select_with_reference_values" do
    context "対象がテンプレートの場合" do
      let(:source){create(:template)}
      let(:se){create(:element_by_it_line, template_id: source.id)}
      let(:element){create(:element_by_it_pulldown_template, source: source, source_element_id: se.id)}

      let(:values){[
        create(:element_value, record_id: 1, element_id: element.id, item_number: 1, content: create(:element_value_line, value: "松江城")),
        create(:element_value, record_id: 1, element_id: element.id, item_number: 2, content: create(:element_value_line, value: "天守閣")),
        create(:element_value, record_id: 2, element_id: element.id, item_number: 1,  content: create(:element_value_line, value: "松江城下町")),
        create(:element_value, record_id: 3, element_id: element.id, item_number: 1,  content: create(:element_value_line, value: "県立美術館"))
      ]}

      let(:selected){values[1].id}

      let(:vals){
        {
         1 => "松江城,天守閣",
         2 => "松江城下町",
         3 => "県立美術館",
        }
      }

      before do
        element.stub(:reference_values){values}
      end

      it "elementの参照しているテンプレートの情報をもとにoptionタグを返すこと" do
        result = vals.map{|r_id, val|%Q(<option value="#{r_id}">#{val}</option>)}
        result.unshift(%Q(<option value="">#{I18n.t("shared.non_select")}</option>))
        expect(helper.options_for_select_with_reference_values(element)).to eq(result.join("\n"))
      end

      it "第2引数に渡した値がselectedになること" do
        result = vals.map{|r_id, val|%Q(<option #{('selected="selected" ' if r_id == selected)}value="#{r_id}">#{val}</option>)}
        result.unshift(%Q(<option value="">#{I18n.t("shared.non_select")}</option>))
        expect(helper.options_for_select_with_reference_values(element, selected)).to eq(result.join("\n"))
      end
    end
  end

  describe "#add_button_tag" do
    subject{helper.add_button_tag("button")}
    let(:result){%Q(<span class="glyphicon glyphicon-plus">button</span>)}

    it "追加ボタンのタグを返す。" do
      expect(subject).to eq(result)
    end
  end

  describe "#remove_button_tag" do
    subject{helper.remove_button_tag("button")}
    let(:result){%Q(<span class="glyphicon glyphicon-minus">button</span>)}

    it "削除ボタンのタグを返す。" do
      expect(subject).to eq(result)
    end
  end

  describe "#add_form_button" do
    let(:template){create(:template)}
    let(:element){create(:element, template_id: template.id)}
    let(:form_object_name){"template_record"}
    let(:index){2}
    let(:inner_html){%Q(<span class="glyphicon glyphicon-plus"></span>).html_safe}
    let(:opts){{
      class: "btn btn-success add-form-button ajax-loading-display",
      method: :post,
      data: {
        "element-id" => element.id, "index" => index,
        "href" => add_form_template_records_path(template_id: template.id)
      }
    }}

    it "項目の追加ボタンが返ること" do
      html = link_to("javascript:;", opts){inner_html}
      expect(helper.add_form_button(template, element, index)).to eq(html)
    end

    it "第４引数にtrueが送られた場合、ボタンがdisabledになること" do
      html = link_to("javascript:;", opts.merge("disabled" => "disabled")){inner_html}
      expect(helper.add_form_button(template, element, index, true)).to eq(html)
    end
  end

  describe "#remove_form_button" do
    let(:element){create(:element)}
    let(:index){2}
    let(:inner_html){%Q(<span class="glyphicon glyphicon-minus"></span>).html_safe}
    let(:opts){{
      class: "btn btn-danger remove-form-button",
      data: {"remove-id" => "input_form_#{element.id}_#{index}"}
    }}

    it "項目の削除ボタンが返ること" do
      html = link_to("javascript:;", opts){inner_html}
      expect(helper.remove_form_button(element.id, index)).to eq(html)
    end
  end

  describe "#add_namespace_form_button" do
    let(:template){create(:template)}
    let(:element){create(:element, template_id: template.id)}
    let(:item_number){3}
    let(:index){2}
    let(:button_tag){%Q(<span class="glyphicon glyphicon-plus"></span>).html_safe}
    let(:opts){{
      class: "btn btn-success add-namespace-form-button ajax-loading-display",
      method: :post,
      data: {
        "element-id" => element.id, "index" => index,
        "item-number" => item_number,
        "href" => add_namespace_form_template_records_path(template_id: template.id)
      }
    }}

    before do
      helper.stub(:add_button_tag){button_tag}
    end

    it "項目の追加ボタンが返ること" do
      html = link_to("javascript:;", opts){button_tag}
      expect(helper.add_namespace_form_button(template, element, item_number, index)).to eq(html)
    end

    it "第５引数にtrueが送られた場合、ボタンがdisabledになること" do
      html = link_to("javascript:;", opts.merge("disabled" => "disabled")){button_tag}
      expect(helper.add_namespace_form_button(template, element, item_number, index, true)).to eq(html)
    end
  end

  describe "#remove_namespace_form_button" do
    let(:element){create(:element)}
    let(:index){2}
    let(:item_number){3}
    let(:inner_html){%Q(<span class="glyphicon glyphicon-minus"></span>).html_safe}
    let(:opts){{
      class: "btn btn-danger remove-namespace-form-button",
      data: {"remove-id" => "namespace_field_#{element.id}_#{index}_#{item_number}"}
    }}

    before do
      helper.stub(:remove_button_tag){inner_html}
    end

    it "項目の削除ボタンが返ること" do
      html = link_to("javascript:;", opts){inner_html}
      expect(helper.remove_namespace_form_button(element.id, item_number, index)).to eq(html)
    end
  end

  describe "#required_icon" do
    let(:icon){%Q(<strong class="text-danger">（#{Element.human_attribute_name(:required)}）</strong>)}

    it "必須入力を表すアイコンのHTMLが返ること" do
      expect(helper.required_icon).to eq(icon)
    end
  end

  describe "#options_for_select_with_hours" do
    let(:hours){
      ar = (0..23).to_a.map{|n|[("%02d" % n) , n]}
      ar.unshift([I18n.t("shared.non_select"), ""])
      ar
    }

    it "時間のoptionタグを返すこと" do
      result = hours.map{|name, value|%Q(<option #{('selected="selected" ' if value == "")}value="#{value}">#{name}</option>)}.join("\n")
      expect(helper.options_for_select_with_hours).to eq(result)
    end

    it "引数に渡した値がselectedになること" do
      selected = 3
      result = hours.map{|name, value|%Q(<option #{('selected="selected" ' if value.to_i == selected)}value="#{value}">#{name}</option>)}.join("\n")
      expect(helper.options_for_select_with_hours(selected)).to eq(result)
    end
  end

  describe "#options_for_select_with_minutes" do
    let(:minutes){
      ar = [0,5,10,15,20,25,30,35,40,45,50,55].map{|n|[("%02d" % n) , n]}
      ar.unshift([I18n.t("shared.non_select"), ""])
      ar
    }

    it "時間のoptionタグを返すこと" do
      result = minutes.map{|name, value|%Q(<option #{('selected="selected" ' if value == "")}value="#{value}">#{name}</option>)}.join("\n")
      expect(helper.options_for_select_with_minutes).to eq(result)
    end

    it "引数に渡した値がselectedになること" do
      selected = 3
      result = minutes.map{|name, value|%Q(<option #{('selected="selected" ' if value.to_i == selected)}value="#{value}">#{name}</option>)}.join("\n")
      expect(helper.options_for_select_with_minutes(selected)).to eq(result)
    end
  end
end
