# == Schema Information
#
# Table name: services
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :service do
    sequence(:name){|n|"県のサービス-#{n}"}
    description "県のサービスです。観光のサービスに使用されています"
    user{create(:section_manager_user)}
    section { create(:section) }
  end
end
