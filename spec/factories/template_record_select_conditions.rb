# == Schema Information
#
# Table name: template_record_select_conditions
#
#  id           :integer          not null, primary key
#  template_id  :integer
#  target_class :string(255)
#  condition    :text
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :template_record_select_condition do
  end
end
