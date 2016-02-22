# == Schema Information
#
# Table name: user_groups
#
#  id   :integer          not null, primary key
#  name :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_group do
    sequence(:name){|n|"user_group#{n}"}
    section_id 1
  end
end
