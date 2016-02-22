require 'spec_helper'

describe Vocabulary::Keyword do
  describe "バリデーション" do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:user_id) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:name) }
    it { should validate_presence_of(:scope) }
    it { should validate_numericality_of(:scope) }

    describe "#scope_permission_valid" do
      let(:user) { create(:editor_user) }

      before do
        @vocabulary_keyword = build(:vocabulary_keyword_whole, user: user)
      end

      context "データ登録者ではない場合" do
        it "バリデーションに引っかかること" do
          expect(@vocabulary_keyword).to have(1).errors_on(:scope)
        end
      end
    end
  end

  describe "メソッド" do
    describe "#scoped_human_name" do
      context "全体に適用されるキーワードの場合" do
        before do
          @vocabulary_keyword = build(:vocabulary_keyword_whole)
        end

        it "正しくラベルが返ること" do
          expect(@vocabulary_keyword.scope_human_name).to eq(I18n.t('activerecord.attributes.vocabulary/keyword.scopes.1_title'))
        end
      end

      context "自ユーザのみに適用されるキーワードの場合" do
        before do
          @vocabulary_keyword = build(:vocabulary_keyword_individual)
        end

        it "正しくラベルが返ること" do
          expect(@vocabulary_keyword.scope_human_name).to eq(I18n.t('activerecord.attributes.vocabulary/keyword.scopes.2_title'))
        end
      end
    end
  end
end
