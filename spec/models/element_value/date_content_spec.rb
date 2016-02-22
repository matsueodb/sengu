# == Schema Information
#
# Table name: element_value_date_contents
#
#  id         :integer          not null, primary key
#  value      :datetime
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe ElementValue::Dates do
  let(:content){create(:element_value_date_content, type: ElementValue::Dates.name)}
  describe "validation" do
    it {should ensure_inclusion_of(:type).in_array(ElementValue::DateContent::TYPE_CLASSES)}
  end

  describe "methods" do
    let(:val){"2014-01-01 00:00:00"}
    describe ".formatted_value" do
      subject{content.formatted_value}

      it "self.valueが返ること" do
        content.stub(:value){val}
        expect(subject).to eq(val)
      end
    end

    describe ".included_by_keyword?" do
      let(:keyword){"01-01"}
      subject{content.included_by_keyword?(keyword)}

      it "self.valueが引数で渡したキーワードを含む場合、trueが返ること" do
        content.stub(:value){"2014-01-01 00:00:00"}
        expect(subject).to be_true
      end

      it "self.valueが引数で渡したキーワードを含まない場合、falseが返ること" do
        content.stub(:value){"2014-02-01 00:00:00"}
        expect(subject).to be_false
      end
    end
  end
end
