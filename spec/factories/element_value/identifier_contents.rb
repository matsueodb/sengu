# == Schema Information
#
# Table name: element_value_identifiers
#
#  id         :integer          not null, primary key
#  value      :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :element_value_identifier_content, :class => 'ElementValue::IdentifierContent' do
    value 1
  end
end
