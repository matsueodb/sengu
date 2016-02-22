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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vocabulary_element, :class => 'Vocabulary::Element' do
    name "ランドマーク"
  end

  factory :vocabulary_element_with_values, :class => 'Vocabulary::Element' do
    name "ランドマーク"
    values { [
      FactoryGirl.create(:vocabulary_element_value_square),
      FactoryGirl.create(:vocabulary_element_value_temple),
      FactoryGirl.create(:vocabulary_element_value_shrine),
      FactoryGirl.create(:vocabulary_element_value_museum)
    ] }
  end
end
