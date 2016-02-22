# == Schema Information
#
# Table name: elements
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  entry_name            :string(255)
#  template_id           :integer
#  regular_expression_id :integer
#  parent_id             :integer
#  input_type_id         :integer
#  max_digit_number          :integer
#  description           :string(255)
#  data_example          :string(255)
#  required              :boolean
#  unique                :boolean
#  confirm_entry         :boolean          default(FALSE)
#  display               :boolean
#  source_type           :string(255)
#  source_id             :integer
#  display_number        :integer
#  created_at            :datetime
#  updated_at            :datetime
#  data_input_way        :integer          default(0)
#  source_element_id     :integer
#

require 'spec_helper'

describe Element do
  describe "association" do
    it {should belong_to(:template)}
    it {should belong_to(:input_type)}
    it {should belong_to(:regular_expression)}
    it {should belong_to(:source)}
    it {should belong_to(:source_element).class_name("Element")}
    it {should belong_to(:parent)}
    it {should have_many(:children).class_name("Element").dependent(:destroy)}
    it {should have_many(:values).class_name("ElementValue").dependent(:destroy)}
  end

  describe "scope" do
    let(:template){create(:template)}
    let(:input_type){create(:input_type_line)}
    describe "locations" do
      subject{Element.locations}
      it "位置情報の型が選択されているものが取得されること" do
        els = []
        2.times do
          els << build(:element_by_it_kokudo_location, template: template, input_type: input_type)
          els << build(:element_by_it_osm_location, template: template, input_type: input_type)
          els << build(:element_by_it_google_location, template: template, input_type: input_type)
          els << build(:element_by_it_line, template: template, input_type: input_type)
        end
        Element.import(els)

        subject.each do |s|
          expect(s.input_type.name.to_sym.in?(InputType::LOCATION_NAMES)).to be_true
        end
      end
    end

    describe "lines" do
      subject{Element.lines}

      it "１行入力の型が選択されているものが取得されること" do
        els = []
        3.times do
          els << build(:element_by_it_line, template: template, input_type: input_type)
          els << build(:element_by_it_multi_line, template: template, input_type: input_type)
        end
        Element.import(els)

        subject.each do |s|
          expect(s.input_type.name).to eq("line")
        end
      end
    end

    describe "root" do
      subject{Element.root}

      it "一番親階層のElementが取得されること" do
        e = create(:element, template: template, input_type: input_type)
        e = create(:element, parent_id: e.id, template: template, input_type: input_type)
        create(:element, parent_id: e.id, template: template, input_type: input_type)

        subject.each do |s|
          expect(s.parent_id).to be_nil
        end
      end
    end

    describe "displays" do
      subject{Element.displays}

      it "display==trueのもののみが取得出来ること" do

        Element.import(
          (1..3).map do
            create(:element, display: true, template: template, input_type: input_type)
            create(:element, display: false, template: template, input_type: input_type)
          end.flatten
        )

        subject.each do |s|
          expect(s.display).to be_true
        end
      end
    end

    describe "availables" do
      subject{Element.availables}

      it "available==trueのもののみが取得出来ること" do

        Element.import(
          (1..3).map do
            create(:element, available: true, template: template, input_type: input_type)
            create(:element, available: false, template: template, input_type: input_type)
          end.flatten
        )

        subject.each do |s|
          expect(s.available).to be_true
        end
      end
    end

    describe "publishes" do
      subject{Element.publishes}

      it "publish==trueのもののみが取得出来ること" do

        Element.import(
          (1..3).map do
            create(:element, publish: true, template: template, input_type: input_type)
            create(:element, publish: false, template: template, input_type: input_type)
          end.flatten
        )

        subject.each do |s|
          expect(s.publish).to be_true
        end
      end
    end
  end

  describe "バリデーション" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:template_id, :parent_id) }
    it { should validate_presence_of(:input_type_id) }
    it { should validate_numericality_of(:max_digit_number).only_integer }
    it { should validate_numericality_of(:min_digit_number).only_integer }
    it { should validate_numericality_of(:min_digit_number).is_greater_than_or_equal_to(0) }
    it { should ensure_length_of(:name).is_at_most(255) }
    it { should ensure_length_of(:description).is_at_most(255) }
    it { should ensure_length_of(:data_example).is_at_most(255) }

    describe "validate_numericality_of :max_digit_number" do
      context "min_digit_numberが0以上10000以下の値が入力されている場合" do
        let(:min_digit_number) { 10 }

        context "max_digit_numberがmin_digit_number以上の場合" do
          context "max_digit_numberが10000以下の場合" do
            it "バリデーションに引っかからないこと" do
              element = build(:only_element, max_digit_number: min_digit_number + 1, min_digit_number: min_digit_number)
              expect(element).to have(0).errors_on(:max_digit_number)
            end
          end

          context "max_digit_numberが10000より大きい場合" do
            it "バリデーションに引っかかること" do
              element = build(:only_element, max_digit_number: 10001, min_digit_number: min_digit_number)
              expect(element).to have(1).errors_on(:max_digit_number)
            end
          end
        end

        context "max_digit_numberがmin_digit_number未満の場合" do
          it "バリデーションに引っかかること" do
            element = build(:only_element, max_digit_number: min_digit_number - 1, min_digit_number: min_digit_number)
            expect(element).to have(1).errors_on(:max_digit_number)
          end
        end
      end

      context "min_digit_numberが10000より大きい値が入力されている場合" do
        let(:min_digit_number) { 10001 }

        context "max_digit_numberが10000以下の場合" do
          it "バリデーションに引っかからないこと" do
            element = build(:only_element, min_digit_number: min_digit_number, max_digit_number: 10000)
            expect(element).to have(0).errors_on(:max_digit_number)
          end
        end

        context "mid_digit_numberが10000より大きい場合" do
          it "バリデーションに引っかかること" do
            element = build(:only_element, min_digit_number: min_digit_number, max_digit_number: 10001)
            expect(element).to have(1).errors_on(:max_digit_number)
          end
        end
      end

      context "min_digit_numberが0未満の値が入力されている場合" do
        let(:min_digit_number) { -1 }

        context "max_digit_numberが1以上の場合" do
          it "バリデーションに引っかからないこと" do
            element = build(:only_element, max_digit_number: 1, min_digit_number: min_digit_number)
            expect(element).to have(0).errors_on(:max_digit_number)
          end
        end

        context "max_digit_numberが1未満の場合" do
          it "バリデーションに引っかかること" do
            element = build(:only_element, max_digit_number: 0, min_digit_number: min_digit_number)
            expect(element).to have(1).errors_on(:max_digit_number)
          end
        end
      end
    end

    describe "validate_numericality_of :min_digit_number" do
      context "max_digit_numberが1以上10000以下の値が入力されている場合" do
        let(:max_digit_number) { 10 }

        context "min_digit_numberがmax_digit_number以下の場合" do
          it "バリデーションに引っかからないこと" do
            element = build(:only_element, min_digit_number: max_digit_number, max_digit_number: max_digit_number)
            expect(element).to have(0).errors_on(:min_digit_number)
          end
        end

        context "min_digit_numberがmax_digit_numberより大きい場合" do
          it "バリデーションに引っかかること" do
            element = build(:only_element, min_digit_number: max_digit_number + 1, max_digit_number: max_digit_number)
            expect(element).to have(1).errors_on(:min_digit_number)
          end
        end
      end

      context "max_digit_numberが10000より大きい値が入力されている場合" do
        let(:max_digit_number) { 10001 }

        context "mid_digit_numberが10000以下の場合" do
          it "バリデーションに引っかからないこと" do
            element = build(:only_element, min_digit_number: 9999, max_digit_number: max_digit_number)
            expect(element).to have(0).errors_on(:min_digit_number)
          end
        end

        context "mid_digit_numberが10000より大きい場合" do
          it "バリデーションに引っかかること" do
            element = build(:only_element, min_digit_number: 10001, max_digit_number: max_digit_number)
            expect(element).to have(1).errors_on(:min_digit_number)
          end
        end
      end

      context "max_digit_numberが1未満の値が入力されている場合" do
        let(:max_digit_number) { 0 }

        context "min_digit_numberが0以上の場合" do
          it "バリデーションに引っかからないこと" do
            element = build(:only_element, min_digit_number: 0, max_digit_number: max_digit_number)
            expect(element).to have(0).errors_on(:min_digit_number)
          end
        end

        context "min_digit_numberが0未満の場合" do
          it "バリデーションに引っかかること" do
            element = build(:only_element, min_digit_number: -1, max_digit_number: max_digit_number)
            expect(element).to have(1).errors_on(:min_digit_number)
          end
        end
      end
    end

    describe "validates inclusion_of :data_input_way" do
      context "elementの入力タイプがcheckbox_templateの場合" do
        Element::DATA_INPUT_WAYS[:checkbox_template].each do |k, v|
          it "#{k}の場合、バリデーションに引っかからないこと" do
            element = build(:element_by_it_checkbox_template, source_id: 1, source_element_id: 1, source_type: "Template", data_input_way: v)
            expect(element).to have(0).errors_on(:data_input_way)
          end
        end

        it "不正な値の場合、バリデーションに引っかかること" do
          v = 500
          element = build(:element_by_it_checkbox_template, source_id: 1, source_element_id: 1, source_type: "Template", data_input_way: v)
          expect(element).to have(1).errors_on(:data_input_way)
        end
      end

      context "elementの入力タイプがcheckbox_vocabularyの場合" do
        Element::DATA_INPUT_WAYS[:checkbox_vocabulary].each do |k, v|
          it "#{k}の場合、バリデーションに引っかからないこと" do
            element = build(:element_by_it_checkbox_vocabulary, source_id: 1, source_type: "Vocabulary::Element", data_input_way: v)
            expect(element).to have(0).errors_on(:data_input_way)
          end
        end

        it "不正な値の場合、バリデーションに引っかかること" do
          v = 500
          element = build(:element_by_it_checkbox_vocabulary, source_id: 1, source_type: "Vocabulary::Element", data_input_way: v)
          expect(element).to have(1).errors_on(:data_input_way)
        end
      end

      context "elementの入力タイプがpulldown_templateの場合" do
        Element::DATA_INPUT_WAYS[:pulldown_template].each do |k, v|
          it "#{k}の場合、バリデーションに引っかからないこと" do
            element = build(:element_by_it_pulldown_template, source_id: 1, source_element_id: 1, source_type: "Template", data_input_way: v)
            expect(element).to have(0).errors_on(:data_input_way)
          end
        end

        it "不正な値の場合、バリデーションに引っかかること" do
          v = 500
          element = build(:element_by_it_pulldown_template, source_id: 1, source_element_id: 1, source_type: "Template", data_input_way: v)
          expect(element).to have(1).errors_on(:data_input_way)
        end
      end

      context "elementの入力タイプがpulldown_vocabularyの場合" do
        Element::DATA_INPUT_WAYS[:pulldown_vocabulary].each do |k, v|
          it "#{k}の場合、バリデーションに引っかからないこと" do
            element = build(:element_by_it_pulldown_vocabulary, source_id: 1, source_type: "Vocabulary::Element", data_input_way: v)
            expect(element).to have(0).errors_on(:data_input_way)
          end
        end

        it "不正な値の場合、バリデーションに引っかかること" do
          v = 500
          element = build(:element_by_it_pulldown_vocabulary, source_id: 1, source_type: "Vocabulary::Element", data_input_way: v)
          expect(element).to have(1).errors_on(:data_input_way)
        end
      end
    end

    describe "validate_presence_of_source_id" do
      before do
        @template = create(:template, service_id: 1)
      end

      context "入力タイプがテンプレートのチェックボックスの場合" do
        before do
          input_type = create(:input_type_checkbox_template)
          @element = build(:only_element, template_id: @template.id, input_type_id: input_type.id)
        end

        it "source_idが空の場合にバリデーションに引っかかること" do
          expect(@element).to have(1).errors_on(:source_id)
        end
      end

      context "入力タイプが語彙のチェックボックスの場合" do
        before do
          input_type = create(:input_type_checkbox_vocabulary)
          @element = build(:only_element, template_id: @template.id, input_type_id: input_type.id)
        end

        it "source_idが空の場合にバリデーションに引っかかること" do
          expect(@element).to have(1).errors_on(:source_id)
        end
      end

      context "入力タイプがテンプレートのプルダウンの場合" do
        before do
          input_type = create(:input_type_pulldown_template)
          @element = build(:only_element, template_id: @template.id, input_type_id: input_type.id)
        end

        it "source_idが空の場合にバリデーションに引っかかること" do
          expect(@element).to have(1).errors_on(:source_id)
        end
      end

      context "入力タイプが語彙のチェックボックスの場合" do
        before do
          input_type = create(:input_type_pulldown_vocabulary)
          @element = build(:only_element, template_id: @template.id, input_type_id: input_type.id)
        end

        it "source_idが空の場合にバリデーションに引っかかること" do
          expect(@element).to have(1).errors_on(:source_id)
        end
      end

      context "入力タイプが他のデータを参照しないデータの場合" do
        before do
          input_type = create(:input_type_line)
          @element = build(:only_element, template_id: @template.id, input_type_id: input_type.id)
        end

        it "source_idが空の場合にバリデーションに引っかからないこと" do
          expect(@element).not_to have(1).errors_on(:source_id)
        end
      end
    end

    describe "validate_presence_of_source_id" do
      before do
        @template = create(:template, service_id: 1)
      end

      context "入力タイプがテンプレートのチェックボックスの場合" do
        before do
          input_type = create(:input_type_checkbox_template)
          @element = build(:only_element, template_id: @template.id, input_type_id: input_type.id, source_id: 1)
        end

        it "source_element_idが空の場合にバリデーションに引っかかること" do
          expect(@element).to have(1).errors_on(:source_element_id)
        end
      end

      context "入力タイプがテンプレートのチェックボックスの場合" do
        before do
          input_type = create(:input_type_pulldown_template)
          @element = build(:only_element, template_id: @template.id, input_type_id: input_type.id, source_id: 1)
        end

        it "source_element_idが空の場合にバリデーションに引っかかること" do
          expect(@element).to have(1).errors_on(:source_element_id)
        end
      end
    end

    describe "#uniqueness_name_valid" do
      before do
        parent_template = create(:template_with_elements)
        @template = create(:template, parent_id: parent_template.id, service_id: 1)
        @element = build(:only_element, template_id: @template.id, name: parent_template.elements.first.name)
      end

      it "親テンプレートに同じ名前の項目があるとバリデーションに引っかかること" do
        expect(@element).to have(1).errors_on(:name)
      end
    end

    describe "#parent_depth_valid" do
      before do
        @template = create(:template)
      end

      context "更新時の場合" do
        before do
          parent_element = create(:only_element, template_id: @template.id)
          child_element = create(:only_element, template_id: @template.id, parent_id: parent_element.id)
          @element = create(:only_element, template_id: @template.id)
          @element.parent_id = child_element.id
        end

        it "親子関係が深さ1以上になるでバリデーションに引っかかること" do
          expect(@element).to have(1).errors_on(:parent_id)
        end
      end
    end

    describe "#change_attribute_valid" do
      before do
        @template = create(:template)
      end

      context "更新時の場合" do
        before do
          @element = create(:only_element, template_id: @template.id)
          create(:element_value, template_id: @template.id, element_id: @element.id)
        end

        it "name属性が変更された際にバリデーションに引っかかること" do
          @element.name = "testtest"
          expect(@element).to have(1).errors_on(:name)
        end

        it "input_type_id属性が変更された際にバリデーションに引っかかること" do
          @element.input_type_id = create(:input_type_pulldown_template).id
          expect(@element).to have(1).errors_on(:input_type_id)
        end

        it "regular_expression_id属性が変更された際にバリデーションに引っかかること" do
          @element.regular_expression_id = 1000
          expect(@element).to have(1).errors_on(:regular_expression_id)
        end

        it "max_digit_number属性が変更された際にバリデーションに引っかかること" do
          @element.max_digit_number = 1000
          expect(@element).to have(1).errors_on(:max_digit_number)
        end

        it "min_digit_number属性が変更された際にバリデーションに引っかかること" do
          @element.max_digit_number = 1000
          @element.min_digit_number = 50
          expect(@element).to have(1).errors_on(:min_digit_number)
        end

        it "parent_id属性が変更された際にバリデーションに引っかかること" do
          @element.parent_id = 1000
          expect(@element).to have(1).errors_on(:parent_id)
        end

        it "required属性が変更された際にバリデーションに引っかかること" do
          @element.required = true
          expect(@element).to have(1).errors_on(:required)
        end

        it "unique属性が変更された際にバリデーションに引っかかること" do
          @element.unique = true
          expect(@element).to have(1).errors_on(:unique)
        end
      end

      context "作成時の場合" do
        before do
          @element = build(:only_element, template_id: @template.id)
        end

        it "name属性が変更された際にバリデーションに引っかからない" do
          @element.name = "testtest"
          expect(@element).not_to have(1).errors_on(:name)
        end

        it "input_type_id属性が変更された際にバリデーションに引っかからない" do
          @element.input_type_id = create(:input_type_pulldown_template).id
          expect(@element).not_to have(1).errors_on(:input_type_id)
        end

        it "regular_expression_id属性が変更された際にバリデーションに引っかからない" do
          @element.regular_expression_id = 1000
          expect(@element).not_to have(1).errors_on(:regular_expression_id)
        end

        it "max_digit_number属性が変更された際にバリデーションに引っかからない" do
          @element.max_digit_number = 1000
          expect(@element).not_to have(1).errors_on(:max_digit_number)
        end

        it "min_digit_number属性が変更された際にバリデーションに引っかからない" do
          @element.max_digit_number = 1000
          @element.min_digit_number = 500
          expect(@element).not_to have(1).errors_on(:min_digit_number)
        end

        it "parent_id属性が変更された際にバリデーションに引っかからない" do
          @element.parent_id = 1000
          expect(@element).not_to have(1).errors_on(:parent_id)
        end

        it "required属性が変更された際にバリデーションに引っかからない" do
          @element.required = true
          expect(@element).not_to have(1).errors_on(:required)
        end

        it "unique属性が変更された際にバリデーションに引っかからない" do
          @element.unique = true
          expect(@element).not_to have(1).errors_on(:unique)
        end
      end
    end

    describe "#multiple_input_valid" do
      before do
        parent = create(:element, multiple_input: true)
        @element = build(:element, parent: parent)
      end

      it "既に複数入力が有効になっている場合変更できないこと" do
        expect(@element).not_to have(1).errors_on(:multiple_input)
      end
    end
  end

  describe "メソッド" do
    describe "#input_conditions" do
      let(:element){create(:element_by_it_line)}
      subject{element.input_conditions}

      it "入力値制限が設定されている場合、その名前が返ること" do
        re = create(:regular_expression)
        element.update(regular_expression: re)
        expect(subject.first).to eq(re.name)
      end

      it "必須項目の場合、'必須項目'が返ること" do
        element.update(required: true)
        expect(subject.first).to eq(Element.human_attribute_name(:required))
      end

      it "ユニークな項目の場合、'ユニーク'が返ること" do
        element.update(unique: true)
        expect(subject.first).to eq(Element.human_attribute_name(:unique))
      end

      it "最大桁数制限がある項目の場合、最大桁数制限を表す文字列が返ること" do
        element.update!(max_digit_number: 5)
        str = Element.human_attribute_name(:max_digit_number)
        str << I18n.t("element.input_conditions.max_digit_number", count: 5)
        expect(subject.first).to eq(str)
      end

      it "最小桁数制限がある項目の場合、最小桁数制限を表す文字列が返ること" do
        element.update!(min_digit_number: 5)
        str = Element.human_attribute_name(:min_digit_number)
        str << I18n.t("element.input_conditions.min_digit_number", count: 5)
        expect(subject.first).to eq(str)
      end
    end

    describe ".change_order" do
      context "正常系" do
        before do
          @template = create(:template_with_elements)
          @ids = @template.elements.pluck(:id).reverse
          Element.change_order(@ids)
        end

        it "display_numberが変更されていること" do
          @ids.each_with_index do |id, idx|
            element = Element.find(id)
            expect(element.display_number).to eq(idx)
          end
        end
      end

      context "異常系" do
        context "Updateで例外が発生した場合" do
          before do
            @template = create(:template_with_elements)
            @ids = @template.elements.pluck(:id).reverse
            Element.stub_chain(:where, :update_all).and_raise(StandardError)
          end

          it "display_numberが変更されていない" do
            Element.change_order(@ids)
            @ids.reverse.each_with_index do |id, idx|
              element = Element.find(id)
              expect(element.display_number).to eq(idx)
            end
          end

          it "falseが返ること" do
            expect(Element.change_order(@ids)).to be_false
          end
        end
      end
    end

    describe "#last_children" do
      let(:element) { create(:element) }

      context "子供が存在する場合" do
        before do
          @children = 3.times.map{ create(:only_element, template_id: element.template.id, parent_id: element.id) }
        end

        it "子供の配列を返すこと" do
          expect(element.last_children).to eq(@children)
        end
      end

      context "子供が存在しない場合" do
        it "自分自身のみの配列を返すこと" do
          expect(element.last_children).to eq([element])
        end
      end
    end

    describe "#reuse_build" do
      let(:template) { create(:template) }
      let(:element) { create(:element, template_id: template.id) }
      let!(:children) { [create(:element, template_id: template.id, parent_id: element.id)] }
      let(:template_id) { 1000 }

      before do
        @element = element.reuse_build(template_id)
      end

      it "template_idが設定されていること" do
        expect(@element.template_id).to eq(template_id)
      end

      it "子要素が一つあること" do
        expect(@element.children.size).to eq(1)
      end
    end

    describe "#reuse" do
      let(:template) { create(:template) }
      let(:element) { create(:element, template_id: template.id) }
      let!(:children) { [create(:element, template_id: template.id, parent_id: element.id)] }
      let(:template_id) { 1000 }

      subject{ element.reuse(template_id) }

      it "子要素を含めて、Elementがが増えること" do
        expect{subject}.to change(Element, :count).by(children.count + 1)
      end
    end

    describe "#selection_of_reference_values" do
      let(:element){create(:element)}
      subject{element.selection_of_reference_values}

      context "関連先がテンプレートの場合" do
        let(:reference_values){
          [
            double(:element_value, record_id: 1, item_number: 1, formatted_value: "A"),
            double(:element_value, record_id: 1, item_number: 2, formatted_value: "B"),
            double(:element_value, record_id: 2, item_number: 1, formatted_value: "C"),
            double(:element_value, record_id: 2, item_number: 2, formatted_value: "D"),
            double(:element_value, record_id: 3, item_number: 2, formatted_value: "F"),
            double(:element_value, record_id: 3, item_number: 1, formatted_value: "E"),
            double(:element_value, record_id: 4, item_number: 1, formatted_value: "G")

          ]
        }
        before do
          element.stub(:source_type){"Template"}
          element.stub(:reference_values){reference_values}
        end

        it "関連先のデータを配列（[項目名, id])の形式で返す。複数データがある場合はitem_numberで並び替えて、カンマ区切りで返すこと" do
          expect(subject).to eq([["A,B", 1], ["C,D", 2], ["E,F", 3], ["G", 4]])
        end
      end

      context "関連先が語彙の場合" do
        let(:reference_values){
          [
            double(:element_value, name: "月", id: 1),
            double(:element_value, name: "火", id: 2),
            double(:element_value, name: "水", id: 3)
          ]
        }
        before do
          element.stub(:source_type){"Vocabulary::Element"}
          element.stub(:reference_values){reference_values}
        end

        it "関連先のデータを配列（[項目名, id])の形式で返す。" do
          expect(subject).to eq([["月", 1], ["火", 2], ["水", 3]])
        end
      end
    end

    describe "#load_values_by_template_ids" do
      let(:template) { create(:template) }
      let(:element) { create(:element, template_id: template.id) }

      before do
        @e_vals = create_list(:element_value, 5, element_id: element.id, template_id: template.id)
        @new_e_vals = build_list(:element_value, 5, element_id: element.id, template_id: template.id)
      end

      it "自身にひもづくElementValue + 指定した新規レコードを返すこと" do
        e_vals = element.load_values_by_template_ids([template.id], @e_vals + @new_e_vals)
        expect(e_vals).to match_array(@e_vals + @new_e_vals)
      end
    end

    describe "#registerable_reference_ids" do
      let(:template) { create(:template) }

      context "Templateを参照する場合" do
        let(:other_template) { create(:template) }
        let(:source_element) { create(:only_element, template: template, template: other_template) }

        let(:element) { create(:element_by_it_checkbox_template, source_element_id: source_element.id, source: other_template) }

        before do
          @ids = []
          3.times do
            t_r = create(:template_record, template_id: other_template.id)
            create(:element_value, record_id: t_r.id, element_id: source_element.id)
            @ids << t_r.id
          end
        end

        it "登録可能なrecord_idを返すこと" do
          expect(element.registerable_reference_ids).to match_array(@ids)
        end
      end

      context "語彙を参照する場合" do
        let(:vocabulary_element) { create(:vocabulary_element_with_values) }
        let(:element) { create(:element_by_it_checkbox_vocabulary, source: vocabulary_element) }

        it "登録可能なVocabulary::ElementValueのIDを返すこと" do
          expect(element.registerable_reference_ids).to eq(vocabulary_element.values.pluck(:id))
        end
      end
    end

    describe "#code_list_values" do
      subject{ element.code_list_values }

      context "入力タイプが値の参照ではない場合" do
        let(:element) { create(:element_by_it_line) }

        it "空の配列が返却されること" do
          expect(subject).to eq([])
        end
      end

      context "入力タイプが参照の場合" do
        context "テンプレート参照の場合" do
          let(:template) { create(:template) }
          let(:source_template) { create(:template) }
          let!(:select_records) { create_list(:tr_with_all_values, 3, template_id: source_template.id) }
          let(:source_element) { source_template.elements.first }
          let(:element) { create(:element_by_it_pulldown_template, template_id: template.id, source: source_template, source_element_id: source_element.id) }

          before do
            input_type = element.input_type
            t_r = build(:template_record, template_id: template.id)
            content_type = input_type.content_class_name.constantize.superclass.to_s
            select_records.each do |record|
              value =  t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: record.id)
              value.build_content(value: record.id, type: input_type.content_class_name)
            end
            t_r.save!
          end

          it "参照先に登録されているデータの選択肢の配列が返ること" do
            expected_values = ElementValue.where(record_id: source_template.all_records.pluck(:id), element_id: element.source_element_id).map(&:formatted_value)
            expect(subject).to match_array(expected_values)
          end
        end

        context "コードリスト参照の場合" do
          let(:vocabulary_element) { create(:vocabulary_element_with_values) }
          let(:element) { create(:element_by_it_pulldown_vocabulary, source: vocabulary_element) }

          it "コードリストの値の配列が返ること" do
            expect(subject).to match_array(vocabulary_element.values.pluck(:name))
          end
        end
      end
    end

    describe "#destroyable?" do
      let(:element) { create(:element) }

      subject{ element.destroyable? }

      context "削除可能な場合" do
        it "trueを返すこと" do
          expect(subject).to be_true
        end
      end

      context "項目のテンプレートを下に作成された拡張テンプレートが存在する場合" do
        before do
          create(:template, parent_id: element.template_id)
        end

        it "falseを返すこと" do
          expect(subject).to be_false
        end
      end


      context "項目が他のテンプレートから参照する際にの表示項目として使用されている場合" do
        before do
          t = create(:template)
          create(:element_by_it_checkbox_template, source: t, source_element_id: element.id)
        end

        it "falseを返すこと" do
          expect(subject).to be_false
        end
      end
    end

    describe "#namespace?" do
      subject{element.namespace?}

      context "selfが保存済みレコードの場合で、childrenがロードされているとき" do
        let(:element) { create(:element) }
        before do
          element.stub(:loaded?){true}
        end
        it "selfに対して子要素がある場合、trueが返ること" do
          create(:element, parent_id: element.id)
          expect(subject).to be_true
        end

        it "selfに対して子要素がない場合、falseが返ること" do
          expect(subject).to be_false
        end
      end

      context "selfが新規レコードの場合" do
        let(:element) { build(:element) }

        it "selfのchildrenアクセッサにデータが入っている場合、trueが返ること" do
          element.children << build(:element)
          expect(subject).to be_true
        end

        it "selfのchildrenアクセッサにデータが入っていない場合、trueが返ること" do
          element.children = []
          expect(subject).to be_false
        end
      end
    end

    describe "#set_display_number" do
      before do
        @template = create(:template_with_elements)
      end

      context "display_numberがnilの場合" do
        before do
          @element = build(:only_element, template_id: @template.id, parent_id: nil)
        end

        it "display_numberの最大値が格納されること" do
          max_num = Element.where(template_id: @template.id, parent_id: nil).maximum(:display_number)
          expect(@element.send(:set_display_number)).to eq(max_num + 1)
        end
      end

      context "親要素が変更された場合" do
        before do
          @element = @template.elements.first
          @element.parent_id = @template.elements.last.id
        end

        it "display_numberの最大値が格納されること" do
          expect(@element.send(:set_display_number)).to eq(0)
        end
      end
    end

    describe "#set_regular_expression_id" do
      let(:regular_expression_id) { 1 }

      before do
        input_type = create(:input_type_line, regular_expression_id: regular_expression_id)
        @element = build(:element, regular_expression_id: nil, input_type_id: input_type.id)
        @element.send(:set_regular_expression_id)
      end

      it "InputTypeに対応するregular_expression_idが格納されること" do
        expect(@element.regular_expression_id).to eq(regular_expression_id)
      end
    end

    describe "#set_value_for_source_type" do
      context "テンプレートから選択する入力タイプの場合" do
        before do
          input_type = create(:input_type_checkbox_template)
          @element = build(:element, source_id: 1, input_type_id: input_type.id)
          @element.send(:set_value_for_source_type)
        end

        it "'Template'がsource_typeに格納されること" do
          expect(@element.source_type).to eq(Template.name)
        end
      end

      context "語彙から選択する入力タイプの場合" do
        before do
          input_type = create(:input_type_checkbox_vocabulary)
          @element = build(:element, source_id: 1, input_type_id: input_type.id)
          @element.send(:set_value_for_source_type)
        end

        it "'Vocabulary::Element'がsource_typeに格納されること" do
          expect(@element.source_type).to eq(Vocabulary::Element.name)
        end

        it "source_element_idカラムがnilであること" do
          expect(@element.source_element_id).to be_nil
        end
      end

      context "日付を選択する入力タイプの場合" do
        before do
          input_type = create(:input_type_dates)
          @element = build(:element, source_id: 1, input_type_id: input_type.id)
          @element.send(:set_value_for_source_type)
        end

        it "source_typeがnilであること" do
          expect(@element.source_type).to be_nil
        end

        it "source_element_idカラムがnilであること" do
          expect(@element.source_element_id).to be_nil
        end
      end
    end

    describe "#data_input_way_checkbox?" do
      let(:element){create(:element)}
      subject{element.data_input_way_checkbox?}
      it "data_input_wayが0の場合、trueが返ること" do
        element.stub(:data_input_way){Element::DATA_INPUT_WAY_CHECKBOX}
        expect(subject).to be_true
      end

      it "data_input_wayが1の場合、falseが返ること" do
        element.stub(:data_input_way){Element::DATA_INPUT_WAY_POPUP}
        expect(subject).to be_false
      end
    end

    describe "#data_input_way_pulldown?" do
      let(:element){create(:element)}
      subject{element.data_input_way_pulldown?}
      it "data_input_wayが0の場合、trueが返ること" do
        element.stub(:data_input_way){Element::DATA_INPUT_WAY_PULLDOWN}
        expect(subject).to be_true
      end

      it "data_input_wayが1の場合、falseが返ること" do
        element.stub(:data_input_way){Element::DATA_INPUT_WAY_POPUP}
        expect(subject).to be_false
      end
    end

    describe "#data_input_way_popup?" do
      let(:element){create(:element)}
      subject{element.data_input_way_popup?}
      it "data_input_wayが1の場合、trueが返ること" do
        element.stub(:data_input_way){Element::DATA_INPUT_WAY_POPUP}
        expect(subject).to be_true
      end

      it "data_input_wayが1以外の場合、falseが返ること" do
        element.stub(:data_input_way){Element::DATA_INPUT_WAY_CHECKBOX}
        expect(subject).to be_false
      end
    end

    describe "#data_input_way_radio?" do
      let(:element){create(:element)}
      subject{element.data_input_way_radio?}
      it "data_input_wayが2の場合、trueが返ること" do
        element.stub(:data_input_way){Element::DATA_INPUT_WAY_RADIO_BUTTON}
        expect(subject).to be_true
      end

      it "data_input_wayが2以外の場合、falseが返ること" do
        element.stub(:data_input_way){Element::DATA_INPUT_WAY_CHECKBOX}
        expect(subject).to be_false
      end
    end

    describe "#reference_values" do
      subject{element.reference_values}

      context "参照先がテンプレートの場合" do
        let(:source){create(:template)}
        let(:source_element){create(:element_by_it_line, template_id: source.id)}

        context "テンプレートが非拡張テンプレートの場合" do
          let(:element){create(:element_by_it_checkbox_template, source: source, source_element_id: source_element.id)}
          let(:values){
            (1..3).map do
              tr = create(:template_record, template_id: source.id)
              c = create(:element_value_line)
              ev = create(:element_value, record_id: tr.id, element_id: source_element.id, template_id: source.id, content: c)
              # 以下ダミー
              dummy_el = create(:element_by_it_line, template_id: source.id)
              create(:element_value, record_id: tr.id, element_id: dummy_el.id, template_id: source.id)
              # 以上ダミー
              ev
            end
          }
          before do
            values
          end

          it "参照先のレコードが返ること" do
            expect(subject).to match_array(values)
          end
        end

        context "テンプレートが拡張テンプレートの場合" do
          let(:child){create(:template, parent_id: source.id, service_id: 1)}
          let(:element){create(:element_by_it_checkbox_template, source: child, source_element_id: source_element.id)}
          let(:values){
            (1..3).map do
              # parent
              tr = create(:template_record, template_id: source.id)
              ev1 = create(:element_value, record_id: tr.id, element_id: source_element.id, template_id: source.id)
              # Child
              tr = create(:template_record, template_id: child.id)
              c = create(:element_value_line)
              ev2 = create(:element_value, record_id: tr.id, element_id: source_element.id, template_id: child.id, content: c)
              # 以下ダミー
              dummy_el = create(:element_by_it_line, template_id: child.id)
              create(:element_value, record_id: tr.id, element_id: dummy_el.id, template_id: child.id)
              dummy_el = create(:element_by_it_line, template_id: source.id)
              create(:element_value, record_id: tr.id, element_id: dummy_el.id, template_id: source.id)
              # 以上ダミー
              [ev1, ev2]
            end.flatten
          }

          it "参照先のレコードが返ること" do
            expect(subject).to match_array(values)
          end
        end
      end

      context "参照先が語彙の場合" do
        let(:source){create(:vocabulary_element)}
        let(:element){create(:element_by_it_checkbox_vocabulary, source: source)}
        before do
          3.times do
            create(:vocabulary_element_value, element_id: source.id)
            dummy_ve = create(:vocabulary_element)
            create(:vocabulary_element_value, element_id: dummy_ve.id)
          end

          element.source = source
        end

        it "関連しているVocabulary::ElementValueが返ること" do
          expect(subject).to match_array(Vocabulary::ElementValue.where(element_id: source.id))
        end
      end
    end

    describe '#calculate_flat_display_numbers' do
      let(:template) { create(:template) }
      let(:element) { create(:element, template_id: template.id) }

      before do
        @children = 3.times.map{ create(:only_element, template_id: element.template.id, parent_id: element.id) }
      end

      subject{element.calculate_flat_display_numbers(0, {})}

      it "並び順の最後が返ること" do
        expect(subject).to eql 3
      end
    end

    describe "#ancestor_available?" do
      let(:template) { create(:template) }
      let(:element) { create(:element, template_id: template.id, parent_id: parent.id) }

      subject{element.ancestor_available?}

      context "親がavailableの場合" do
        let(:parent) { create(:element, available: true) }

        it "trueを返すこと" do
          expect(subject).to be_true
        end
      end

      context "親がavailableでない場合" do
        let(:parent) { create(:element, available: false) }

        it "falseを返すこと" do
          expect(subject).to be_false
        end
      end
    end

    describe "#actually_available?" do
      let(:template) { create(:template) }
      subject{element.actually_available?}

      context "自分がavailableの場合" do
        let(:element) { create(:element, template_id: template.id, parent_id: parent.id, available: true) }

        context "親がavailableの場合" do
          let(:parent) { create(:element, available: true) }

          it "trueを返すこと" do
            expect(subject).to be_true
          end
        end

        context "親がavailableでない場合" do
          let(:parent) { create(:element, available: false) }

          it "falseを返すこと" do
            expect(subject).to be_false
          end
        end
      end

      context "自分がavailableでない場合" do
        let(:element) { create(:element, template_id: template.id, parent_id: parent.id, available: false) }

        context "親がavailableの場合" do
          let(:parent) { create(:element, available: true) }

          it "falseを返すこと" do
            expect(subject).to be_false
          end
        end

        context "親がavailableでない場合" do
          let(:parent) { create(:element, available: false) }

          it "falseを返すこと" do
            expect(subject).to be_false
          end
        end
      end
    end

    describe "#multiple_input_ancestor" do
      let(:template) { create(:template) }
      let(:element) { create(:element, template_id: template.id, parent_id: parent.id) }
      subject{ element.multiple_input_ancestor }

      context "複数入力可能な祖先がいる場合" do
        let(:parent) { create(:element, template_id: template.id, multiple_input: true) }

        it "elementを返す" do
          expect(subject.id).to eql(parent.id)
        end
      end

      context "複数入力可能な祖先がいない場合" do
        let(:parent) { create(:element, template_id: template.id, multiple_input: false) }

        it "nilを返す" do
          expect(subject).to be_nil
        end
      end
    end
  end
end
