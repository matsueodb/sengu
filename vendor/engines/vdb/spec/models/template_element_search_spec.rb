require 'spec_helper'

describe TemplateElementSearch do
  describe "バリデーション" do
    it {should ensure_inclusion_of(:domain_id).in_array([nil, TemplateElementSearch::CORE_ID, TemplateElementSearch::DOMAIN_ID]) }

    describe "#validate" do
      context "nameがnilの場合" do
        before do
          allow(subject).to receive(:name).and_return(nil)
        end

        it "use_categoryがtrueの場合、カテゴリを選択するようエラーメッセージが出力されること" do
          allow(subject).to receive(:use_category).and_return(true)
          subject.valid?
          expect(subject.errors.full_messages).to include(I18n.t("activemodel.errors.models.template_element_search.attributes.base.select_category"))
        end

        it "use_categoryがfalseの場合、キーワードを入力するようエラーメッセージが出力されること" do
          allow(subject).to receive(:use_category).and_return(false)
          subject.valid?
          expect(subject.errors.full_messages).to include(I18n.t("activemodel.errors.models.template_element_search.attributes.base.input_keyword"))
        end
      end
    end
  end

  describe "メソッド" do
    describe "#find_complex" do
      subject { TemplateElementSearch.new(name: 'name', domain_id: TemplateElementSearch::CORE_ID) }
      let(:response) { double('response', success?: true) }

      before do
        expect(response).to receive(:find_complex_with_getname)
        expect(Sengu::VDB::Core).to receive(:find).and_return(response)
      end

      it "Sengu::VDB::Core#findを呼び出して、レスポンスに#find_complex_with_getnameを呼び出していること" do
        subject.find_complex
      end
    end

    describe "#find_complexes" do
      let(:user) { create(:super_user) }
      let(:response) { double('response') }
      describe "正常系" do
        before do
          response.stub(:success?){true}
          response.stub(:fatal?){false}
        end

        describe "カテゴリ検索の場合" do
          let(:names) { ['建物', '施設', 'Matsue'] }
          let(:category) { '建物' }
          subject { TemplateElementSearch.new(name: category, domain_id: TemplateElementSearch::CORE_ID, use_category: true) }

          before do
            names.each do |n|
              create(:vocabulary_keyword, name: n, category: category, user: user)
              expect(Sengu::VDB::Core).to receive(:find).with(n).and_return(response)
              expect(response).to receive(:find_complex_with_getname)
            end
          end

          it "Sengu::VDB::Core#find、レスポンスに#find_complex_with_getnameをそれぞれ3回呼び出していること" do
            subject.find_complexes
          end
        end

        describe "カテゴリ検索ではない場合" do
          let(:name) { '建物' }
          subject { TemplateElementSearch.new(name: name, domain_id: TemplateElementSearch::CORE_ID, use_category: false) }

          before do
            expect(Sengu::VDB::Core).to receive(:find).with(name).and_return(response)
            expect(response).to receive(:find_complex_with_getname)
          end

          it "Sengu::VDB::Core#findを呼び出して、レスポンスに#find_complex_with_getnameを呼び出していること" do
            subject.find_complexes
          end
        end
      end

      describe "異常系" do
        let(:name){"建物"}
        let(:tes){TemplateElementSearch.new(name: name, domain_id: TemplateElementSearch::CORE_ID, use_category: false)}
        subject {tes.find_complexes}

        context "語彙DBのアクセスに失敗した場合" do
          before do
            Sengu::VDB::Core.stub(:find){ raise ::Sengu::VDB::Base::ConnectionError}
          end

          it "エラーが追加されること" do
            subject
            expect(tes.errors[:base]).to eq([I18n.t("sengu.vdb.base.errors.connection")])
          end
        end

        context "解析に失敗した場合" do
          before do
            Sengu::VDB::Core.stub(:find){ raise ::Sengu::VDB::Response::ParseError}
          end

          it "エラーが追加されること" do
            subject
            expect(tes.errors[:base]).to eq([I18n.t("sengu.vdb.response.errors.parse")])
          end
        end

        context "語彙DBが異常を返した場合" do
          let(:response) { double('response', success?: false, fatal?: true, message: "error_message") }

          before do
            expect(Sengu::VDB::Core).to receive(:find).with(name).and_return(response)
            expect(Sengu::VDB::Core).to receive(:find).with(name, false).and_return(response)
            expect(response).to receive(:find_complex_with_getname)
          end

          it "エラーが追加されること" do
            subject
            expect(tes.errors[:base]).to eq(["error_message"])
          end
        end
      end
    end

    describe "#find_element" do
      subject { TemplateElementSearch.new(name: 'name', domain_id: TemplateElementSearch::CORE_ID) }
      let(:response) { double('response') }

      before do
        expect(response).to receive(:find_element_with_getname)
        response.stub(:kind_of?).with(Net::HTTPOK) { true }
        expect(Sengu::VDB::Core).to receive(:find).and_return(response)
      end

      it "Sengu::VDB::Core#findを呼び出して、レスポンスに#find_element_with_getnameを呼び出していること" do
        subject.find_element
      end
    end

    describe "#search" do
      let(:name) { 'name' }
      let(:user) { create(:super_user) }
      let(:response){double("response")}

      describe "正常系" do
        before do
          response.stub(:success?){true}
          response.stub(:fatal?){false}
        end

        context "バリデーションに成功した場合" do
          before do
            @template_element_search = TemplateElementSearch.new(name: name, domain_id: TemplateElementSearch::CORE_ID, user_id: user.id)
            expect(Sengu::VDB::Core).to receive(:search).with(name){response}
          end

          it "Sengu::VDB::Core#searchを呼び出していること" do
            @template_element_search.search
          end
        end

        context "語彙データにキーワードが設定されている場合" do
          let(:keywords) { ['建物', '施設', 'Matsue'] }
          let(:content) { '建物' }

          before do
            @template_element_search = TemplateElementSearch.new(name: content, domain_id: TemplateElementSearch::CORE_ID, user_id: user.id)
            expect(Sengu::VDB::Core).to receive(:search).with(content){response}
            keywords.each do |k|
              create(:vocabulary_keyword, name: k, content: content, user: user)
              expect(Sengu::VDB::Core).to receive(:search).with(k){response}
            end
          end

          it "Sengu::VDB::Core#searchを設定されたキーワード分呼び出していること" do
            @template_element_search.search
          end
        end
      end

      describe "異常系" do
        context "バリデーションに失敗した場合" do
          before do
            @template_element_search = TemplateElementSearch.new
            expect(Sengu::VDB::Core).not_to receive(:search).with(name)
          end

          it "Sengu::VDB::Core#searchを呼び出していないこと" do
            @template_element_search.search
          end

          it "falseを返すこと" do
            expect(@template_element_search.search).to be_false
          end
        end

        context "検索を実行した場合" do
          let(:tes){TemplateElementSearch.new(name: name, domain_id: TemplateElementSearch::CORE_ID, user_id: user.id)}
          subject {tes.search}

          context "語彙DBのアクセスに失敗した場合" do
            before do
              Sengu::VDB::Core.stub(:search){ raise ::Sengu::VDB::Base::ConnectionError}
            end

            it "エラーが追加されること" do
              subject
              expect(tes.errors[:base]).to eq([I18n.t("sengu.vdb.base.errors.connection")])
            end
          end

          context "解析に失敗した場合" do
            before do
              Sengu::VDB::Core.stub(:search){ raise ::Sengu::VDB::Response::ParseError}
            end

            it "エラーが追加されること" do
              subject
              expect(tes.errors[:base]).to eq([I18n.t("sengu.vdb.response.errors.parse")])
            end
          end

          context "語彙DBが異常を返した場合" do
            before do
              response.stub(:success?){false}
              response.stub(:fatal?){true}
              response.stub(:message){"error_message"}
              expect(Sengu::VDB::Core).to receive(:search).with(name).and_return(response)
            end

            it "エラーが追加されること" do
              subject
              expect(tes.errors[:base]).to eq(["error_message"])
            end
          end
        end
      end
    end

    describe "#vdb_class" do
      context "domain_idを指定しない場合" do
        it "[Sengu::VDB::Core, Sengu::VDB::Domain]が返ること" do
          expect(TemplateElementSearch.new.vdb_class).to match_array([Sengu::VDB::Core, Sengu::VDB::Domain])
        end
      end

      context "domain_idがコアの場合" do
        it "Sengu::VDB::Coreが返ること" do
          expect(TemplateElementSearch.new(domain_id: TemplateElementSearch::CORE_ID).vdb_class).to eq(Sengu::VDB::Core)
        end
      end

      context "domain_idがドメインの場合" do
        it "Sengu::VDB::Domainが返ること" do
          expect(TemplateElementSearch.new(domain_id: TemplateElementSearch::DOMAIN_ID).vdb_class).to eq(Sengu::VDB::Domain)
        end
      end
    end
  end
end


