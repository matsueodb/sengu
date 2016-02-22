# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vocabulary_keyword, :class => 'Vocabulary::Keyword' do
    sequence(:name){|n| "建物_場所_#{n}"}
    content "施設の場所"
    user_id 1
    scope 1
    category "人、住民"

    factory :vocabulary_keyword_whole do
      scope Vocabulary::Keyword::SCOPES[:whole]
    end

    factory :vocabulary_keyword_individual do
      scope Vocabulary::Keyword::SCOPES[:individual]
    end
  end
end
