require 'spec_helper'

describe Templates::ElementsHelper do
  describe "#render_form_with_input_type" do
    let(:template) { create(:template) }
    let(:element) { create(:element, template_id: template.id) }

    context "語彙を選択するフォームを表示する場合" do
      let(:input_type) { create(:input_type_checkbox_vocabulary) }

      it "vocabulary_formをrenderしていること" do
        expect(helper.render_form_with_input_type(template, element, input_type)).to render_template("templates/elements/forms/_vocabulary_form")
      end
    end

    context "テンプレートを選択するフォームを表示する場合" do
      let(:input_type) { create(:input_type_checkbox_template) }

      before do
        allow(helper).to receive(:current_user).and_return(create(:super_user))
      end

      it "template_select_formをrenderしていること" do
        expect(helper.render_form_with_input_type(template, element, input_type)).to render_template("templates/elements/forms/_template_select_form")
      end
    end

    context "それ以外のフォームを表示する場合" do
      let(:input_type) { create(:input_type_line) }

      it "template_select_formをrenderしていること" do
        expect(helper.render_form_with_input_type(template, element, input_type)).to render_template("templates/elements/forms/_other_form")
      end
    end
  end

  describe "#options_for_select_with_data_input_ways" do
    Element::DATA_INPUT_WAYS.each do |input_name, types|
      context "#{input_name}の場合" do
        let(:attr){
          case
          when input_name.include?("template")
            te = create(:template)
            {source: te, source_element_id: create(:element, template_id: te.id)}
          when input_name.include?("vocabulary")
            ve = create(:vocabulary_element)
            {source: ve}
          end
        }
        let(:element){create(:"element_by_it_#{input_name}", attr)}
        it "入力形式に合った選択肢がOptionタグで返ること" do
          result = types.map{|k, v|%Q(<option value="#{v}">#{I18n.t("element.data_input_way_label.#{k}")}</option>)}.join("\n")
          expect(helper.options_for_select_with_data_input_ways(element.input_type)).to eq(result)
        end

        it "第２引数で渡した値がselectedになり、optionタグが返ること" do
          selected = types.values.last
          result = types.map{|k, v|%Q(<option #{('selected="selected" ' if v == selected)}value="#{v}">#{I18n.t("element.data_input_way_label.#{k}")}</option>)}.join("\n")
          expect(helper.options_for_select_with_data_input_ways(element.input_type, selected)).to eq(result)
        end
      end
    end
  end
end
