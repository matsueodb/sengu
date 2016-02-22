# == Schema Information
#
# Table name: vocabulary_element_values
#
#  id         :integer          not null, primary key
#  element_id :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :vocabulary_element_value, :class => 'Vocabulary::ElementValue' do
    name 'Aサイズ'
  end

  factory :vocabulary_element_value_square, :class => 'Vocabulary::ElementValue' do
    name "広場"
  end

  factory :vocabulary_element_value_temple, :class => 'Vocabulary::ElementValue' do
    name "寺"
  end

  factory :vocabulary_element_value_shrine, :class => 'Vocabulary::ElementValue' do
    name "神社"
  end

  factory :vocabulary_element_value_museum, :class => 'Vocabulary::ElementValue' do
    name "博物館"
  end
end
