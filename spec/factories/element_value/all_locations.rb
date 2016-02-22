FactoryGirl.define do
  factory :element_value_all_locations, :class => 'ElementValue::AllLocations' do
    factory :element_value_all_locations_kokudo_location_lat do
      value "35.442593"
    end

    factory :element_value_all_locations_osm_location_lat do
      value "36.442593"
    end

    factory :element_value_all_locations_google_location_lat do
      value "37.442593"
    end
    
    factory :element_value_all_locations_kokudo_location_lon do
      value "133.066472"
    end

    factory :element_value_all_locations_osm_location_lon do
      value "134.066472"
    end

    factory :element_value_all_locations_google_location_lon do
      value "135.066472"
    end
  end
end
