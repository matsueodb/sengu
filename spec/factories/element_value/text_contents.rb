# == Schema Information
#
# Table name: element_value_texts
#
#  id         :integer          not null, primary key
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :element_value_text_content, :class => 'ElementValue::TextContent' do
    value "島根輸送"
  end
end
