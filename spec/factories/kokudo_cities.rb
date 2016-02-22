# == Schema Information
#
# Table name: kokudo_cities
#
#  id      :integer          not null, primary key
#  name    :string(255)
#  pref_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :kokudo_city do
    sequence(:name){|n|"松江#{n}市"}
    {
      shimane: "松江市",
      tottori: "米子市",
      okayama: "倉敷市",
      hiroshima: "広島市",
      yamaguchi: "宇部市",
    }.each do |k, v|
      factory :"city_#{k}" do
        name v

        trait :with_city_and_address do
          addresses{[create(:"address_#{k}")]}
        end

        factory :"city_#{k}_with_address", traits: [:with_city_and_address]
      end
    end
  end
end
