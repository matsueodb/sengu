# == Schema Information
#
# Table name: template_records
#
#  id          :integer          not null, primary key
#  template_id :integer
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe TemplateRecord do
  let(:section){create(:section)}
  let(:service){create(:service, section_id: section.id)}
  let(:template){create(:template, service_id: service.id)}
  let(:child_template){create(:template, parent_id: template.id, service_id: service.id)}
  let(:template_record){create(:template_record, template_id: template.id)}

  describe "method" do
    describe "#build_element_values" do
      subject{template_record.build_element_values(template)}
      it "関連するエレメントに対するvaluesがビルドされること" do
        input_type = create(:input_type_line)
        el = create(:element, input_type_id: input_type.id, template_id: template.id)
        template.stub(:all_elements){Element.where("id = ?", el.id)}

        subject
        attr = {
          template_id: template.id,
          element_id: el.id,
          content_type: InputType::TYPE_CLASS_NAME[el.input_type.name].superclass.name
        }.with_indifferent_access

        value = template_record.values.first
        attr.each do |k, v|
          expect(value.attributes[k]).to eq(v)
        end
      end

      context "checkbox_templateのエレメントがある場合" do
        let(:input_type){create(:input_type_checkbox_template)}
        let(:source){create(:template)}
        let(:records){(1..3).map{create(:template_record, template_id: source.id)}}
        let(:el){create(:element, input_type_id: input_type.id, template_id: template.id, source_type: source.id, source_id: source.id, source_element_id: create(:element, template_id: source.id).id)}
        before do
          records
          template.stub(:all_elements){Element.where("id = ?", el.id)}
        end

        it "kindに1から連番値がセットされること" do
          subject
          attr = {
            template_id: template.id,
            element_id: el.id,
            content_type: InputType::TYPE_CLASS_NAME[el.input_type.name].superclass.name
          }.with_indifferent_access

          vals = template_record.values.sort_by{|v|v.kind}
          vals.each.with_index(1) do |val, i|
            ats = val.attributes
            attr.merge(kind: i).each do |k, v|
              expect(ats[k]).to eq(v)
            end
          end
        end
      end

      context "位置情報に関するエレメントがある場合" do
        let(:input_type){create(:input_type_kokudo_location)}
        let(:el){create(:element, input_type_id: input_type.id, template_id: template.id)}

        before do
          template.stub(:all_elements){Element.where("id = ?", el.id)}
        end

        it "kindが経度、緯度に対応する値がセットされること" do
          subject
          attr = {
            template_id: template.id,
            element_id: el.id,
            content_type: InputType::TYPE_CLASS_NAME[el.input_type.name].superclass.name
          }.with_indifferent_access
          ElementValue::KINDS[:kokudo_location].each do |k, kind|
            val = template_record.values.detect{|a|a.kind == kind}
            ats = val.attributes
            attr.merge(kind: kind).each do |k, v|
              expect(ats[k]).to eq(v)
            end
          end
        end
      end
    end

    describe "#sortable_values" do
      let(:values){
        [
          build(:element_value, element_id: 2, kind: 1),
          build(:element_value, element_id: 2, kind: 3),
          build(:element_value, element_id: 1, kind: 3),
          build(:element_value, element_id: 1, kind: 1),
          build(:element_value, element_id: 3, kind: 2),
          build(:element_value, element_id: 1, kind: 2)
        ]
      }

      subject{template_record.sortable_values}

      before do
        template_record.stub(:values){values}
      end

      it "@sortable_valuesが無い場合、self.valuesをelement_id, kindの昇順で並び替えて返すこと" do
        expect(subject).to eq(values.sort{|a,b|[a.element_id, a.kind]<=>[b.element_id, b.kind]})
      end

      it "@sortable_valuesがある場合、その値を返すこと" do
        svs = values[1,3]
        template_record.instance_eval do
          @sortable_values = svs
        end

        expect(subject).to eq(svs)
      end


    end

    describe "#destroyable?" do
      let(:user){create(:super_user)}
      subject{template_record.destroyable?(user)}

      context "引数で渡したユーザがデータの作成者の場合" do
        before do
          template_record.update!(user_id: user.id)
        end
        it "trueが返ること" do
          expect(subject).to be_true
        end
      end

      context "引数で渡したユーザがデータの作成者ではない場合" do
        before{template_record.update!(user_id: create(:editor_user).id)}

        context "テンプレートのサービスの所属とユーザの所属が等しい場合" do
          before{user.update!(section_id: section.id)}

          it "ユーザが管理者の場合、trueが返ること" do
            expect(subject).to be_true
          end

          it "ユーザが所属管理者の場合、trueが返ること" do
            user.update!(authority: User.authorities[:section_manager])
            expect(subject).to be_true
          end

          it "ユーザがデータ登録者の場合、falseが返ること" do
            user.update!(authority: User.authorities[:editor])
            expect(subject).to be_false
          end
        end

        it "テンプレートのサービスの所属とユーザの所属が等しくない場合、falseが返ること" do
          user.update!(section_id: create(:section).id)
          expect(subject).to be_false
        end
      end
    end

    describe "#editable?" do
      let(:user){create(:super_user)}
      subject{template_record.editable?(user)}

      context "引数で渡したユーザがデータの作成者の場合" do
        before do
          template_record.update!(user_id: user.id)
        end
        it "trueが返ること" do
          expect(subject).to be_true
        end
      end

      context "引数で渡したユーザがデータの作成者ではない場合" do
        before{template_record.update!(user_id: create(:editor_user).id)}

        context "テンプレートのサービスの所属とユーザの所属が等しい場合" do
          before{user.update!(section_id: section.id)}

          it "ユーザが管理者の場合、trueが返ること" do
            expect(subject).to be_true
          end

          it "ユーザが所属管理者の場合、trueが返ること" do
            user.update!(authority: User.authorities[:section_manager])
            expect(subject).to be_true
          end

          it "ユーザがデータ登録者の場合、falseが返ること" do
            user.update!(authority: User.authorities[:editor])
            expect(subject).to be_false
          end
        end

        it "テンプレートのサービスの所属とユーザの所属が等しくない場合、falseが返ること" do
          user.update!(section_id: create(:section).id)
          expect(subject).to be_false
        end
      end
    end

    describe "#formatted_value" do
      let(:element){create(:element, template_id: template.id)}
      let(:result){"ABC,DEF,GHI"}
      let(:formatted_values){
        ["ABC", "DEF", "GHI"]
      }
      subject{template_record.formatted_value(element)}

      it "formatted_valuesの戻り値の配列の各要素に対してカンマ区切りでつなげたものが返ること" do
        template_record.stub(:formatted_values){formatted_values}
        expect(subject).to eq(result)
      end
    end

    describe "#formatted_values" do
      let(:element){create(:element, template_id: template.id)}
      let(:result){["ABC","DEF"]}
      let(:record_values){
        [
          double(:element_value, formatted_value: "ABC"),
          double(:element_value, formatted_value: nil),
          double(:element_value, formatted_value: "DEF")
        ]
      }
      subject{template_record.formatted_values(element)}

      it "record_valuesの戻り値の配列の各要素に対して、formatted_valueを実行し、nilを削除したものが返ること" do
        template_record.stub(:record_values_by_element){record_values}
        expect(subject).to eq(result)
      end
    end

    describe "#record_values" do
      let(:ext_from){create(:template, service_id: template.service_id)}
      let(:template2){create(:template, service_id: template.service_id)}
      let(:element){create(:element_by_it_line, template_id: ext_from.id)}

      let(:els){
        [build(:element_by_it_line, template_id: ext_from.id),
        build(:element_by_it_line, template_id: ext_from.id),
        build(:element_by_it_line, template_id: ext_from.id)]
      }

      let(:values){[
        build(:element_value, element: els[0], record_id: template_record.id, template_id: ext_from.id),
        build(:element_value, element: els[1], record_id: template_record.id, template_id: ext_from.id),
        build(:element_value, element: els[2], record_id: template_record.id, template_id: ext_from.id),
        build(:element_value, element: els[0], record_id: template_record.id, template_id: template.id),
        build(:element_value, element: els[1], record_id: template_record.id, template_id: template.id),
        build(:element_value, element: els[2], record_id: template_record.id, template_id: template.id),
        build(:element_value, element: els[0], record_id: template_record.id, template_id: template2.id),
        build(:element_value, element: els[1], record_id: template_record.id, template_id: template2.id),
        build(:element_value, element: els[2], record_id: template_record.id, template_id: template2.id)
      ]}

      before do
        template.update!(parent_id: ext_from.id)
        template2.update!(parent_id: ext_from.id)
      end


      context "引数のtemplateがnilの場合" do
        before do
          template_record.stub(:template){template}
          template.stub(:all_elements){els}
        end

        subject{template_record.record_values}

        context "拡張基のテンプレートに該当のデータがある場合" do
          before do
            @values = values.select{|v|v.template_id == ext_from.id}
            els.each do |el|
              vals = @values.select{|v|v.element == el}
              template_record.stub(:record_values_by_element).with(el, template){vals}
            end
          end

          it "拡張基のtemplate_idをもつElementValueが返ること" do
            expect(subject).to match_array(@values)
          end
        end

        context "拡張基のテンプレートに該当のデータがない場合" do
          context "self.tepmlate_idのデータがある場合" do
            before do
              @values = values.select{|v|v.template_id == template.id}
              els.each do |el|
                vals = @values.select{|v|v.element == el}
                template_record.stub(:record_values_by_element).with(el, template){vals}
              end
            end

            it "self.template_idをもつElementValueが返ること" do
              expect(subject).to match_array(@values)
            end
          end

          context "self.template_idのデータが無い場合" do
            it "空配列が返ること" do
              expect(subject).to be_empty
            end
          end
        end
      end

      context "引数にtemplateが渡されている場合" do
        subject{template_record.record_values(template2)}

        context "引数で渡したテンプレートの拡張基のテンプレートに該当のデータがある場合" do
          before do
            template2.stub(:all_elements){els}
            @values = values.select{|v|v.template_id == ext_from.id}
            els.each do |el|
              vals = @values.select{|v|v.element == el}
              template_record.stub(:record_values_by_element).with(el, template2){vals}
            end
          end

          it "拡張基のtemplate_idをもつElementValueが返ること" do
            expect(subject).to match_array(@values)
          end
        end

        context "引数で渡したテンプレートの拡張基のテンプレートに該当のデータがない場合" do
          context "引数で渡したテンプレートのデータがある場合" do
            before do
              template2.stub(:all_elements){els}
              @values = values.select{|v|v.template_id == template2.id}
              els.each do |el|
                vals = @values.select{|v|v.element == el}
                template_record.stub(:record_values_by_element).with(el, template2){vals}
              end
            end

            it "self.template_idをもつElementValueが返ること" do
              expect(subject).to match_array(@values)
            end
          end

          context "引数で渡したテンプレートのデータが無い場合" do
            it "空配列が返ること" do
              expect(subject).to be_empty
            end
          end
        end
      end
    end

    describe "#record_values_by_element" do
      let(:child_template){create(:template, service_id: service.id, parent_id: template.id)}
      let(:el){create(:element_by_it_line, template_id: template.id)}
      let(:other_el){create(:element_by_it_line, template_id: template.id)}
      let(:tr1){create(:template_record, template_id: template.id)}
      let(:tr2){create(:template_record, template_id: child_template.id)}
      let(:values){
        vals = (1..3).to_a.map do |n|
          [
            build(:element_value, template_id: template.id, element_id: el.id, item_number: n, record_id: tr1.id), # 拡張基のデータ
            build(:element_value, template_id: child_template.id, element_id: el.id, item_number: n, record_id: tr1.id), # 拡張側のデータ
            build(:element_value, template_id: template.id, element_id: other_el.id, item_number: n) # 別のelementのデータ
          ]
        end.flatten
        ElementValue.import(vals)
        ElementValue.all.to_a
      }

      before do
        # let call
        values
      end

      it "取得した値がitem_number順に並んでいること" do
        vals = tr1.record_values_by_element(el, child_template).sort_by(&:item_number)
        expect(tr1.record_values_by_element(el, child_template)).to eq(vals)
      end

      context "引数で渡したテンプレートが拡張テンプレートの場合" do
        subject{tr1.record_values_by_element(el, child_template)}

        it "拡張基テンプレートにデータがある場合はそのデータを返すこと" do
          subject.each do |ev|
            expect(ev.element_id).to eq(el.id)
            expect(ev.template_id).to eq(template.id)
          end
        end

        it "拡張基テンプレートに該当のデータが無く、拡張側にある場合はそのデータを返すこと" do
          ElementValue.where(element_id: el.id, template_id: template.id).destroy_all

          subject.each do |ev|
            expect(ev.element_id).to eq(el.id)
            expect(ev.template_id).to eq(child_template.id)
          end
        end
      end

      context "引数で渡したテンプレートが拡張基のテンプレートの場合" do
        subject{tr1.record_values_by_element(el, template)}

        it "拡張基テンプレートのデータを返すこと" do
          subject.each do |ev|
            expect(ev.element_id).to eq(el.id)
            expect(ev.template_id).to eq(template.id)
          end
        end
      end
    end

    describe "#all_values" do
      let(:child_template){create(:template, service_id: service.id, parent_id: template.id)}
      let(:el){create(:element_by_it_line, template_id: template.id)}
      let(:tr1){create(:template_record, template_id: template.id)}
      let(:tr2){create(:template_record, template_id: child_template.id)}
      let(:values){
        vals = (1..3).to_a.map do |n|
          [
            build(:element_value, template_id: template.id, element_id: el.id, item_number: n, record_id: tr1.id), # 拡張基のデータ
            build(:element_value, template_id: child_template.id, element_id: el.id, item_number: n, record_id: tr1.id), # 拡張側のデータ
            build(:element_value, template_id: child_template.id, element_id: el.id, item_number: n, record_id: tr2.id) # 拡張側のデータ
          ]
        end.flatten
        ElementValue.import(vals)
        ElementValue.all.to_a
      }

      before do
        # let call
        values
      end

      context "引数で渡したテンプレートが拡張テンプレートの場合" do
        subject{tr1.all_values(child_template)}

        it "拡張基と拡張側のデータを返すこと" do
          ids = [template.id, child_template.id]
          subject.each do |ev|
            expect(ev.template_id.in?(ids)).to be_true
          end
        end
      end

      context "引数で渡したテンプレートが拡張基のテンプレートの場合" do
        subject{tr1.all_values(template)}

        it "拡張基と拡張側のデータを返すこと" do
          subject.each do |ev|
            expect(ev.template_id).to eq(template.id)
          end
        end
      end


    end


    describe "#included_by_keyword?" do
      let(:key){"松江"}
      subject{template_record.included_by_keyword?(key)}
      it "キーワードを含むデータがある場合Trueが返ること" do
        el = create(:element_by_it_line, template_id: template.id)
        ev_s = create(:element_value_line, value: "松江城")
        val = create(:element_value, content_type: ElementValue::StringContent.name, content_id: ev_s.id, element_id: el.id)
        template_record.stub(:values){[val]}

        expect(subject).to be_true
      end
    end

    describe "#validation_of_uniqueness_on_import_csv" do
      let(:el_name){"名前"}
      let(:val){"田中一郎"}
      let(:input_type){create(:input_type_line)}
      let(:element){create(:element, name: el_name, input_type_id: input_type.id, template_id: template.id)}
      let(:vals){[build(:element_value_line, value: val)]}

      subject{template_record.validation_of_uniqueness_on_import_csv(element, vals)}

      context "elementが重複不可の場合" do
        before{element.stub(:unique?){true}}

        it "重複する値がある場合、エラーが追加されること" do
          create(:template_record, template_id: template.id)
          evs = create(:element_value_line, value: val)
          create(:element_value, content: evs, element_id: element.id)

          subject
          result = [el_name + I18n.t("errors.messages.taken")]
          expect(template_record.errors[:base]).to eq(result)
        end

        it "重複する値がない場合、エラーが追加されないこと" do
          subject
          result = [el_name + I18n.t("errors.messages.taken")]
          expect(template_record.errors[:base]).to_not eq(result)
        end
      end
    end

    describe "#validation_of_presence" do
      let(:el_name){"名前"}
      let(:input_type){create(:input_type_line)}
      let(:element){create(:element, name: el_name, input_type_id: input_type.id, template_id: template.id)}
      let(:vals){[build(:element_value_line)]}

      subject{template_record.validation_of_presence(element, vals)}

      context "elementが必須項目の場合" do
        before{element.stub(:required?){true}}

        it "値が未入力の場合、エラーが追加されること" do
          ElementValue::Line.any_instance.stub(:value){""}
          subject
          result = [el_name + I18n.t("errors.messages.blank")]
          expect(template_record.errors[:base]).to eq(result)
        end

        it "値が入力されている場合、エラーが追加されないこと" do
          ElementValue::Line.any_instance.stub(:value){"松江城"}
          subject
          result = [el_name + I18n.t("errors.messages.blank")]
          expect(template_record.errors[:base]).to_not eq(result)
        end
      end
    end

    describe "#validation_of_length" do
      let(:el_name){"名前"}
      let(:input_type){create(:input_type_line)}
      let(:element){create(:element, name: el_name, input_type_id: input_type.id, template_id: template.id)}
      let(:vals){[build(:element_value_line)]}

      subject{template_record.validation_of_length(element, vals)}

      context "elementに最大桁数の指定がある場合" do
        context "elementに最小桁数の指定があり、最大桁数と同じ値が設定されている場合" do
          before do
            element.stub(:max_digit_number){5}
            element.stub(:min_digit_number){5}
          end

          it "値の長さがmax_digit_numberの値と等しい場合、エラーが追加されないこと" do
            ElementValue::Line.any_instance.stub(:value){"県立美術館"}
            subject
            result = [el_name + I18n.t("errors.messages.wrong_length", count: 5)]
            expect(template_record.errors[:base]).to_not eq(result)
          end

          it "値の長さがmax_digit_numberの値以上の桁数の場合、エラーが追加されること" do
            ElementValue::Line.any_instance.stub(:value){"小泉八雲記念館"}
            subject
            result = [el_name + I18n.t("errors.messages.wrong_length", count: 5)]
            expect(template_record.errors[:base]).to eq(result)
          end

          it "値の長さがmax_digit_numberの値以下の桁数の場合、エラーが追加されること" do
            ElementValue::Line.any_instance.stub(:value){"松江城"}
            subject
            result = [el_name + I18n.t("errors.messages.wrong_length", count: 5)]
            expect(template_record.errors[:base]).to eq(result)
          end
        end

        context "elementに最小桁数の指定がない場合もしくは、最大桁数と違う値が設定されている場合" do
          before do
            element.stub(:max_digit_number){5}
            element.stub(:min_digit_number){nil}
          end

          it "値の長さがmax_digit_numberの値と等しい場合、エラーが追加されないこと" do
            ElementValue::Line.any_instance.stub(:value){"県立美術館"}
            subject
            result = [el_name + I18n.t("errors.messages.too_long", count: 5)]
            expect(template_record.errors[:base]).to_not eq(result)
          end

          it "値の長さがmax_digit_numberの値以上の桁数の場合、エラーが追加されること" do
            ElementValue::Line.any_instance.stub(:value){"小泉八雲記念館"}
            subject
            result = [el_name + I18n.t("errors.messages.too_long", count: 5)]
            expect(template_record.errors[:base]).to eq(result)
          end

          it "値の長さがmax_digit_numberの値以下の桁数の場合、エラーが追加されないこと" do
            ElementValue::Line.any_instance.stub(:value){"松江城"}
            subject
            result = [el_name + I18n.t("errors.messages.too_long", count: 5)]
            expect(template_record.errors[:base]).to_not eq(result)
          end
        end
      end

      context "elementに最小桁数の指定がある場合" do
        before do
          element.stub(:min_digit_number){5}
        end

        it "値の長さがmin_digit_numberの値と等しい場合、エラーが追加されないこと" do
            ElementValue::Line.any_instance.stub(:value){"県立美術館"}
            subject
            result = [el_name + I18n.t("errors.messages.too_short", count: 5)]
            expect(template_record.errors[:base]).to_not eq(result)
          end

          it "値の長さがmin_digit_numberの値以上の桁数の場合、エラーが追加されないこと" do
            ElementValue::Line.any_instance.stub(:value){"小泉八雲記念館"}
            subject
            result = [el_name + I18n.t("errors.messages.too_short", count: 5)]
            expect(template_record.errors[:base]).to_not eq(result)
          end

          it "値の長さがmin_digit_numberの値以下の桁数の場合、エラーが追加されること" do
            ElementValue::Line.any_instance.stub(:value){"松江城"}
            subject
            result = [el_name + I18n.t("errors.messages.too_short", count: 5)]
            expect(template_record.errors[:base]).to eq(result)
          end
      end
    end

    describe "#validation_by_regular_expression" do
      let(:el_name){"メールアドレス"}
      let(:input_type){create(:input_type_line)}
      let(:element){create(:element, name: el_name, input_type_id: input_type.id, template_id: template.id)}
      let(:vals){[build(:element_value_line)]}
      let(:re){create(:regular_expression_email)}

      subject{template_record.validation_by_regular_expression(element, vals)}

      context "elementに入力形式の指定がある場合" do
        before{element.stub(:regular_expression){re}}

        it "指定した入力形式に沿っていない場合、エラーが追加されること" do
          ElementValue::Line.any_instance.stub(:value){"error_address@test,com"}
          subject
          result = [el_name + I18n.t("errors.messages.invalid")]
          expect(template_record.errors[:base]).to eq(result)
        end

        it "指定した入力形式に沿っている場合、エラーが追加されないこと" do
          ElementValue::Line.any_instance.stub(:value){"error_address@test.com"}
          subject
          result = [el_name + I18n.t("errors.messages.invalid")]
          expect(template_record.errors[:base]).to_not eq(result)
        end
      end
    end

    describe "#validation_of_location" do
      let(:element){create(:element_by_it_google_location, template_id: template.id, name: "住所")}
      let(:vals){
        [
          build(:element_value_google_location_lat),
          build(:element_value_google_location_lon, value: "")
        ]
      }
      subject{template_record.validation_of_location(element, vals)}

      it "経度と緯度の値のうち片方しか入力されていない場合、エラーとする。" do
        subject
        result = [element.name + I18n.t("errors.messages.location.please_enter_both_latitude_and_longitude")]
        expect(template_record.errors[:base]).to eq(result)
      end
    end

    describe "#validation_by_reference_values" do
      let(:element){create(:element_by_it_checkbox_template, template_id: template.id, name: "住所", source_id: 1)}
      let(:registerable_reference_ids) { [1, 2, 3] }
      let(:reference_ids) { [1, 2, 3, 4] }
      let(:vals) {
        reference_ids.map do |id|
          e_v = build(:element_value)
          e_v.build_content(value: id)
          e_v
        end
      }


      before do
        allow(element).to receive(:registerable_reference_ids).and_return(registerable_reference_ids)
        template_record.validation_by_reference_values(element, vals)
      end

      it "登録できないデータが混ざっていた場合、エラーとする" do
        result = [element.name + I18n.t("errors.messages.invalid")]
        expect(template_record.errors[:base]).to eq(result)
      end
    end

    describe "#validation_of_line" do
      let(:element){create(:element_by_it_line, template_id: template.id, name: "名前")}

      context "エラーが発生することの検証" do
        let(:val){"A" * 256}
        let(:vals){
          [build(:element_value_line, value: val)]
        }
        subject{template_record.validation_of_line(element, vals)}

        it "256文字以上の文字が送られた場合、エラーとする" do
          subject
          result = [element.name + I18n.t("errors.messages.line.please_enter_up_to_255_characters")]
          expect(template_record.errors[:base]).to eq(result)
        end
      end

      context "エラーが発生しないことの検証" do
        let(:val){"A" * 255}
        let(:vals){
          [build(:element_value_line, value: val)]
        }
        subject{template_record.validation_of_line(element, vals)}

        it "255文字以下の文字が送られた場合、エラーが発生しないこと" do
          subject
          result = [element.name + I18n.t("errors.messages.line.please_enter_up_to_255_characters")]
          expect(template_record.errors[:base]).to_not eq(result)
        end
      end
    end

    describe "#validation_of_upload_file" do
      let(:element){create(:element_by_it_upload_file, template_id: template.id, name: "ファイル")}
      let(:file) {ActionDispatch::Http::UploadedFile.new({:tempfile => File.new(Rails.root.join('spec', 'files', "csv", 'standard.csv'))})}
      let(:cont1){build(:element_value_upload_file)}
      let(:cont2){build(:element_value_upload_file)}
      let(:val1){build(:element_value, content: cont1, kind: ElementValue::LABEL_KIND)}
      let(:val2){build(:element_value, content: cont2, kind: ElementValue::FILE_KIND)}

      before do
        cont2.stub(:temp){file}
      end

      subject{template_record.validation_of_upload_file(element, [val1, val2])}

      context "エラーが発生することの検証" do
        it "添付したファイルが制限値より大きい場合、エラーとする" do
          max_size = file.size - 1
          Settings.stub_chain(:files, :upload_file, :max_file_size){max_size}
          subject
          count = max_size / 1.megabytes
          result = [element.name + I18n.t("errors.messages.upload_file.less_than_or_equal_to", count: count)]
          expect(template_record.errors[:base]).to eq(result)
        end

        it "ファイルのラベルを入力しているときに、ファイルがアップロードされていない場合、エラーとなること" do
          val2.content = nil
          subject
          result = [element.name + I18n.t("errors.messages.upload_file.please_select_a_file")]
          expect(template_record.errors[:base]).to eq(result)
        end
      end

      context "エラーが発生しないことの検証" do
        it "添付したファイルが制限値より小さい場合、エラーとならないこと" do
          max_size = file.size + 1
          Settings.stub_chain(:files, :upload_file, :max_file_size){max_size}
          subject
          count = max_size / 1.megabytes
          result = [element.name + I18n.t("errors.messages.upload_file.less_than_or_equal_to", count: count)]
          expect(template_record.errors[:base]).to_not eq(result)
        end
      end
    end

    describe "save_from_params!" do
      let(:source_te){create(:template)}
      let(:source_el){create(:element_by_it_line, template_id: source_te.id)}
      let(:source_re1){create(:template_record, template_id: source_te.id)}
      let(:source_re2){create(:template_record, template_id: source_te.id)}
      let(:source_re3){create(:template_record, template_id: source_te.id)}
      let(:ve){create(:vocabulary_element_with_values)}

      let(:e_line)                {create(:element_by_it_line, template_id: template.id)}
      let(:e_multi_line)          {create(:element_by_it_multi_line, template_id: template.id)}
      let(:e_dates)               {create(:element_by_it_dates, template_id: template.id)}
      let(:e_kokudo_location)     {create(:element_by_it_kokudo_location, template_id: template.id)}
      let(:e_osm_location)        {create(:element_by_it_osm_location, template_id: template.id)}
      let(:e_google_location)     {create(:element_by_it_google_location, template_id: template.id)}
      let(:e_upload_file)         {create(:element_by_it_upload_file, template_id: template.id)}
      let(:e_checkbox_template)   {create(:element_by_it_checkbox_template, template_id: template.id, source: source_te, source_element_id: source_el.id)}
      let(:e_pulldown_template)   {create(:element_by_it_pulldown_template, template_id: template.id, source: source_te, source_element_id: source_el.id)}
      let(:e_checkbox_vocabulary) {create(:element_by_it_checkbox_vocabulary, template_id: template.id, source: ve)}
      let(:e_pulldown_vocabulary) {create(:element_by_it_pulldown_vocabulary, template_id: template.id, source: ve)}
      let(:e_times) {create(:element_by_it_times, template_id: template.id)}

      context "データが作成されることの検証" do
        context "１行入力のデータが作成されることの検証" do
          let(:params){{
            e_line.id.to_s => {
              "1" => {"0" => {"value" => "松江城", "template_id" => template.id}},
              "2" => {"0" => {"value" => "松江城城下町", "template_id" => template.id}},
              "3" => {"0" => {"template_id" => template.id}} # valueがないデータは追加されない
            }
          }}
          subject{template_record.save_from_params!(params)}

          it "ElementValueが作成されること" do
            expect{subject}.to change(ElementValue, :count).by(2)
          end

          it "ElementValue::Lineが作成されること" do
            expect{subject}.to change(ElementValue::Line, :count).by(2)
          end
        end

        context "複数行入力のデータが作成されることの検証" do
          let(:params){{
            e_multi_line.id.to_s => {"1" => {"0" => {"value" => "松江城\n松江のお城です。", "template_id" => template.id}}}
          }}
          subject{template_record.save_from_params!(params)}

          it "ElementValueが作成されること" do
            expect{subject}.to change(ElementValue, :count).by(1)
          end

          it "ElementValue::MultiLineが作成されること" do
            expect{subject}.to change(ElementValue::MultiLine, :count).by(1)
          end
        end

        context "日付入力のデータが作成されることの検証" do
          let(:params){{
            e_dates.id.to_s => {"1" => {"0" => {"value" => "2014-04-01", "template_id" => template.id}}}
          }}
          subject{template_record.save_from_params!(params)}

          it "ElementValueが作成されること" do
            expect{subject}.to change(ElementValue, :count).by(1)
          end

          it "ElementValue::Datesが作成されること" do
            expect{subject}.to change(ElementValue::Dates, :count).by(1)
          end
        end

        %w(kokudo_location osm_location google_location).each do |key|
          name = InputType::TYPE_HUMAN_NAME[key]
          klass = "ElementValue::#{key.to_s.camelize}"
          context "#{name}入力のデータが作成されることの検証" do
            let(:el){create(:"element_by_it_#{key}")}
            let(:params){{
              el.id.to_s => {"1" => {
                "1" => {"value" => "35.47633639994709", "template_id" => template.id},
                "2" => {"value" => "133.06639533211944", "template_id" => template.id}
              }}
            }}
            subject{template_record.save_from_params!(params)}

            it "ElementValueが作成されること" do
              expect{subject}.to change(ElementValue, :count).by(2)
            end

            it "#{klass}が作成されること" do
              expect{subject}.to change(klass.constantize, :count).by(2)
            end
          end
        end

        context "ファイル入力のデータが作成されることの検証" do
          let(:csv) {
            ActionDispatch::Http::UploadedFile.new({
              :filename => 'standard.csv',
              :tempfile => File.new(Rails.root.join('spec', 'files', "csv", 'standard.csv'))
            })
          }

          let(:params){{
            e_upload_file.id.to_s => {"1" => {"0" => {"upload_file" => csv, "template_id" => template.id}}}
          }}
          subject{template_record.save_from_params!(params)}

          it "ElementValueが作成されること" do
            expect{subject}.to change(ElementValue, :count).by(1)
          end

          it "ElementValue::UploadFileが作成されること" do
            expect{subject}.to change(ElementValue::UploadFile, :count).by(1)
          end
        end

        context "複数選択（テンプレート）入力のデータが作成されることの検証" do
          let(:params){{
            e_checkbox_template.id.to_s => {"1" => {
              source_re1.id.to_s => {"value" => source_re1.id.to_s, "template_id" => template.id},
              source_re2.id.to_s => {"value" => source_re2.id.to_s, "template_id" => template.id},
            }}
          }}
          subject{template_record.save_from_params!(params)}

          it "ElementValueが作成されること" do
            expect{subject}.to change(ElementValue, :count).by(2)
          end

          it "ElementValue::CheckboxTemplateが作成されること" do
            expect{subject}.to change(ElementValue::CheckboxTemplate, :count).by(2)
          end
        end

        context "単一選択（テンプレート）入力のデータが作成されることの検証" do
          let(:params){{
            e_pulldown_template.id.to_s => {"1" => {
              "0" => {"value" => source_re1.id.to_s, "template_id" => template.id}
            }}
          }}
          subject{template_record.save_from_params!(params)}

          it "ElementValueが作成されること" do
            expect{subject}.to change(ElementValue, :count).by(1)
          end

          it "ElementValue::PulldownTemplateが作成されること" do
            expect{subject}.to change(ElementValue::PulldownTemplate, :count).by(1)
          end
        end

        context "複数選択（語彙）入力のデータが作成されることの検証" do
          let(:vev1){ve.values[0]}
          let(:vev2){ve.values[1]}
          let(:params){{
            e_checkbox_vocabulary.id.to_s => {"1" => {
              vev1.id.to_s => {"value" => vev1.id.to_s, "template_id" => template.id},
              vev2.id.to_s => {"value" => vev2.id.to_s, "template_id" => template.id},
            }}
          }}
          before do
            # let call
            vev1
            vev2
          end

          subject{template_record.save_from_params!(params)}

          it "ElementValueが作成されること" do
            expect{subject}.to change(ElementValue, :count).by(2)
          end

          it "ElementValue::CheckboxVocabularyが作成されること" do
            expect{subject}.to change(ElementValue::CheckboxVocabulary, :count).by(2)
          end
        end

        context "単一選択（語彙）入力のデータが作成されることの検証" do
          let(:vev1){ve.values[0]}
          let(:params){{
            e_pulldown_vocabulary.id.to_s => {"1" => {
              "0" => {"value" => vev1.id.to_s, "template_id" => template.id}
            }}
          }}
          before do
            # let call
            vev1
          end

          subject{template_record.save_from_params!(params)}

          it "ElementValueが作成されること" do
            expect{subject}.to change(ElementValue, :count).by(1)
          end

          it "ElementValue::PulldownVocabularyが作成されること" do
            expect{subject}.to change(ElementValue::PulldownVocabulary, :count).by(1)
          end
        end

        context "時間入力のデータが作成されること" do
          let(:params){{
            e_dates.id.to_s => {"1" => {"0" => {"value" => {"(4i)" => "10", "(5i)" => 15}, "template_id" => template.id}}}
          }}
          subject{template_record.save_from_params!(params)}

          it "ElementValueが作成されること" do
            expect{subject}.to change(ElementValue, :count).by(1)
          end

          it "ElementValue::Datesが作成されること" do
            expect{subject}.to change(ElementValue::Dates, :count).by(1)
          end
        end
      end

      context "既存のデータで、ElementValueのidが送られなかった場合" do
        let(:evl){create(:element_value_line, value: "堀川")}
        let(:ev){create(:element_value, content: evl, record_id: template_record.id, element_id: e_line.id, template_id: template.id)}

        before do
          ev
        end

        let(:params){{
          e_line.id.to_s => {
            "1" => {"0" => {"value" => "松江城", "template_id" => template.id}},
            "2" => {"0" => {"value" => "松江城城下町", "template_id" => template.id}},
            "3" => {"0" => {"template_id" => template.id}} # valueがないデータは追加されない
          }
        }}
        subject{template_record.save_from_params!(params)}

        it "既存のデータが削除されること" do
          id = ev.id
          expect{subject}.to change{ElementValue.exists?(id)}.from(true).to(false)
        end

        it "ElementValueが作成されること" do
          expect{subject}.to change(ElementValue, :count).from(1).to(2)
        end

        it "ElementValue::Lineが作成されること" do
          expect{subject}.to change(ElementValue::Line, :count).from(1).to(2)
        end
      end

      context "既存のデータで、ElementValueのidが送られた場合" do
        let(:evl1){create(:element_value_line, value: "堀川")}
        let(:ev1){create(:element_value, content: evl1, record_id: template_record.id, element_id: e_line.id, template_id: template.id)}
        let(:evl2){create(:element_value_line, value: "記念館")}
        let(:ev2){create(:element_value, content: evl2, record_id: template_record.id, element_id: e_line.id, template_id: template.id)}

        before do
          ev1
          ev2
        end

        let(:params){{
          e_line.id.to_s => {
            "1" => {"0" => {"id" => ev1.id, "content_id" => evl1.id, "value" => "松江城", "template_id" => template.id}},
            "2" => {"0" => {"id" => ev2.id, "content_id" => evl2.id, "template_id" => template.id}}
          }
        }}
        subject{template_record.save_from_params!(params)}

        it "valueがあるものは更新されること" do
          expect{subject}.to change{evl1.reload.value}.from("堀川").to("松江城")
        end

        it "valueがないものは更新されないこと" do
          expect{subject}.to_not change{evl1.reload.value}.from("記念館")
        end
      end

      context "データの更新権限の確認" do
        let(:ext){create(:template, parent_id: template.id)}
        let(:evl1){create(:element_value_line, value: "大阪城")}
        let(:ev1){create(:element_value, content: evl1, record_id: template_record.id, element_id: e_line.id, template_id: template.id)}

        let(:params){
          {e_line.id.to_s => {
            "1" => {"0" => {"id" => ev1.id, "content_id" => evl1.id, "value" => "松江城", "template_id" => template.id}}
          }}
        }

        before do
          ev1
        end

        context "拡張基のデータを拡張基のテンプレートから更新する場合" do
          subject{template_record.save_from_params!(params, template)}

          it "値が更新されること" do
            expect{subject}.to change{evl1.reload.value}.from("大阪城").to("松江城")
          end
        end

        context "拡張基のデータを拡張側のテンプレートから更新する場合" do
          subject{template_record.save_from_params!(params, ext)}

          it "値が更新されないこと" do
            expect{subject}.to_not change{evl1.value}.from("大阪城").to("松江城")
          end
        end
      end
    end

    describe "#item_numbers_by_namespace" do
      let(:input_type){create(:input_type_line)}
      let(:namespace){create(:element, template_id: template.id, multiple_input: true)}
      let(:el){create(:element, input_type_id: input_type.id, template_id: template.id, source_id: 1, source_type: "Template", source_element_id: 1, parent_id: namespace.id)}
      let(:ev_s){create(:element_value_line)}
      let(:count) { 2 }

      subject{template_record.item_numbers_by_namespace}

      before do
        create(:element_value, content_type: InputType::TYPE_CLASS_NAME[el.input_type.name].superclass.name, content_id: ev_s.id, element_id: el.id, repeat_element_id: namespace.id, record_id: template_record.id, item_number: 1)
        create(:element_value, content_type: InputType::TYPE_CLASS_NAME[el.input_type.name].superclass.name, content_id: ev_s.id, element_id: el.id, repeat_element_id: namespace.id, record_id: template_record.id, item_number: 2)
        template_record.reload
      end

      it "繰り返し回数が返ってくること" do
        expect(subject[namespace.id]).to eql(count)
      end
    end

    describe "private" do
      describe "#reject_multiple_records" do
        let(:input_type){create(:input_type_line)}
        let(:el){create(:element, input_type_id: input_type.id, template_id: template.id, source_id: 1, source_type: "Template", source_element_id: 1)}
        let(:ev_s){create(:element_value_line)}
        let(:element_value){create(:element_value, content_type: InputType::TYPE_CLASS_NAME[el.input_type.name].superclass.name, content_id: ev_s.id, element_id: el.id)}

        subject{template_record.send(:reject_multiple_records, element_value.attributes)}

        it "他のデータを参照しないinput_typeの場合、falseが返ること" do
          InputType.any_instance.stub(:referenced_type?){false}
          expect(subject).to be_false
        end

        context "他のデータを参照するinput_typeの場合" do
          before do
            InputType.any_instance.stub(:referenced_type?){true}
          end

          context "引数で渡したattributesにidがない場合" do
            let(:attr){element_value.attributes.reject{|k,v|k == "id"}}
            context "引数attributesで渡したHashの:valueがblank?の場合" do
              subject{template_record.send(:reject_multiple_records, attr)}

              it "trueが返ること" do
                expect(subject).to be_true
              end
            end
          end

          context "引数で渡したattributesにidがある場合" do
            let(:attr){element_value.attributes}
            context "引数attributesで渡したHashの:valueがblank?の場合" do
              subject{template_record.send(:reject_multiple_records, attr)}

              it "falseが返ること" do
                expect(subject).to be_false
              end

              it "attributesに:_destroy=> 1がセットされること" do
                expect{subject}.to change{attr[:_destroy]}.from(nil).to(1)
              end
            end
          end
        end
      end

      describe "#validation_based_on_element" do
        let(:input_type){create(:input_type_line)}
        let(:el){create(:element, input_type_id: input_type.id, template_id: template.id)}
        let(:ev_s){create(:element_value_line)}
        let(:element_value){create(:element_value, content_type: InputType::TYPE_CLASS_NAME[el.input_type.name].superclass.name, content_id: ev_s.id, element_id: el.id)}

        subject{template_record.send(:validation_based_on_element)}

        before do
          element_value
          ev_s
          template_record.stub(:values){ElementValue.all}
        end

        it "validation_of_presenceが呼ばれること" do
          template_record.should_receive(:validation_of_presence)
          subject
        end

        it "validation_of_uniquenessが呼ばれること" do
          template_record.should_receive(:validation_of_uniqueness)
          subject
        end

        it "validation_of_lengthが呼ばれること" do
          template_record.should_receive(:validation_of_length)
          subject
        end

        it "validation_by_regular_expressionが呼ばれること" do
          template_record.should_receive(:validation_by_regular_expression)
          subject
        end

        it "validation_by_reference_valuesが呼ばれること" do
          template_record.should_receive(:validation_by_reference_values)
          subject
        end

        it "validation_of_lineが呼ばれること" do
          template_record.should_receive(:validation_of_line)
          subject
        end

        it "validation_of_upload_fileが呼ばれること" do
          template_record.should_receive(:validation_of_upload_file)
          subject
        end
      end

      describe "#validation_of_uniqueness" do
        let(:el_name){"名前"}
        let(:val){"田中一郎"}
        let(:input_type){create(:input_type_line)}
        let(:element){create(:element, name: el_name, input_type_id: input_type.id, template_id: template.id)}
        let(:vals){[build(:element_value_line, value: val)]}

        subject{template_record.send(:validation_of_uniqueness, element, vals)}

        context "elementが重複不可の場合" do
          before{element.stub(:unique?){true}}

          it "重複する値がある場合、エラーが追加されること" do
            tr = create(:template_record, template_id: template.id)
            evs = create(:element_value_line, value: val)
            ev = create(:element_value, content: evs, element_id: element.id)

            subject
            result = [el_name + I18n.t("errors.messages.taken")]
            expect(template_record.errors[:base]).to eq(result)
          end

          it "重複する値がない場合、エラーが追加されないこと" do
            subject
            result = [el_name + I18n.t("errors.messages.taken")]
            expect(template_record.errors[:base]).to_not eq(result)
          end
        end
      end

    end
  end
end
