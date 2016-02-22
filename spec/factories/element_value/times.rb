FactoryGirl.define do
  factory :element_value_times, :class => 'ElementValue::Times' do
    value DateTime.now
  end
end
