FactoryGirl.define do
  factory :element_value_kokudo_location, :class => 'ElementValue::KokudoLocation' do
    factory :element_value_kokudo_location_lat do
      value "35.442593"
    end
    
    factory :element_value_kokudo_location_lon do
      value "133.066472"
    end
  end
end
