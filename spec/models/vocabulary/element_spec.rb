# == Schema Information
#
# Table name: vocabulary_elements
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Vocabulary::Element do
  describe "association" do
    it{should have_many(:elements).class_name('Element')}
    it{should have_many(:values).class_name('Vocabulary::ElementValue')}
  end

  describe "validation" do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_most(255) }
  end

  describe "methods" do
    let(:element){create(:vocabulary_element)}
    describe ".records_referenced_from_element" do
      let(:values){
        [
          create(:vocabulary_element_value, element_id: element.id),
          create(:vocabulary_element_value, element_id: element.id),
          create(:vocabulary_element_value, element_id: element.id),
        ]
      }
      subject{element.records_referenced_from_element}

      it "elementのvaluesの値が返ること" do
        expect(subject).to eq(values)
      end
    end
  end
end
