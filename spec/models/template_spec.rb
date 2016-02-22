# == Schema Information
#
# Table name: templates
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  user_id       :integer
#  user_group_id :integer
#  service_id    :integer
#  parent_id     :integer
#  status        :integer          default(1)
#

require 'spec_helper'

describe Template do
  let(:user){create(:editor_user)}
  let(:service){create(:service)}
  let(:template){create(:template, user_id: user.id)}

  describe "association" do
    it {should have_many(:template_records).dependent(:destroy) } # .autosaveがundefineとなる
    it {should have_many(:elements).dependent(:destroy) }
    it {should have_many(:element_values).dependent(:destroy) }
    it {should have_many(:template_record_select_conditions).dependent(:destroy) }
    it {should belong_to(:user)}
    it {should belong_to(:user_group)}
    it {should belong_to(:service)}
    it {should belong_to(:parent).class_name("Template")}
    it {should have_many(:extensions).class_name("Template").dependent(:destroy)}
    it {should have_many(:referenced_elements).class_name("Element")}
  end

  describe "scope" do
    describe "extensions" do
      subject{Template.extensions}
      it "parent_idがNOT nilのものが返ること" do
        3.times do
          pa = create(:template)
          create(:template, parent_id: pa.id, service_id: 1)
        end

        subject.each do |tp|
          expect(tp.parent_id).to_not be_nil
        end
      end
    end

    describe "masters" do
      subject{Template.masters}
      it "parent_idがnilのものが返ること" do
        3.times do
          pa = create(:template)
          create(:template, parent_id: pa.id, service_id: 1)
        end

        subject.each do |tp|
          expect(tp.parent_id).to be_nil
        end
      end
    end

    describe "in_service" do
      subject{Template.in_service}
      it "service_idがnil以外のもの" do
        3.times do
          create(:template, service_id: 1)
          create(:template)
        end

        subject.each do |tp|
          expect(tp.service_id).to_not be_nil
        end
      end
    end

    describe "privates" do
      subject{Template.privates}
      it "service_idがnilのもの" do
        3.times do
          create(:template, service_id: 1)
          create(:template)
        end

        subject.each do |tp|
          expect(tp.service_id).to be_nil
        end
      end
    end

    describe "displayables" do
      subject{Template.displayables(user)}

      context "ユーザグループが設定されているテンプレートがない場合" do
        let(:service) { create(:service, section_id: section.id) }
        let(:section) { create(:section) }
        let(:user){create(:editor_user, section_id: section.id)}

        before do
          @templates = create_list(:template, 10, service_id: service.id)
        end

        it "引数で渡したユーザの所属のサービス内のテンプレートを返すこと" do
          expect(subject.to_a).to match_array(@templates)
        end
      end

      context "ユーザグループが設定れているテンプレートがある場合" do
        let(:service) { create(:service, section_id: another_section.id) }
        let(:another_section) { create(:section) }
        let(:another_user){create(:editor_user, section_id: another_section.id)}

        let(:user){create(:editor_user)}

        before do
          group = create(:user_group, section_id: another_section.id)
          group.users << user
          @templates = create_list(:template, 10, service_id: service.id, user_group_id: group.id)
        end

        it "自分が追加されているグループにが割り当てられているテンプレートを返すこと" do
          expect(subject.to_a).to match_array(@templates)
        end
      end
    end
  end

  describe "validation" do
    it {should validate_presence_of :name}
    it {should ensure_length_of(:name).is_at_most(255) }
    it {should validate_presence_of :service_id}

    describe "#validate_change_service_id" do
      let(:source){create(:template, service_id: service.id)}
      let(:sel){create(:element_by_it_line, template_id: source.id)}
      let(:other_service){create(:service)}

      subject{
        template.attributes = {service_id: 0}
        template
      }

      before do
        template.update(service_id: service.id)
      end

      it "他のテンプレートから参照されていない場合で、他のテンプレートを参照していない場合、エラーが追加されないこと" do
        expect(subject).to have(0).error_on(:service_id)
      end

      it "他のテンプレートから参照されている場合、service_idが変更できないこと" do
        el = create(:element_by_it_line, template_id: template.id)
        create(:element_by_it_checkbox_template, source: template, source_element_id: el.id, template_id: source.id)
        expect(subject).to have(1).error_on(:service_id)
      end

      it "他のテンプレートを参照している場合、service_idが変更できないこと" do
        create(:element_by_it_checkbox_template, source: source, source_element_id: sel.id, template_id: template.id)
        expect(subject).to have(1).error_on(:service_id)
      end
    end

    describe "#validate_change_user_group_id" do
      let(:user_group){create(:user_group)}
      subject{
        template.attributes = {user_group_id: 0}
        template
      }

      before do
        template.update(user_group_id: user_group.id)
      end

      context "user_group_idを変更したとき" do
        it "テンプレートにデータが存在しない場合、エラーが追加されないこと" do
          ElementValue.where(template_id: template.id).destroy_all
          expect(subject).to have(0).error_on(:user_group_id)
        end

        it "テンプレートにデータが存在する場合、エラーが追加されること" do
          tr = create(:template_record, template_id: template.id)
          create(:element_value, template_id: template.id, record_id: tr.id)
          expect(subject).to have(1).error_on(:user_group_id)
        end
      end
    end
  end

  describe "method" do
    describe "#creator?" do
      subject{template.creator?(user)}

      it "user_id==nilの場合、falseが返ること" do
        template.stub(:user_id){nil}
        expect(subject).to be_false
      end

      it "user_id!=nilの場合、trueが返ること" do
        template.stub(:user_id){user.id}
        expect(subject).to be_true
      end
    end

    describe "#has_service?" do
      subject{template.has_service?}

      it "service_id==nilの場合、falseが返ること" do
        template.stub(:service_id){nil}
        expect(subject).to be_false
      end

      it "service_id!=nilの場合、trueが返ること" do
        template.stub(:service_id){1}
        expect(subject).to be_true
      end
    end

    describe "#has_parent?" do
      subject{template.has_parent?}

      it "parent_id==nilの場合、falseが返ること" do
        template.stub(:parent_id){nil}
        expect(subject).to be_false
      end

      it "parent_id!=nilの場合、trueが返ること" do
        template.stub(:parent_id){1}
        expect(subject).to be_true
      end
    end

    describe "#has_user_group?" do
      subject{template.has_user_group?}

      it "user_group_id==nilの場合、falseが返ること" do
        template.stub(:user_group_id){nil}
        expect(subject).to be_false
      end

      it "user_group_id!=nilの場合、trueが返ること" do
        template.stub(:user_group_id){1}
        expect(subject).to be_true
      end
    end

    describe "#has_extension?" do
      subject{template.has_extension?}

      it "selfの拡張テンプレートがある場合、trueが返ること" do
        template.stub(:extensions){Template.all}
        expect(subject).to be_true
      end

      it "selfの拡張テンプレートがない場合、falseが返ること" do
        template.stub(:extensions){Template.where("id IS NULL")}
        expect(subject).to be_false
      end
    end

    describe "#all_records" do
      context "拡張していないテンプレートの場合" do
        let(:records1){(1..3).map{create(:template_record, template_id: template.id)}}
        let(:options){{includes: {values: :element}}}
        before do
          options
          records1
        end

        subject{template.all_records}

        it "selfのリレーションしているTemplateRecordが返ること" do
          expect(subject).to match_array(records1)
        end
      end

      context "拡張しているテンプレートの場合" do
        let(:el1){create(:element_by_it_line, template_id: template.id)}
        let(:child){create(:template, parent_id: template.id, service_id: service.id)}
        let(:child_records){(1..3).map{create(:template_record, template_id: child.id)}}

        let(:parent_records1){[
          create(:template_record, template_id: template.id, values: [create(:element_value, element_id: el1.id, template_id: template.id, content: create(:element_value_line, value: "松江城"))]),
          create(:template_record, template_id: template.id, values: [create(:element_value, element_id: el1.id, template_id: template.id, content: create(:element_value_line, value: "松江城下町"))])
        ]}
        let(:parent_records2){[
          create(:template_record, template_id: template.id, values: [create(:element_value, element_id: el1.id, template_id: template.id, content: create(:element_value_line, value: "八重垣神社"))]),
          create(:template_record, template_id: template.id, values: [create(:element_value, element_id: el1.id, template_id: template.id, content: create(:element_value_line, value: "県立美術館"))])
        ]}

        before do
          parent_records1
          parent_records2
          child_records
          child
        end

        context "拡張時の取得条件を設定している場合" do
          before do
            create(:template_record_select_condition, template_id: child.id,
              target_class: "ElementValue::Line",
              condition: "element_values.element_id = #{el1.id} AND element_value_string_contents.value LIKE '%松江%'")
          end

          subject{child.all_records}

          it "拡張時の取得条件に一致するデータもしくは、self.template_idをtemplate_idにもつTemplateRecordが返ること" do
            expect(subject.order("id DESC").to_a).to eq((child_records + parent_records1).sort_by{|tr|-tr.id})
          end
        end

        context "拡張時の取得条件を設定していない場合" do
          subject{child.all_records}

          it "selfのテンプレートで作成したデータおよび、拡張基のデータが全て取得されること" do
            expect(subject.order("id DESC").to_a).to eq((child_records + parent_records1 + parent_records2).sort_by{|tr|-tr.id})
          end
        end
      end
    end

    describe "#all_elements" do
      let(:elements1){(1..3).map{create(:element, template_id: template.id)}}
      let(:options){{includes: [:input_type, :template]}}
      before do
        options
        elements1
      end
      context "拡張していないテンプレートの場合" do
        subject{template.all_elements}

        it "selfのリレーションしているTemplateRecordが返ること" do
          expect(subject).to eq(elements1)
        end
      end

      context "拡張しているテンプレートの場合" do
        let(:child){create(:template, parent_id: template.id, service_id: service.id)}
        let(:elements2){(1..3).map{create(:element, template_id: child.id)}}

        before do
          elements2
        end

        subject{child.all_elements}

        it "selfのリレーションしているTemplateRecordと親テンプレートのTemplateRecordが返ること" do
          expect(subject).to eq(elements1 + elements2)
        end
      end
    end

    describe "#operator?" do
      let(:template) { create(:template, service_id: service.id) }
      subject{template.operator?(user)}

      context "自分の所属のサービス内のテンプレートの場合" do
        let(:service) { create(:service, section_id: section.id) }
        let(:section) { create(:section) }

        context "引数で渡されたユーザが所属の管理者の場合" do
          let(:user) { create(:section_manager_user, section_id: section.id) }

          it "trueが返ること" do
            expect(subject).to be_true
          end
        end

        context "引数で渡されたユーザが管理者の場合" do
          let(:user) { create(:super_user, section_id: section.id) }

          it "trueが返ること" do
            expect(subject).to be_true
          end
        end

        context "引数で渡されたユーザがデータ登録者の場合" do
          let(:user) { create(:editor_user, section_id: section.id) }

          it "trueが返ること" do
            expect(subject).to be_false
          end
        end
      end

      context "自分の所属のサービス内のテンプレートではない場合" do
        let(:service) { create(:service, section_id: section.id) }
        let(:section) { create(:section) }
        let(:another_user) { create(:section_manager_user, section_id: section.id) }
        let(:user) { create(:section_manager_user) }

        it "falseが返ること" do
          expect(subject).to be_false
        end
      end
    end

    describe "#destroyable?" do
      subject{template.destroyable?(user)}

      it "操作権限が無い場合、falseが返ること" do
        template.stub(:operator?){false}
        expect(subject).to be_false
      end

      context "操作権限がある場合" do
        before{template.stub(:operator?){true}}

        it "他のテンプレートから関連付けされている場合、falseが返ること" do
          template.stub(:related_reference?){true}
          expect(subject).to be_false
        end

        context "他のテンプレートから関連づけされていない場合" do
          before{template.stub(:related_reference?){false}}

          it "拡張テンプレートが存在する場合、falseが返ること" do
            template.stub(:has_extension?){true}
            expect(subject).to be_false
          end

          it "拡張テンプレートが存在しない場合、trueが返ること" do
            template.stub(:has_extension?){false}
            expect(subject).to be_true
          end
        end
      end
    end

    describe "#related_reference?" do
      subject{template.related_reference?}

      it "Elementにsource_type=='Template'&&source_id=self.idのレコードがある場合Trueが返ること" do
        input_type = create(:input_type_checkbox_template)
        create(:element, template_id: template.id, source_type: Template.name, source_id: template.id, input_type_id: input_type.id, source_element_id: create(:element, template_id: template.id).id)
        expect(subject).to be_true
      end

      it "Elementにsource_type=='Template'&&source_id=self.idのレコードが無い場合falseが返ること" do
        expect(subject).to be_false
      end
    end

    describe "#status_label" do
      it "status==0の場合、非公開を表す文字列が返ること" do
        result = I18n.t("activerecord.attributes.template.status_label.close")
        expect(Template.status_label(Template.statuses[:close])).to eq(result)
      end

      it "status==1の場合、公開を表す文字列が返ること" do
        result = I18n.t("activerecord.attributes.template.status_label.publish")
        expect(Template.status_label(Template.statuses[:publish])).to eq(result)
      end
    end

    describe ".extension?" do
      subject{template.extension?}

      it "拡張テンプレートでは無い場合、falseが返ること" do
        template.stub(:parent_id){nil}
        expect(subject).to be_false
      end

      it "拡張テンプレートの場合、trueが返ること" do
        template.stub(:parent_id){1}
        expect(subject).to be_true
      end
    end

    describe "#add_extension?" do
      subject{template.add_extension?}

      before{template.stub(:has_service?){false}}

      it "拡張テンプレートの場合、falseが返ること" do
        template.update!(parent_id: create(:template).id)
        expect(subject).to be_false
      end

      it "拡張テンプレートではない場合、trueが返ること" do
        template.update!(parent_id: nil)
        expect(subject).to be_true
      end
    end

    describe "#same_service_templates" do
      let(:service) { create(:service) }
      let(:template) { create(:template, service_id: service.id) }

      subject{ template.same_service_templates(include_self) }

      context "引数がtrueの場合" do
        let(:include_self) { true }

        before do
          @templates = create_list(:template, 5, service_id: service.id)
          @templates << template
        end

        it "自分を含んだ同じサービス内のテンプレートを取得すること" do
          expect(subject).to match_array(@templates)
        end
      end

      context "引数がfalseの場合" do
        let(:include_self) { false }

        before do
          @templates = create_list(:template, 5, service_id: service.id)
        end

        it "自分を含まない同じサービス内のテンプレートを取得すること" do
          expect(subject).to match_array(@templates)
        end
      end
    end

    describe "#editable_of_service?" do
      subject{template.editable_of_service?}

      it "新規レコードの場合、trueが返ること" do
        template.stub(:new_record?){true}
        expect(subject).to be_true
      end

      context "既存のレコードの場合" do
        it "拡張テンプレートが存在する場合、falseが返ること" do
          create(:template, service_id: service.id, parent_id: template.id)
          expect(subject).to be_false
        end

        context "拡張テンプレートが存在しない場合" do

          it "関連づけをされていない場合、trueが返ること" do
            expect(subject).to be_true
          end

          it "関連づけをされている場合、falseが返ること" do
            input_type = create(:input_type_checkbox_template)
            source_element_id = create(:element, template_id: template.id).id
            create(:element, template_id: template.id, source_id: template.id, source_type: Template.name, input_type_id: input_type.id, source_element_id: source_element_id)
            expect(subject).to be_false
          end
        end
      end
    end

    describe "#editable_of_user_group?" do
      subject{template.editable_of_user_group?}

      it "テンプレートにデータがある場合、falseが返ること" do
        create(:element_value, template_id: template.id)
        expect(subject).to be_false
      end

      it "テンプレートにデータがない場合、trueが返ること" do
        expect(subject).to be_true
      end
    end

    describe "#included_by_keyword?" do
      let(:key){"Test keyword"}
      let(:record){create(:template_record, template_id: template.id)}

      before do
        record # let call
      end

      subject{template.included_by_keyword?(key)}

      it "登録されているデータの整形した値に引数で渡した値が含まれる場合trueを返すこと" do
        TemplateRecord.any_instance.stub(:included_by_keyword?).with(key){true}
        expect(subject).to be_true
      end

      it "登録されているデータの整形した値に引数で渡した値が含まれない場合falseを返すこと" do
        TemplateRecord.any_instance.stub(:included_by_keyword?).with(key){false}
        expect(subject).to be_false
      end
    end

    describe "#included_by_keyword_records" do
      let(:key){"Test keyword"}
      let(:true_records){(1..3).map{create(:template_record, template_id: template.id)}}
      let(:false_records){(1..3).map{create(:template_record, template_id: template.id)}}

      before do
        true_records.each{|a|a.stub(:included_by_keyword?){true}}
        false_records.each{|a|a.stub(:included_by_keyword?){false}}
        template.stub(:template_records){true_records + false_records}
      end

      subject{template.included_by_keyword_records(key)}

      it "登録されているデータの整形した値に引数で渡した値が含まれるTemplateRecordを返すこと" do
        expect(subject).to eq(true_records)
      end
    end

    describe "#convert_csv_format" do
      let(:template) { create(:template_with_elements) }

      before do
        els = template.inputable_elements{|e| e.includes(:input_type, :regular_expression)}
        @csv = CSV.generate('', encoding: 'SJIS'){|csv| csv << els.map(&:name).unshift(ImportCSV::ID_COL_NAME)}.kconv(Kconv::SJIS,Kconv::UTF8)
      end

      it "正しいフォーマットを出力していること" do
        expect(template.convert_csv_format).to eq(@csv)
      end

      it "Shift-JISエンコーディングをしていること" do
        expect(template.convert_csv_format.encoding.to_s).to eq('Shift_JIS')
      end
    end

    describe "#convert_records_csv" do
      let(:template) { create(:template) }

      before do
        create(:tr_with_all_values, template_id: template.id)
      end

      it "Shift-JISエンコーディングをしていること" do
        expect(template.convert_records_csv.encoding.to_s).to eq('Shift_JIS')
      end

      it "ヘッダーの出力結果のCSVが正しいこと" do
        header = CSV.parse(template.convert_records_csv.kconv(Kconv::UTF8, Kconv::SJIS)).first
        expected_header = template.inputable_elements.map(&:name).unshift(ImportCSV::ID_COL_NAME)
        expect(header).to eq(expected_header)
      end

      # CSVの中身は全入力タイプのパターンを手動と目視でテスト済み
    end

    describe '#records_referenced_from_element' do
      let(:records){(1..3).map{create(:template_record, template_id: template.id)}}
      before do
        template.stub(:template_records){records}
      end

      subject{template.records_referenced_from_element}
      it "Elementから実際に参照されるデータを返す。（template_records）" do
        expect(subject).to eq(records)
      end
    end

    describe "#close?" do
      subject{template.close?}

      it "status==0の場合、trueが返ること" do
        template.stub(:status){Template.statuses[:close]}
        expect(subject).to be_true
      end

      it "status==1の場合、falseが返ること" do
        template.stub(:status){Template.statuses[:publish]}
        expect(subject).to be_false
      end
    end

    describe ".change_order" do
      let(:templates){
        list = (0..5).to_a.map{|n|build(:template, service_id: service.id, display_number: n)}
        Template.import(list)
        Template.where(service_id: service.id).order("display_number")
      }

      let(:ids){templates.map(&:id).reverse}

      before do
        ids # let call
      end

      subject{Template.change_order(service, ids)}

      context "正常系" do
        it "display_numberが変更されていること" do
          subject
          ids.each_with_index do |id, idx|
            tp = Template.find(id)
            expect(tp.display_number).to eq(idx)
          end
        end

        it "trueが返ること" do
          expect(subject).to be_true
        end
      end

      context "異常系" do
        context "Updateで例外が発生した場合" do
          before do
            Template.stub_chain(:where, :update_all).and_raise(StandardError)
          end

          it "display_numberが変更されていない" do
            subject
            ids.reverse.each_with_index do |id, idx|
              tp = Template.find(id)
              expect(tp.display_number).to eq(idx)
            end
          end

          it "falseが返ること" do
            expect(subject).to be_false
          end
        end
      end
    end

    describe '#calculate_flat_display_numbers' do
      let(:template) { create(:template_with_elements) }
      subject{template.calculate_flat_display_numbers}

      describe "root要素しかない場合" do
        it "並び順が計算されること" do
          expect(subject).to include template.elements.root.each.with_index.each_with_object({}) {|(v,i), hash| hash[v.id] = i + 1 }
        end
      end

      describe "root要素が子要素を持つ場合、並び順が計算されること" do
        # 要素1
        # ┗要素1_1
        # 要素2
        # ┗要素2_1
        # 要素3
        # ┗要素3_1
        before do
          template.elements.root.each do |root|
            root.children << create(:only_element)
          end
          @expected = { }
          number = 0
          template.elements.root.each do |root|
            @expected[root.id] = number +=1
            root.children.each do |child|
              @expected[child.id] = number += 1
            end
          end
        end

        it "並び順が計算されること" do
          expect(subject).to include @expected
        end
      end
    end

    describe "#about_url_for_rdf" do
      let(:template) { create(:template) }

      it "自分自身のデータ一覧のURLを返すこと" do
        expect(template.about_url_for_rdf).to eq(Rails.application.routes.url_helpers.template_records_path(template))
      end
    end

    describe "private" do
      describe "#validate_change_service_id" do
        let(:source){create(:template, service_id: service.id)}
        let(:sel){create(:element_by_it_line, template_id: source.id)}
        let(:other_service){create(:service)}
        let(:msg){Template.human_attribute_name(:service_id) + I18n.t("errors.messages.template.service_id.it_cannot_be_changed_because_it_is_related")}

        subject{
          template.attributes = {service_id: 0}
          template.valid?
          template.errors.full_messages.first
        }

        before do
          template.update!(service_id: service.id)
        end

        it "他のテンプレートから参照されていない場合で、他のテンプレートを参照していない場合、エラーが追加されないこと" do
          expect(subject).to_not eq(msg)
        end

        it "他のテンプレートから参照されている場合、エラーが追加されること" do
          el = create(:element_by_it_line, template_id: template.id)
          create(:element_by_it_checkbox_template, source: template, source_element_id: el.id, template_id: source.id)
          expect(subject).to eq(msg)
        end

        it "他のテンプレートを参照している場合、エラーが追加されること" do
          create(:element_by_it_checkbox_template, source: source, source_element_id: sel.id, template_id: template.id)
          expect(subject).to eq(msg)
        end
      end

      describe "#validate_user_group_id" do
        let(:user_group){create(:user_group)}
        let(:msg){Template.human_attribute_name(:user_group_id) + I18n.t("errors.messages.template.user_group_id.it_cannot_be_changed_because_it_has_the_data")}

        subject{
          template.attributes = {user_group_id: 0}
          template.valid?
          template.errors.full_messages.first
        }

        before do
          template.update!(user_group_id: user_group.id)
        end

        it "テンプレートにデータが存在しない場合、エラーが追加されないこと" do
          ElementValue.where(template_id: template.id).destroy_all
          expect(subject).to_not eq(msg)
        end

        it "テンプレートにデータが存在する場合、エラーが追加されること" do
          tr = create(:template_record, template_id: template.id)
          create(:element_value, template_id: template.id, record_id: tr.id)
          expect(subject).to eq(msg)
        end
      end

      describe "#set_display_number" do
        before do
          create(:template, service_id: service.id)
        end

        context "display_numberがnilの場合" do
          before do
            @temp = build(:template, service_id: service.id)
          end

          it "display_numberの最大値が格納されること" do
            max_num = Template.where(service_id: service.id).maximum(:display_number)
            expect(@temp.send(:set_display_number)).to eq(max_num + 1)
          end
        end
      end
    end
  end
end
