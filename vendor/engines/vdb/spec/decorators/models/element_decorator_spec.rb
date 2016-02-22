require 'spec_helper'

describe Element do
  describe "バリデーション" do
    let(:data_type) { 'ic:テキスト型' }

    before do
      it_line = create(:input_type_line)
      @element = create(:element, input_type: it_line, data_type: data_type)
      @element.input_type = create(:input_type_dates)
    end
  end

  describe "メソッド" do
    let(:template) { create(:template) }
    let(:element) { create(:only_element, template_id: template.id, entry_name: "entry_name")}

    describe "#about_url_for_rdf_with_vdb" do
      context "項目が参照で無い場合" do
        subject{ element.about_url_for_rdf_with_vdb(template) }

        context "語彙データベースから作成されている場合" do
          describe "コアの場合" do
            it "語彙データベースのURLが返ること" do
              allow(element).to receive(:domain_id) { Sengu::VDB::Core::DOMAIN_ID }
              expect(subject).to eql("https://goikiban.ipa.go.jp/api/v1.0/domain4_ouxlpz/core/Part?getname=#{element.entry_name}&relateflg=#{Sengu::VDB::Base::RELATE_FLGS[true]}")
            end
          end

          describe "ドメインの場合" do
            it "語彙データベースのURLが返ること" do
              allow(element).to receive(:domain_id) { Sengu::VDB::Domain::DOMAIN_ID }
              expect(subject).to eql("https://goikiban.ipa.go.jp/api/v1.0/domain4_ouxlpz/domain/Part?getname=#{element.entry_name}&relateflg=#{Sengu::VDB::Base::RELATE_FLGS[true]}")
            end
          end
        end

        context "独自項目の場合" do
          it "about_url_for_rdf_without_vdbが呼ばれること" do
            expect(element).to receive(:about_url_for_rdf_without_vdb).with(template)
            subject
          end
        end
      end

      context "項目が参照の場合" do
        subject{ element.about_url_for_rdf_with_vdb(template, referenced: true) }

        it "about_url_for_rdf_without_vdbが呼ばれること" do
          expect(element).to receive(:about_url_for_rdf_without_vdb).with(template)
          subject
        end
      end
    end

    describe "#disabled_input_type_ids" do
      let(:data_type) { 'ic:テキスト型' }

      context "エントリーネームが設定されていない場合" do
        before do
          @element = build(:element, data_type: data_type)
        end

        it "使用できないIDを返却すること" do
          expect(@element.disabled_input_type_ids).to eq([])
        end
      end
    end
  end
end
