# == Schema Information
#
# Table name: elements
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  entry_name            :string(255)
#  template_id           :integer
#  regular_expression_id :integer
#  parent_id             :integer
#  input_type_id         :integer
#  max_digit_number          :integer
#  description           :string(255)
#  data_example          :string(255)
#  required              :boolean
#  unique                :boolean
#  confirm_entry         :boolean          default(FALSE)
#  display               :boolean
#  source_type           :string(255)
#  source_id             :integer
#  display_number        :integer
#  created_at            :datetime
#  updated_at            :datetime
#  data_input_way        :integer          default(0)
#  source_element_id     :integer
#

# Read about factories at https://github.com/Ma
# thoughtbot/factory_girl

FactoryGirl.define do
  factory :only_element, class: Element do
    sequence(:name) {|n| "輸送関連_輸送業者-#{n}"}
    input_type { create(:input_type_line) }
  end

  factory :element do
    sequence(:name) {|n| "輸送関連_輸送業者-#{n}"}
    input_type { create(:input_type_line) }
    template { create(:template) }

    InputType::TYPE_HUMAN_NAME.each do |name, label|
      factory "element_by_it_#{name}", class: Element do
        sequence(:name) {|n| "輸送関連_輸送業者-#{name}-#{n}"}
        input_type {get_input_type_by_name(name)}
      end
    end

    before(:create) do |el|
      if el.input_type.template? && el.source_element_id.blank?
        template = el.source.blank? ? create(:template) : el.source
        element = create(:element, template_id: template.id)
        el.source_element_id = element.id
      end
    end
  end

  factory :element_set_all_attr, class: Element do
    id                    10000000
    name                  '人＿性別'
    entry_name            'ic:人性別型'
    input_type { create(:input_type_line) }
    template { create(:template) }
    regular_expression_id :integer
    parent_id             10000000
    max_digit_number      100
    min_digit_number      0
    description           '人の性別を表します'
    data_example          '男性・女性'
    required              true
    unique                false
    confirm_entry         false
    display               true
    source_type           "Vocabulary::Element"
    source_id             1000000
  end
end

def get_input_type_by_name(name)
  InputType.find_by(name: name) || create(:"input_type_#{name}")
end
