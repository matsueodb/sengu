# == Schema Information
#
# Table name: element_value_dates
#
#  id         :integer          not null, primary key
#  value      :datetime
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :element_value_date_content, :class => 'ElementValue::DateContent' do
    value "2014-01-31 17:29:44"
  end
end
