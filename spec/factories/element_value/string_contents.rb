# == Schema Information
#
# Table name: element_value_strings
#
#  id         :integer          not null, primary key
#  value      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :element_value_string_content, :class => 'ElementValue::StringContent' do
    value "島根輸送"
  end
end
