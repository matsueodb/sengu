# == Schema Information
#
# Table name: regular_expressions
#
#  id       :integer          not null, primary key
#  name     :string(255)
#  format   :string(255)
#  option   :string(255)
#  editable :boolean          default(TRUE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :regular_expression do
    sequence(:name) {|n|"name_#{n}"}
    sequence(:format) {|n|"^format#{n}"}

    factory :regular_expression_email do
      name "メールアドレス"
      format '^[a-z0-9_\.\-]+@[a-z0-9_\.\-]+\.[a-z0-9_\.\-]+$' # シングルクォートでないとエスケープされる
      option "i"
      editable false
    end
  end
end
