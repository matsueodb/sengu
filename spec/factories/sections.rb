# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :section do
    sequence(:name){|n|"営業#{n}課"}
  end
end
