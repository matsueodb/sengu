require 'spec_helper'

describe Vocabulary::Element do
  describe "メソッド" do
    describe "#update_by_vdb" do
      subject{ element.update_by_vdb }

      context "語彙から取得したコードリストの場合" do
        before do
          allow(VocabularySearch).to receive(:find).and_return(code_list)
        end

        context "作成の場合" do
          let!(:element) { create(:vocabulary_element, from_vdb: true) }
          let(:vdb_element) { build(:vocabulary_element_with_values) }
          let(:code_list) { double('code_list', to_vocabulary_element: vdb_element) }

          it "trueを返すこと" do
            expect(subject).to eq(true)
          end

          it "足りないデータを挿入していること" do
            expect{subject}.to change(Vocabulary::ElementValue, :count).by(vdb_element.values.count)
          end
        end

        context "削除の場合" do
          context "削除対象のデータを使用したテンプレートのデータが存在する場合" do
            let(:element) { create(:vocabulary_element_with_values, from_vdb: true) }
            let(:vdb_element) { build(:vocabulary_element) }
            let(:code_list) { double('code_list', to_vocabulary_element: vdb_element) }

            before do
              el = create(:element_by_it_checkbox_vocabulary, source: element)
              create(:element_value, element: el, kind: element.values.first.id)
            end

            it "falseをかえすこと" do
              expect(subject).to eq(false)
            end
          end

          context "削除対象のデータを使用したテンプレートのデータが存在しない場合" do
            let!(:element) { create(:vocabulary_element_with_values, from_vdb: true) }
            let(:vdb_element) { build(:vocabulary_element) }
            let(:code_list) { double('code_list', to_vocabulary_element: vdb_element) }

            it "trueを返すこと" do
              expect(subject).to eq(true)
            end

            it "不要なデータを削除していること" do
              subject
              expect(element.values).to eq(vdb_element.values)
            end
          end
        end
      end

      context "語彙から取得したコードリストではない場合" do
        let(:element) { create(:vocabulary_element, from_vdb: false) }

        it "falseを返すこと" do
          expect(subject).to eq(false)
        end
      end
    end

    describe "#about_url_for_rdf" do
      describe "語彙データベースから設定されている場合" do
        let(:vocabulary_element) { create(:vocabulary_element, from_vdb: true) }

        it "語彙データベースのURLを返却すること" do
          expect(vocabulary_element.about_url_for_rdf).to eq(Sengu::VDB::Domain.get_vocabulary_url(Settings.vdb.api_ids.find_id, getname: vocabulary_element.name, relateflg: "1").to_s)
        end
      end

      describe "独自に設定した場合" do
        let(:vocabulary_element) { create(:vocabulary_element, from_vdb: false) }

        it "nilを返却すること" do
          expect(vocabulary_element.about_url_for_rdf).to be_nil
        end
      end
    end

    describe "#about_url_for_rdf_without_vdb" do
      let(:vocabulary_element) { create(:vocabulary_element) }

      it "自分自身のデータ一覧のURLを返却すること" do
        expect(vocabulary_element.about_url_for_rdf_without_vdb).to eq(Rails.application.routes.url_helpers.vocabulary_element_values_path(vocabulary_element))
      end
    end
  end
end
