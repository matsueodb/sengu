FactoryGirl.define do
  factory :element_value_osm_location, :class => 'ElementValue::OsmLocation' do
    factory :element_value_osm_location_lat do
      value "35.442593"
    end
    
    factory :element_value_osm_location_lon do
      value "133.066472"
    end
  end
end
