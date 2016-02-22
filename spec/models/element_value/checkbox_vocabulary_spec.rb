# == Schema Information
#
# Table name: element_value_identifier_contents
#
#  id         :integer          not null, primary key
#  value      :integer
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe ElementValue::CheckboxVocabulary do
  let(:content){create(:element_value_checkbox_vocabulary)}

  describe "methods" do
    describe "#reference_class" do
      subject{content.reference_class}

      it "Vocabulary::ElementValueが返ること" do
        expect(subject).to eq(Vocabulary::ElementValue)
      end
    end

    describe "#included_by_keyword?" do
      let(:keyword){'松江'}
      let(:eve){create(:vocabulary_element_value)}
      subject{content.included_by_keyword?(keyword)}

      before do
        content.stub(:reference){eve}
      end

      it "参照している語彙の名前にキーワードを含む場合、Trueが返ること" do
        eve.stub(:name){"松江城"}
        expect(subject).to be_true
      end

      it "参照している語彙の名前にキーワードを含む場合、Trueが返ること" do
        eve.stub(:name){"県立美術館"}
        expect(subject).to be_false
      end
    end

    describe "Concerns::ElementValueVocabulary" do
      describe "#formatted_value" do
        subject{content.formatted_value}

        it_behaves_like "Concerns::ElementValueVocabulary#formatted_valueの検証"
      end
    end
  end
end
