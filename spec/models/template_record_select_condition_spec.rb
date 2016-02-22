# == Schema Information
#
# Table name: template_record_select_conditions
#
#  id           :integer          not null, primary key
#  template_id  :integer
#  target_class :string(255)
#  condition    :text
#

require 'spec_helper'

describe TemplateRecordSelectCondition do
  let(:service){create(:service)}
  let(:parent_template){create(:template)}
  let(:template){create(:template, parent_id: parent_template.id, service_id: service.id)}
  
  describe "methods" do
    describe ".make_sqls" do
      {"1行入力" => :line, "複数行入力" => :multi_line}.each do |label, key|
        context "#{label}に対するパラメータが送られた場合" do
          let(:el){create(:"element_by_it_#{key}")}
          let(:cname){"ElementValue::#{key.to_s.camelize}"}
          let(:tname){cname.constantize.table_name}
          let(:value){"松江"}
          context "前方一致が選ばれた場合" do
            let(:params){{condition: {el.id => {"0" => {"string_condition" => "forward_match", "value" => value}}}}}
            let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value LIKE '#{value}%')"}

            subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

            it "戻り値の最初の要素の値1に対応するSQLが返ること" do
              arg1, arg2 = subject.first
              expect(arg1).to eq(sql)
            end

            it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
              arg1, arg2 = subject.first
              expect(arg2).to eq(cname)
            end
          end

          context "後方一致が選ばれた場合" do
            let(:params){{condition: {el.id => {"0" => {"string_condition" => "backward_match", "value" => value}}}}}
            let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value LIKE '%#{value}')"}

            subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

            it "戻り値の最初の要素の値1に対応するSQLが返ること" do
              arg1, arg2 = subject.first
              expect(arg1).to eq(sql)
            end

            it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
              arg1, arg2 = subject.first
              expect(arg2).to eq(cname)
            end
          end

          context "中間一致が選ばれた場合" do
            let(:params){{condition: {el.id => {"0" => {"string_condition" => "middle_match", "value" => value}}}}}
            let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value LIKE '%#{value}%')"}

            subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

            it "戻り値の最初の要素の値1に対応するSQLが返ること" do
              arg1, arg2 = subject.first
              expect(arg1).to eq(sql)
            end

            it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
              arg1, arg2 = subject.first
              expect(arg2).to eq(cname)
            end
          end

          context "完全一致が選ばれた場合" do
            let(:params){{condition: {el.id => {"0" => {"string_condition" => "exact_match", "value" => value}}}}}
            let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value LIKE '#{value}')"}

            subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

            it "戻り値の最初の要素の値1に対応するSQLが返ること" do
              arg1, arg2 = subject.first
              expect(arg1).to eq(sql)
            end

            it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
              arg1, arg2 = subject.first
              expect(arg2).to eq(cname)
            end
          end
        end
      end

      context "日付に対するパラメータが送られた場合" do
        let(:el){create(:"element_by_it_dates")}
        let(:cname){"ElementValue::Dates"}
        let(:tname){cname.constantize.table_name}
        let(:value1){Date.today.strftime("%Y-%m-%d")}
        let(:value2){Date.today.tomorrow.strftime("%Y-%m-%d")}

        context "開始日のみが送られた場合" do
          let(:params){{condition: {el.id => {"0" => {"value" => value1}, "1" => {"value" => nil}}}}}
          let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value >= '#{value1}')"}

          subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

          it "戻り値の最初の要素の値1に対応するSQLが返ること" do
            arg1, arg2 = subject.first
            expect(arg1).to eq(sql)
          end

          it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
            arg1, arg2 = subject.first
            expect(arg2).to eq(cname)
          end
        end

        context "終了日のみが送られた場合" do
          let(:params){{condition: {el.id => {"0" => {"value" => nil}, "1" => {"value" => value2}}}}}
          let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value <= '#{value2}')"}

          subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

          it "戻り値の最初の要素の値1に対応するSQLが返ること" do
            arg1, arg2 = subject.first
            expect(arg1).to eq(sql)
          end

          it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
            arg1, arg2 = subject.first
            expect(arg2).to eq(cname)
          end
        end

        context "開始日と終了日両方が送られた場合" do
          let(:params){{condition: {el.id => {"0" => {"value" => value1}, "1" => {"value" => value2}}}}}
          let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value BETWEEN '#{value1}' AND '#{value2}')"}

          subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

          it "戻り値の最初の要素の値1に対応するSQLが返ること" do
            arg1, arg2 = subject.first
            expect(arg1).to eq(sql)
          end

          it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
            arg1, arg2 = subject.first
            expect(arg2).to eq(cname)
          end
        end
      end

      context "時間入力に対するパラメータが送られた場合" do
        let(:el){create(:"element_by_it_times")}
        let(:cname){"ElementValue::Times"}
        let(:tname){cname.constantize.table_name}
        let(:bt){ElementValue::Times::BASE_DATE}

        context "開始日のみが送られた場合" do
          let(:params){{condition: {el.id => {"0" => {"value" => {"hour" => "10", "min" => "15"}}, "1" => {"value" => {"hour" => nil, "min" => nil}}}}}}
          let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value >= '#{DateTime.new(bt.year, bt.month, bt.day, 10, 15)}')"}

          subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

          it "戻り値の最初の要素の値1に対応するSQLが返ること" do
            arg1, arg2 = subject.first
            expect(arg1).to eq(sql)
          end

          it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
            arg1, arg2 = subject.first
            expect(arg2).to eq(cname)
          end
        end

        context "終了日のみが送られた場合" do
          let(:params){{condition: {el.id => {"1" => {"value" => {"hour" => "10", "min" => "15"}}, "0" => {"value" => {"hour" => nil, "min" => nil}}}}}}
          let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value <= '#{DateTime.new(bt.year, bt.month, bt.day, 10, 15)}')"}

          subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

          it "戻り値の最初の要素の値1に対応するSQLが返ること" do
            arg1, arg2 = subject.first
            expect(arg1).to eq(sql)
          end

          it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
            arg1, arg2 = subject.first
            expect(arg2).to eq(cname)
          end
        end

        context "開始日と終了日両方が送られた場合" do
          let(:params){{condition: {el.id => {"0" => {"value" => {"hour" => "10", "min" => "15"}}, "1" => {"value" => {"hour" => "12", "min" => "30"}}}}}}
          let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value BETWEEN '#{DateTime.new(bt.year, bt.month, bt.day, 10, 15)}' AND '#{DateTime.new(bt.year, bt.month, bt.day, 12, 30)}')"}

          subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

          it "戻り値の最初の要素の値1に対応するSQLが返ること" do
            arg1, arg2 = subject.first
            expect(arg1).to eq(sql)
          end

          it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
            arg1, arg2 = subject.first
            expect(arg2).to eq(cname)
          end
        end
      end

      {"チェックボックス（語彙）" => :checkbox_vocabulary, "プルダウン(語彙）" => :pulldown_vocabulary}.each do |label, key|
        context "#{label}に対するパラメータが送られた場合" do
          let(:ve){create(:vocabulary_element)}
          let(:el){create(:"element_by_it_#{key}", source_type: "Vocabulary::Element", source_id: ve.id)}
          let(:cname){"ElementValue::#{key.to_s.camelize}"}
          let(:tname){cname.constantize.table_name}
          let(:value1){"1"}
          let(:value2){"3"}
          let(:value3){"5"}
          let(:params){{condition: {el.id => {"1" => {"value" => value1}, "3" => {"value" => value2}, "5" => {"value" => value3}}}}}
          let(:sql){"(element_values.element_id = '#{el.id}' AND #{tname}.value IN (#{value1},#{value2},#{value3}))"}

          subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

          it "戻り値の最初の要素の値1に対応するSQLが返ること" do
            arg1, arg2 = subject.first
            expect(arg1).to eq(sql)
          end

          it "戻り値の最初の要素の値2に対象のクラス名が返ること" do
            arg1, arg2 = subject.first
            expect(arg2).to eq(cname)
          end
        end
      end

      context "複数の種類の条件が送られた場合" do
        let(:ve){create(:vocabulary_element)}
        let(:el_line){create(:element_by_it_line)}
        let(:el_mline){create(:element_by_it_multi_line)}
        let(:el_date){create(:element_by_it_dates)}
        let(:el_cve){create(:element_by_it_checkbox_vocabulary, source_type: "Vocabulary::Element", source_id: ve.id)}
        let(:el_pve){create(:element_by_it_pulldown_vocabulary, source_type: "Vocabulary::Element", source_id: ve.id)}
        let(:params){{condition: {
          el_line.id => {"0" => {"string_condition" => "forward_match", "value" => "松江"}},
          el_mline.id => {"0" => {"string_condition" => "middle_match", "value" => "島根"}},
          el_date.id => {"0" => {"value" => "2014-01-01"}},
          el_cve.id => {"1" => {"value" => "1"}, "3" => {"value" => "3"}},
          el_pve.id => {"2" => {"value" => "2"}, "4" => {"value" => "4"}}
        }}}

        subject{TemplateRecordSelectCondition.make_sqls(params[:condition])}

        context "戻り値の1番目の要素の検証" do
          it "１つ名の値で１行入力欄の検索条件SQLが返ること" do
            arg1, arg2 = subject[0]
            sql = "(element_values.element_id = '#{el_line.id}' AND element_value_string_contents.value LIKE '松江%')"
            expect(arg1).to eq(sql)
          end

          it "二つ目の値でElementValue::Lineが返ること" do
            arg1, arg2 = subject[0]
            expect(arg2).to eq("ElementValue::Line")
          end
        end
        
        context "戻り値の2番目の要素の検証" do
          it "１つ名の値で複数行入力欄の検索条件SQLが返ること" do
            arg1, arg2 = subject[1]
            sql = "(element_values.element_id = '#{el_mline.id}' AND element_value_text_contents.value LIKE '%島根%')"
            expect(arg1).to eq(sql)
          end

          it "二つ目の値でElementValue::MultiLineが返ること" do
            arg1, arg2 = subject[1]
            expect(arg2).to eq("ElementValue::MultiLine")
          end
        end
        
        context "戻り値の3番目の要素の検証" do
          it "１つ名の値で日付入力欄の検索条件SQLが返ること" do
            arg1, arg2 = subject[2]
            sql = "(element_values.element_id = '#{el_date.id}' AND element_value_date_contents.value >= '2014-01-01')"
            expect(arg1).to eq(sql)
          end

          it "二つ目の値でElementValue::Datesが返ること" do
            arg1, arg2 = subject[2]
            expect(arg2).to eq("ElementValue::Dates")
          end
        end

        context "戻り値の4番目の要素の検証" do
          it "１つ名の値でチェックボックス（語彙）入力欄の検索条件SQLが返ること" do
            arg1, arg2 = subject[3]
            sql = "(element_values.element_id = '#{el_cve.id}' AND element_value_identifier_contents.value IN (1,3))"
            expect(arg1).to eq(sql)
          end

          it "二つ目の値でElementValue::CheckboxVocabularyが返ること" do
            arg1, arg2 = subject[3]
            expect(arg2).to eq("ElementValue::CheckboxVocabulary")
          end
        end

        context "戻り値の5番目の要素の検証" do
          it "１つ名の値でプルダウン（語彙）入力欄の検索条件SQLが返ること" do
            arg1, arg2 = subject[4]
            sql = "(element_values.element_id = '#{el_pve.id}' AND element_value_identifier_contents.value IN (2,4))"
            expect(arg1).to eq(sql)
          end

          it "二つ目の値でElementValue::PulldownVocabularyが返ること" do
            arg1, arg2 = subject[4]
            expect(arg2).to eq("ElementValue::PulldownVocabulary")
          end
        end
      end
    end
    
    describe ".create_sql" do
      let(:params){{}}
      let(:val1){["id = 1", "ElementValue::Line"]}
      let(:val2){["id = 2", "ElementValue::MultiLine"]}
      subject{TemplateRecordSelectCondition.create_sql(template, params[:condition])}
      
      it "make_sqlsの戻り値をもとにレコードが生成されること" do
        TemplateRecordSelectCondition.stub(:make_sqls){[val1, val2]}
        subject

        first = TemplateRecordSelectCondition.first.attributes
        first.delete("id")
        expect(first).to eq({"template_id" => template.id, "condition" => val1.first, "target_class" => val1.last})
        first = TemplateRecordSelectCondition.last.attributes
        first.delete("id")
        expect(first).to eq({"template_id" => template.id, "condition" => val2.first, "target_class" => val2.last})

      end
    end

    describe ".get_records" do
      let(:el_line){create(:element_by_it_line, template_id: parent_template.id)}
      let(:el_date){create(:element_by_it_dates, template_id: parent_template.id)}
      let(:tr1){
        tr = create(:template_record, template_id: parent_template.id)
        ev_line = create(:element_value_line, value: "松江城")
        ev = create(:element_value, record_id: tr.id, content: ev_line, element_id: el_line.id)

        ev_date = create(:element_value_dates, value: "2014-01-01")
        ev = create(:element_value, record_id: tr.id, content: ev_date, element_id: el_date.id)
        tr
      }

      let(:sqls){[
          ["element_id = #{el_line.id} AND element_value_string_contents.value LIKE '松江%'", "ElementValue::Line"],
          ["element_id = #{el_date.id} AND element_value_date_contents.value >= '2014-01-01'", "ElementValue::Dates"]
        ]}

      before do
        tr1
        %w(小泉八雲記念館 出雲ドーム 出雲大社).each do |val|
          tr = create(:template_record, template_id: parent_template.id)
          evsc = create(:element_value_line)
          ev = create(:element_value, record_id: tr.id, content: evsc, value: val)
        end
      end


      subject{TemplateRecordSelectCondition.get_records(template, {})}

      it "make_sqlsの戻り値のSQLの全ての条件に該当するTemplateRecordを返すこと" do
        TemplateRecordSelectCondition.stub(:make_sqls){sqls}
        expect(subject.map(&:id)).to eq([tr1.id])
      end
    end
  end
end
