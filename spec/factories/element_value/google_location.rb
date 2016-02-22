FactoryGirl.define do
  factory :element_value_google_location, :class => 'ElementValue::GoogleLocation' do
    factory :element_value_google_location_lat do
      value "35.442593"
    end
    
    factory :element_value_google_location_lon do
      value "133.066472"
    end
  end
end
