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

describe ElementValue::CheckboxTemplate do
  let(:content){create(:element_value_checkbox_template)}

  describe "methods" do
    describe ".reference_class" do
      subject{content.reference_class}

      it "TemplateRecordが返ること" do
        expect(subject).to eq(TemplateRecord)
      end
    end

    describe ".included_by_keyword?" do
      let(:keyword){'松江'}
      subject{content.included_by_keyword?(keyword)}

      it "falseが返ること" do
        expect(subject).to be_false
      end
    end

    describe "Concerns::ElementValueTemplate" do
      describe ".formatted_value" do
        subject{content.formatted_value}

        it_behaves_like "Concerns::ElementValueTemplate#formatted_valueの検証"
      end
    end
  end
end
