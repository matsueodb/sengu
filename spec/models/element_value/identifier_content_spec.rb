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

describe ElementValue::IdentifierContent do
  let(:content){create(:element_value_identifier_content, type: ElementValue::CheckboxTemplate.name)}
  describe "validation" do
    it {should ensure_inclusion_of(:type).in_array(ElementValue::IdentifierContent::TYPE_CLASSES)}
  end
  
  describe "methods" do
    let(:template){create(:template)}
    let(:tr){create(:template_record, template: template)}

    before do
      content.stub(:reference_class){tr.class}
      content.stub(:value){tr.id}
    end

    subject{content.reference}

    describe ".reference" do
      it ".reference_classのクラスのself.value == idのレコードが返ること" do
        expect(subject).to eq(tr)
      end
    end
    
    describe "Concerns::ElementValueContent" do
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
