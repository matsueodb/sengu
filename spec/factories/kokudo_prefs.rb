# == Schema Information
#
# Table name: kokudo_prefs
#
#  id   :integer          not null, primary key
#  name :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :kokudo_pref do
    sequence(:name){|n|"島根#{n}県"}

    {
      shimane: "島根県",
      tottori: "鳥取県",
      okayama: "岡山県",
      hiroshima: "広島県",
      yamaguchi: "山口県",
    }.each do |k, v|
      factory :"pref_#{k}" do
        name v

        trait :with_city_and_address do
          cities{ [create(:"city_#{k}_with_address")]}
        end

        factory :"pref_#{k}_with_city_and_address", traits: [:with_city_and_address]
      end
    end
  end
end
