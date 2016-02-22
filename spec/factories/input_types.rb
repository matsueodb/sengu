# == Schema Information
#
# Table name: input_types
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  label                 :string(255)
#  content_class_name    :string(255)
#  regular_expression_id :integer
#  created_at            :datetime
#  updated_at            :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :input_type do

    InputType::TYPE_HUMAN_NAME.each do |name, label|
      factory "input_type_#{name}".to_sym do
        name name
        label label
      end
    end
    
  end
end
