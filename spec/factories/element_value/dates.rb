FactoryGirl.define do
  factory :element_value_dates, :class => 'ElementValue::Dates' do
    value Date.today
  end
end
