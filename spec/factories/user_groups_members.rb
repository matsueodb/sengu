# == Schema Information
#
# Table name: user_groups_members
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  group_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_groups_member do
    user_id 1
    group_id 1
  end
end
