# == Schema Information
#
# Table name: element_value_text_contents
#
#  id         :integer          not null, primary key
#  value      :text
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe ElementValue::TextContent do
  let(:content){create(:element_value_text_content, type: ElementValue::MultiLine.name)}
  describe "validation" do
    it {should ensure_inclusion_of(:type).in_array(ElementValue::TextContent::TYPE_CLASSES)}
  end

  describe "methods" do
    describe ".included_by_keyword?" do
      let(:keyword){"松江"}
      subject{content.included_by_keyword?(keyword)}

      it "引数で渡したキーワードの文字列をvalueに含む場合、trueが返ること" do
        content.stub(:value){"松江城とは\n松江のお城です。"}
        expect(subject).to be_true
      end

      it "引数で渡したキーワードの文字列をvalueに含まない場合、falseが返ること" do
        content.stub(:value){"県立美術館とは\n島根県の美術館です。"}
        expect(subject).to be_false
      end
    end

    describe "Concerns::ElementValueContent" do
      describe ".formatted_value" do
        subject{content.formatted_value}
        it_behaves_like "Concerns::ElementValueContent#formatted_valueの検証"
      end

      describe ".greater_than?" do
        let(:val){100}
        subject{content.greater_than?(val)}
        it_behaves_like "Concerns::ElementValueContent#greater_than?の検証"
      end

      describe ".less_than?" do
        let(:val){100}
        subject{content.less_than?(val)}
        it_behaves_like "Concerns::ElementValueContent#less_than?の検証"
      end
    end
  end
end
