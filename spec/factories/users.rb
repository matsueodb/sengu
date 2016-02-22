# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  login              :string(255)      default(""), not null
#  encrypted_password :string(255)      default(""), not null
#  name               :string(255)
#  remarks            :string(255)
#  authority          :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :super_user, class: User do
    sequence(:login){|n|"super_user#{n}"}
    sequence(:name){|n|"super_user_name#{n}"}
    password "password"
    password_confirmation "password"
    sequence(:remarks){|n|"remarks#{n}"}
    authority User.authorities[:admin]
    section { create(:section) }
  end

  factory :editor_user, class: User do
    sequence(:login){|n|"editor_user#{n}"}
    sequence(:name){|n|"editor_user_name#{n}"}
    password "password"
    password_confirmation "password"
    sequence(:remarks){|n|"remarks#{n}"}
    authority User.authorities[:editor]
    section { create(:section) }
  end

  factory :section_manager_user, class: User do
    sequence(:login){|n|"section_manager#{n}"}
    sequence(:name){|n|"section_manager_name#{n}"}
    password "password"
    password_confirmation "password"
    sequence(:remarks){|n|"remarks#{n}"}
    authority User.authorities[:section_manager]
    section { create(:section) }
  end
end
