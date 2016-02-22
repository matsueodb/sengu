require 'spec_helper'

describe Sengu::Template::PDF do
  describe "メソッド" do
    let(:template) { create(:template) }

    describe "#initialize" do
      let(:font_path) { Sengu::Template::PDF::FONT_FILE_PATH }

      before do
        expect_any_instance_of(Sengu::Template::PDF).to receive(:font).with(font_path)
      end

      it "日本語を使用するためにフォントを設定していること" do
        Sengu::Template::PDF.new(template)
      end
    end

    describe "#render" do
      let(:pdf) { Sengu::Template::PDF.new(template) }

      before do
        expect(pdf).to receive(:draw)
      end

      it "#drawメソッドを呼び出していること" do
        pdf.render
      end
    end

    describe "#draw" do
      let(:pdf) { Sengu::Template::PDF.new(template) }

      it "#draw_headerメソッドを呼び出してヘッダーを描画していること" do
        expect(pdf).to receive(:draw_header)
        pdf.render
      end

      it "#draw_headerメソッドを呼び出してデータ説明を描画していること" do
        expect(pdf).to receive(:draw_data_description)
        pdf.render
      end

      it "#draw_headerメソッドを呼び出してデータ一覧を描画していること" do
        expect(pdf).to receive(:draw_data_list)
        pdf.render
      end

      it "#draw_headerメソッドを呼び出して構造構造を描画していること" do
        expect(pdf).to receive(:draw_rdf_structure)
        pdf.render
      end

      it "#draw_headerメソッドを呼び出してRDFサンプルを描画していること" do
        expect(pdf).to receive(:draw_rdf_sample)
        pdf.render
      end
    end

    describe "#draw_header" do
      let(:pdf) { Sengu::Template::PDF.new(template) }

      it "PDFのタイトルと本日の日付を描画していること" do
        expect(pdf).to receive(:text).with(I18n.t('sengu.template.pdf.title', template_name: template.name))
        expect(pdf).to receive(:text).with(Date.today.strftime(I18n.t('date.formats.normal')), align: :right)
        pdf.send(:draw_header)
      end

      it "描画後に#move_downでカーソルを10下げること" do
        expect(pdf).to receive(:move_down).with(10)
        pdf.send(:draw_header)
      end
    end

    describe "#draw_data_description" do
      let(:pdf) { Sengu::Template::PDF.new(template) }

      before do
        allow(pdf).to receive(:subtitle_draw)
      end

      it "正しいサブタイトルを描画していること" do
        expect(pdf).to receive(:subtitle_draw).with(I18n.t('sengu.template.pdf.data_description_title'))
        pdf.send(:draw_data_description)
      end

      it "正しいライセンス情報を描画していること" do
        expect(pdf).to receive(:text).with(pdf.send(:nbsp, 2) + I18n.t('sengu.template.pdf.data_description_content', distributor: template.service.section.name, template_name: template.name))
        pdf.send(:draw_data_description)
      end

      it "描画後に#move_downでカーソルを10下げること" do
        expect(pdf).to receive(:move_down).with(10)
        pdf.send(:draw_data_description)
      end
    end

    describe "#draw_data_list" do
      let(:pdf) { Sengu::Template::PDF.new(template) }
      let(:elements) { create_list(:only_element, 5, template_id: template.id) }
      let(:data) { [["first", "second", "thrid", "fuorth", "fifth"]]}

      before do
        allow(pdf).to receive(:subtitle_draw)
        Template.any_instance.stub_chain(:all_elements, :root, :each_with_object).and_return(data)
      end

      it "正しいサブタイトルを描画していること" do
        expect(pdf).to receive(:subtitle_draw).with(I18n.t('sengu.template.pdf.data_list_title'))
        pdf.send(:draw_data_list)
      end

      it "項目のデータをテーブルで描画していること" do
        expect(pdf).to receive(:table).with(data, header: true, column_widths: [25, 120, 115, 160, 120])
        pdf.send(:draw_data_list)
      end
    end

    describe "#draw_rdf_structure" do
      let(:pdf) { Sengu::Template::PDF.new(template) }

      it "正しいサブタイトルを描画していること" do
        expect(pdf).to receive(:subtitle_draw).with(I18n.t('sengu.template.pdf.rdf_structure_title'))
        pdf.send(:draw_rdf_structure)
      end
    end

    describe "#draw_rdf_sample" do
      let(:pdf) { Sengu::Template::PDF.new(template) }

      before do
        allow(pdf).to receive(:subtitle_draw)
      end

      it "正しいサブタイトルを描画していること" do
        expect(pdf).to receive(:subtitle_draw).with(I18n.t('sengu.template.pdf.rdf_sample_title'))
        pdf.send(:draw_rdf_sample)
      end
    end

    describe "#subtitle_draw" do
      let(:pdf) { Sengu::Template::PDF.new(template) }
      let(:str) { 'サブタイトル' }

      it "引数で渡された文字を描画していること" do
        expect(pdf).to receive(:text).with(str)
        pdf.send(:subtitle_draw, str)
      end

      it "描画後に#move_downでカーソルを5下げること" do
        expect(pdf).to receive(:move_down).with(5)
        pdf.send(:subtitle_draw, str)
      end
    end

    describe "#nbsp" do
      let(:pdf) { Sengu::Template::PDF.new(template) }

      context "引数がない場合" do
        it "1つの空白を返すこと" do
          expect(pdf.send(:nbsp)).to eq(Prawn::Text::NBSP * 1)
        end
      end

      context "引数がある場合" do
        let(:repeat_time) { 10 }

        it "指定された文だけ空白を返すこと" do
          expect(pdf.send(:nbsp, repeat_time)).to eq(Prawn::Text::NBSP * repeat_time)
        end
      end
    end

    describe "#restricts" do
      let(:pdf) { Sengu::Template::PDF.new(template) }
      let(:element) { create(:only_element, template_id: template.id) }
      subject { pdf.send(:restricts, element) }

      describe "使用するかどうか" do
        let(:text) { I18n.t('sengu.rdf.builder.restriction.not_available') }

        context "使用する場合" do
          before do
            allow(element).to receive(:actually_available?).and_return(true)
          end

          it "該当するテキストが格納されないこと" do
            expect(subject).not_to include(text)
          end
        end

        context "使用しない場合" do
          before do
            allow(element).to receive(:actually_available?).and_return(false)
          end

          it "該当するテキストが格納されること" do
            expect(subject).to include(text)
          end
        end
      end

      describe "必須どうか" do
        let(:text) { I18n.t('sengu.rdf.builder.restriction.required') }

        context "必須の場合" do
          before do
            allow(element).to receive(:required?).and_return(true)
          end

          it "該当するテキストが格納されること" do
            expect(subject).to include(text)
          end
        end

        context "必須でない場合" do
          before do
            allow(element).to receive(:required?).and_return(false)
          end

          it "該当するテキストが格納されないこと" do
            expect(subject).not_to include(text)
          end
        end
      end

      describe "ユニークどうか" do
        let(:text) { I18n.t('sengu.rdf.builder.restriction.unique') }

        context "ユニークの場合" do
          before do
            allow(element).to receive(:unique?).and_return(true)
          end

          it "該当するテキストが格納されること" do
            expect(subject).to include(text)
          end
        end

        context "ユニークでない場合" do
          before do
            allow(element).to receive(:unique?).and_return(false)
          end

          it "該当するテキストが格納されないこと" do
            expect(subject).not_to include(text)
          end
        end
      end

      describe "正規表現による制約かどうか" do
        let(:text) { "restrict" }

        before do
          element.stub_chain(:regular_expression, :name).and_return(text)
        end

        context "制約がある場合" do
          before do
            element.stub_chain(:regular_expression, :present?).and_return(true)
          end

          it "該当するテキストが格納されること" do
            expect(subject).to include(text)
          end
        end

        context "制約がない場合" do
          before do
            element.stub_chain(:regular_expression, :present?).and_return(false)
          end

          it "該当するテキストが格納されないこと" do
            expect(subject).not_to include(text)
          end
        end
      end
    end

    describe "#set_row_element_data" do
      let(:pdf) { Sengu::Template::PDF.new(template) }
      let(:element) { create(:only_element, template_id: template.id) }
      subject{ pdf.send(:set_row_element_data, element, [], 1, 1) }

      context "子要素が無いとき" do
        it "Prawn::Table::Cell.makeが5回呼ばれること" do
          expect(Prawn::Table::Cell).to receive(:make).exactly(5).times
          subject
        end

        it "戻り値が2であること" do
          expect(subject).to eql(2)
        end
      end

      context "子要素があるとき" do
        before do
          create(:only_element, template_id: template.id, parent_id: element.id)
        end

        it "Prawn::Table::Cell.makeが10回呼ばれること" do
          expect(Prawn::Table::Cell).to receive(:make).exactly(10).times
          subject
        end

        it "戻り値が3であること" do
          expect(subject).to eql(3)
        end
      end
    end

    describe "#make_structure_table" do
      let(:pdf) { Sengu::Template::PDF.new(template) }
      let(:datas) do
        { "xpath1" => [{content: nil},
                       {"xpath2"  => {content: nil}}]
        }
      end
      subject{ pdf.send(:make_structure_table, [], "xpath1", datas["xpath1"]) }

      it "make_structure_tableが2回呼ばれること" do
        expect(pdf).to receive(:make_structure_table).with([], "xpath1", datas["xpath1"]).ordered.and_call_original
        expect(pdf).to receive(:make_structure_table).ordered.and_call_original
        subject
      end
    end

    describe "#translate" do
      let(:pdf) { Sengu::Template::PDF.new(template) }
      subject{ pdf.send(:translate, label) }

      context "引数がnilの場合" do
        let(:label) { nil }

        it "空文字が返ること" do
          expect(subject).to eql("")
        end
      end

      context "引数がsymbolの場合" do
        let(:label) { :data }

        it "空文字が返ること" do
          expect(subject).to eql(I18n.t("sengu.template.pdf.rdf_structure.data"))
        end
      end
    end
  end
end
