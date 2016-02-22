# == Schema Information
#
# Table name: kokudo_addresses
#
#  id        :integer          not null, primary key
#  street    :string(255)
#  city_id   :integer
#  latitude  :float
#  longitude :float
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :kokudo_address do
    sequence(:street){|n|"#{}丁目"}

    {
      shimane: {street: "学園１丁目", latitude: 35.47633639994709, longitude: 133.06639533211944},
      tottori: {street: "日吉津村",   latitude: 35.44344220946034, longitude: 133.38638305664062},
      okayama: {street: "水島",       latitude: 34.52901736234456, longitude: 133.74343872070312},
      hiroshima: {street: "中区", latitude: 34.381469324354654, longitude: 132.4485969543457},
      yamaguchi: {street: "常盤町", latitude: 33.95035192031285, longitude: 131.25027179718018},
    }.each do |k, v|
      factory :"address_#{k}" do
        street v[:street]
        latitude v[:latitude]
        longitude v[:longitude]
      end
    end
  end
end
