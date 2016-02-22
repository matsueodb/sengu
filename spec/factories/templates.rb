# == Schema Information
#
# Table name: templates
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  user_id       :integer
#  user_group_id :integer
#  service_id    :integer
#  parent_id     :integer
#  status        :integer          default(1)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :template do
    sequence(:name){|n|"観光施設テンプレート#{n}"}
    service { create(:service) }
    user {create(:super_user)}

    trait :all_type_elements do
      after(:create) do |t|
        create(:element_by_it_line, template_id: t.id)
        create(:element_by_it_multi_line, template_id: t.id)
        create(:element_by_it_checkbox_template, source_id: create(:template).id, template_id: t.id)
        create(:element_by_it_checkbox_vocabulary, source_id: create(:vocabulary_element).id, template_id: t.id)
        create(:element_by_it_pulldown_template, source_id: create(:template).id, template_id: t.id)
        create(:element_by_it_pulldown_vocabulary, source_id: create(:vocabulary_element).id, template_id: t.id)
        create(:element_by_it_kokudo_location, template_id: t.id)
        create(:element_by_it_osm_location, template_id: t.id)
        create(:element_by_it_google_location, template_id: t.id)
        create(:element_by_it_dates, template_id: t.id)
        create_list(:template_records_with_values, 3, template_id: t.id)
      end
    end

    factory :template_with_records_all_type, traits: [:all_type_elements]
  end

  factory :template_with_elements, class: Template do
    service_id 1
    sequence(:name){|n|"観光施設テンプレート#{n}"}
    user {create(:super_user)}
    after(:create) {|t| 3.times{ create(:only_element, template_id: t.id) } }
  end
end
