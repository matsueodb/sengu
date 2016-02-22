# == Schema Information
#
# Table name: element_values
#
#  id           :integer          not null, primary key
#  record_id    :integer
#  element_id   :integer
#  content_id   :integer
#  content_type :string(255)
#  kind         :integer
#  template_id  :integer
#  created_at   :datetime
#  updated_at   :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :element_value do
    record_id 1
    element{create(:element)}
    content_id 1
    content_type "ElementValue::StringContent"
    template_id 1
  end
end
