require 'spec_helper'

describe VocabularySearch do
  describe "バリデーション" do
    it {should validate_presence_of :name}
  end

  describe "メソッド" do
    describe ".find" do
      let(:name) { {name: 'name'} }
      let(:response) { double('response') }

      before do
        expect(response).to receive(:find_code_list_with_getname)
        expect(Sengu::VDB::Domain).to receive(:find).with(name[:name]).and_return(response)
      end

      it "Sengu::VDB::Domain.findを呼び出して、レスポンスに#find_code_list_with_getnameを呼び出していること" do
        VocabularySearch.find(name)
      end
    end

    describe "#search" do
      let(:name) { 'name' }

      context "バリデーションに成功した場合" do
        before do
          @vocabulary_search = VocabularySearch.new(name: name)
          expect(Sengu::VDB::Domain).to receive(:search).with(name)
        end

        it "Sengu::VDB::Domain#searchを呼び出していること" do
          @vocabulary_search.search
        end
      end

      context "バリデーションに失敗した場合" do
        before do
          @vocabulary_search = VocabularySearch.new
          expect(Sengu::VDB::Domain).not_to receive(:search).with(name)
        end

        it "Sengu::VDB::Domain#searchを呼び出していないこと" do
          @vocabulary_search.search
        end

        it "falseを返すこと" do
          expect(@vocabulary_search.search).to be_false
        end
      end
    end
  end
end

