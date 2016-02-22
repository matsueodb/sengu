require 'spec_helper'
require 'kconv'
require 'csv'

describe ImportCSV do
  describe "バリデーション" do
    let(:template) { create(:template) }
    let(:user) { create(:super_user) }

    describe "#header_valid" do
      let(:csv_content) { '観光施設名, 観光種類名, 観光住所' }

      before do
        3.times{ create(:only_element, template_id: template.id) }
        @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
      end

      it "ヘッダーが実際の要素と異なる場合バリデーションに引っかかること" do
        expect(@import_csv).to have(1).errors_on(:header)
      end
    end

    describe "#rows_valid" do
      let(:csv_content) { "id,観光施設名,観光種類名,観光住所\n,美術館" }

      before do
        3.times{ create(:only_element, template_id: template.id) }
        @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
      end

      it "ヘッダーの数と行のデータの数が異なる場合" do
        expect(@import_csv).to have(1).errors_on(:csv)
      end
    end
  end

  describe "メソッド" do
    let(:template) { create(:template) }
    let(:user) { create(:super_user) }

    describe "#initialize" do
      context "userとtemplateのみの指定の場合" do
        it "csvがパースされないこと" do
          expect_any_instance_of(ImportCSV).not_to receive(:parse_csv)
          @import_csv = ImportCSV.new(user: user, template: template)
        end
      end

      context "csv属性の指定があった場合" do
        let(:csv_content) { '観光施設名, 観光種類名, 観光住所' }

        it "csvがパースされるここと" do
          expect_any_instance_of(ImportCSV).to receive(:parse_csv)
          @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
        end

        after do
          ImportCSV.remove_csv_file(user.id, template.id)
        end
      end
    end

    describe "#save" do
      let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'standard.csv')) }
      let(:template) { create(:template) }

      context "バリデーションに成功した場合" do
        before do
          element = create(:only_element, template: template, parent_id: nil, multiple_input: true)
          vocabulary_element = create(:vocabulary_element_with_values)
          reference_template = create(:template_with_records_all_type)

          create(:element_by_it_line, name: "輸送関連_輸送業者-line-1", template_id: template.id, parent_id: element.id)
          create(:element_by_it_multi_line, name: "輸送関連_輸送業者-multi_line-1",  template_id: template.id, parent_id: element.id)
          create(:element_by_it_checkbox_template, name: "輸送関連_輸送業者-checkbox_template-1", template_id: template.id, source: reference_template, parent_id: element.id, source_element_id: 1)
          create(:element_by_it_checkbox_vocabulary, name: "輸送関連_輸送業者-checkbox_vocabulary-1", template_id: template.id, source: vocabulary_element, parent_id: element.id)
          create(:element_by_it_pulldown_template, name: "輸送関連_輸送業者-pulldown_template-1", template_id: template.id, source: reference_template, parent_id: element.id)
          create(:element_by_it_pulldown_vocabulary, name: "輸送関連_輸送業者-pulldown_vocabulary-1", template_id: template.id, source: vocabulary_element, parent_id: element.id)
          create(:element_by_it_kokudo_location, name: "輸送関連_輸送業者-kokudo_location-1", template_id: template.id, parent_id: element.id)
          create(:element_by_it_osm_location, name: "輸送関連_輸送業者-osm_location-1", template_id: template.id, parent_id: element.id)
          create(:element_by_it_google_location, name: "輸送関連_輸送業者-google_location-1", template_id: template.id, parent_id: element.id)
          create(:element_by_it_dates, name: "輸送関連_ 輸送業者-dates-1", template_id: template.id, parent_id: element.id)

          @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
        end

        context "保存に成功した場合" do
          context "新規レコードの場合" do
            context "グルーピングされていない場合" do
              let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'new_record.csv')) }

              it "全タイプの項目にデータがCSVの行分入ること" do
                expect{@import_csv.save}.to change(TemplateRecord, :count).by(@import_csv.rows.count)
              end

              it "正しい数のElementValueが増えていること" do
                expect{@import_csv.save}.to change(ElementValue, :count).by(@import_csv.rows.count * 13)
              end
            end

            context "グルーピングされている場合" do
              let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'new_record_grouping.csv')) }

              it "3つのグルーピングされたデータ+グルーピングされていないデータ分データが登録されること" do
                expect{@import_csv.save}.to change(TemplateRecord, :count).by(3)
              end

              it "グルーピングに使用したidは実際のデータのidには使用されていないこと" do
                @import_csv.save
                expect(TemplateRecord.find_by(id: 1000)).to be_nil
              end

              it "正しい数のElementValueが増えていること" do
                expect{@import_csv.save}.to change(ElementValue, :count).by(@import_csv.rows.count * 13)
              end
            end
          end
        end

        context "保存に失敗した場合" do
          before do
            allow_any_instance_of(TemplateRecord).to receive(:save!).and_raise StandardError
          end

          it "falseを返すこと" do
            expect(@import_csv.save).to be_false
          end

          after do
            ImportCSV.remove_csv_file(user.id, template.id)
          end
        end
      end
    end

    describe "#build_csv_row" do
      let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'standard.csv')) }

      before do
        8.times{ create(:only_element, template_id: template.id) }
        @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
        @row_count = 0
        CSV.parse(csv_content.kconv(Kconv::UTF8, Kconv::SJIS)) do |row|
          @col_count ||= row.count
          @row_count += 1
        end
      end

      it "TemplateRecordを行と同じ数だけビルドしていること" do
        expect(@import_csv.records.count).to eq(@row_count - 1)
      end

      after do
        ImportCSV.remove_csv_file(user.id, template.id)
      end
    end

    describe "#find_or_build_template_record" do
      let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'standard.csv')) }
      let(:record) { create(:template_record) }

      before do
        @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
        @import_csv.records = [record]
      end

      context "idが記述されていた場合" do
        it "保存済みのTemplateRecordインスタンスを取得していること" do
          expect(@import_csv.find_or_build_template_record([record.id])).to eq(record)
        end
      end

      context "存在しないidの場合" do
        let(:id) { 1000000 }

        it "新規のTemplateRecordインスタンスを取得していること" do
          expect(@import_csv.find_or_build_template_record([id])).to be_a_new(TemplateRecord)
        end

        it "idがセットされていること" do
          expect(@import_csv.find_or_build_template_record([id]).id).to eq(id)
        end
      end

      context "idが記述されていない場合" do
        it "新規のTemplateRecordインスタンスを取得していること" do
          expect(@import_csv.find_or_build_template_record([])).to be_a_new(TemplateRecord)
        end
      end
    end

    describe "#build_template_record" do
      let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'standard.csv')) }

      before do
        @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
      end

      it "新規のTemplateRecordインスタンスを取得していること" do
        expect(@import_csv.build_template_record).to be_a_new(TemplateRecord)
      end
    end

    describe "#get_last_item_number" do
      let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'new_record_grouping.csv')) }

      before do
        element = create(:only_element, template: template, parent_id: nil, multiple_input: true)
        vocabulary_element = create(:vocabulary_element_with_values)
        reference_template = create(:template_with_records_all_type)

        @element = create(:element_by_it_line, template_id: template.id, parent_id: element.id)
        create(:element_by_it_multi_line, template_id: template.id, parent_id: element.id)
        create(:element_by_it_checkbox_template, template_id: template.id, source: reference_template, parent_id: element.id, source_element_id: 1)
        create(:element_by_it_checkbox_vocabulary, template_id: template.id, source: vocabulary_element, parent_id: element.id)
        create(:element_by_it_pulldown_template, template_id: template.id, source: reference_template, parent_id: element.id)
        create(:element_by_it_pulldown_vocabulary, template_id: template.id, source: vocabulary_element, parent_id: element.id)
        create(:element_by_it_kokudo_location, template_id: template.id, parent_id: element.id)
        create(:element_by_it_osm_location, template_id: template.id, parent_id: element.id)
        create(:element_by_it_google_location, template_id: template.id, parent_id: element.id)
        create(:element_by_it_dates, template_id: template.id, parent_id: element.id)

        @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
      end

      context "idが存在する場合" do
        it "idが1000のレコードは3回の繰り返しがあるので4が返ること" do
          t_r = @import_csv.build_template_record(1000)
          expect(@import_csv.get_last_item_number(t_r, @element)).to eq(4)
        end
      end

      context "idが存在しない場合" do
        it "1を返すこと" do
          t_r = @import_csv.build_template_record
          expect(@import_csv.get_last_item_number(t_r, @element)).to eq(1)
        end
      end
    end

    describe "#get_current_item_number" do
      let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'new_record_grouping.csv')) }

      before do
        element = create(:only_element, template: template, parent_id: nil, multiple_input: true)
        vocabulary_element = create(:vocabulary_element_with_values)
        reference_template = create(:template_with_records_all_type)

        @element = create(:element_by_it_line, template_id: template.id, parent_id: element.id)
        create(:element_by_it_multi_line, template_id: template.id, parent_id: element.id)
        create(:element_by_it_checkbox_template, template_id: template.id, source: reference_template, parent_id: element.id, source_element_id: 1)
        create(:element_by_it_checkbox_vocabulary, template_id: template.id, source: vocabulary_element, parent_id: element.id)
        create(:element_by_it_pulldown_template, template_id: template.id, source: reference_template, parent_id: element.id)
        create(:element_by_it_pulldown_vocabulary, template_id: template.id, source: vocabulary_element, parent_id: element.id)
        create(:element_by_it_kokudo_location, template_id: template.id, parent_id: element.id)
        create(:element_by_it_osm_location, template_id: template.id, parent_id: element.id)
        create(:element_by_it_google_location, template_id: template.id, parent_id: element.id)
        create(:element_by_it_dates, template_id: template.id, parent_id: element.id)

        @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
      end

      it "idが1000のレコードは3回の繰り返しがあるので4が返ること" do
        t_r = @import_csv.build_template_record(1000)
        expect(@import_csv.get_current_item_number(t_r, @element)).to eq(4)
      end
    end

    describe "#record_valid" do
      let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'standard.csv')) }

      before do
        create(:only_element, template_id: template.id)
        @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
      end

      it "#validation_of_presenceを呼び出していること" do
        expect(@import_csv.records.first).to receive(:validation_of_presence)
        @import_csv.record_valid
      end

      it "#validation_of_uniqueness_on_import_csvを呼び出していること" do
        expect(@import_csv.records.first).to receive(:validation_of_uniqueness_on_import_csv)
        @import_csv.record_valid
      end

      it "#validation_of_lengthを呼び出していること" do
        expect(@import_csv.records.first).to receive(:validation_of_length)
        @import_csv.record_valid
      end

      it "#validation_by_regular_expressionを呼び出していること" do
        expect(@import_csv.records.first).to receive(:validation_by_regular_expression)
        @import_csv.record_valid
      end

      it "#validation_of_locationを呼び出していること" do
        expect(@import_csv.records.first).to receive(:validation_of_location)
        @import_csv.record_valid
      end

      it "#validation_by_reference_valuesを呼び出していること" do
        expect(@import_csv.records.first).to receive(:validation_by_reference_values)
        @import_csv.record_valid
      end

      it "#validation_of_lineを呼び出していること" do
        expect(@import_csv.records.first).to receive(:validation_of_line)
        @import_csv.record_valid
      end
    end

    describe ".remove_csv_file" do
      before do
        @path = File.join(Settings.files.csv_dir_path, user.id.to_s, "#{self.template.id.to_s}.csv")
        FileUtils.mkdir_p(File.dirname(@path))
        File.open(@path, 'w'){|f| f.print 'csv'}
      end

      it "csvファイルが削除されていること" do
        ImportCSV.remove_csv_file(user.id, template.id)
        expect(File.exists?(@path)).to be_false
      end
    end

    describe ".remove_user_dir" do
      before do
        @path = File.join(Settings.files.csv_dir_path, user.id.to_s, "#{self.template.id.to_s}.csv")
        FileUtils.mkdir_p(File.dirname(@path))
        File.open(@path, 'w') do |f|
          f.print 'csv'
        end
        ImportCSV.remove_user_dir(user.id)
      end

      it "ディレクトリが削除されていること" do
        expect(FileTest.exists?(File.dirname(@path))).to be_false
      end
    end

    describe ".csv_file_path" do
      it "パスが設定からのパス+ユーザid+テンプレートidになっていること" do
        path = File.join(Settings.files.csv_dir_path, user.id.to_s, "#{self.template.id.to_s}.csv")
        expect(ImportCSV.send(:csv_file_path, user.id, template.id)).to eq(path)
      end
    end

    describe ".csv_exists?" do
      context "ファイルが存在する場合" do
        let(:path) { ImportCSV.send(:csv_file_path, user.id, template.id) }

        before do
          FileUtils.mkdir_p(File.dirname(path))
          File.open(path, 'w'){|f| f.print('csv')}
        end

        it "trueを返すこと" do
          expect(ImportCSV.csv_exists?(user.id, template.id)).to be_true
        end

        after do
          ImportCSV.remove_csv_file(user.id, template.id)
        end
      end

      context "ファイルが存在しない場合" do
        it "falseを返すこと" do
          expect(ImportCSV.csv_exists?(user.id, template.id)).to be_false
        end
      end
    end

    describe "#csv_file_read" do
      let(:csv_content) { "観光施設名, 観光種類名, 観光住所" }

      context "ファイルが既に存在する場合" do

        before do
          @import_csv = ImportCSV.new(user: user, template: template)
          @path = File.join(Settings.files.csv_dir_path, user.id.to_s, "#{self.template.id.to_s}.csv")
          FileUtils.mkdir_p(File.dirname(@path))
          File.open(@path, 'w'){|f| f.print csv_content.kconv(Kconv::SJIS,Kconv::UTF8)}
        end

        it "ファイルの中身を返すこと" do
          expect(@import_csv.send(:csv_file_read)).to eq(csv_content)
        end

        after do
          File.delete(@path)
        end
      end

      context "ファイルが存在しない場合" do
        before do
          @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
          @path = File.join(Settings.files.csv_dir_path, user.id.to_s, "#{self.template.id.to_s}.csv")
          @import_csv.send(:csv_file_read)
        end

        it "csvアクセッサで指定した文字をファイルに書き込むこと" do
          expect(File.exists?(@path)).to be_true
        end

        after do
          File.delete(@path)
        end
      end
    end

    describe "#parse_csv" do
      let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'standard.csv')) }

      before do
        @import_csv = ImportCSV.new(user: user, template: template, csv: csv_content)
        @rows = []
        CSV.parse(csv_content.kconv(Kconv::UTF8, Kconv::SJIS)).each_with_index do |row, idx|
          if idx != 0
            @rows << row
          else
            @header = row
          end
        end
        @import_csv.send(:parse_csv)
      end

      it "ヘッダーをパースしてアクセッサにセットしていること" do
        expect(@import_csv.header).to eq(@header)
      end

      it "行をパースしてアクセッサにセットしていること" do
        expect(@import_csv.rows).to match_array(@rows)
      end

      after do
        ImportCSV.remove_csv_file(user.id, template.id)
      end
    end
  end

  after do
    dirs = Dir[File.join(Settings.files.csv_dir_path, "*")]
    FileUtils.rm_rf(dirs)
  end
end
