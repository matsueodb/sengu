#
#=== ElmenetValue::XXXVocabularyの共通処理
#
module Concerns::ElementValueVocabulary
  extend ActiveSupport::Concern

  included do
  end

  #
  #=== valueを整形して返す
  # Override
  #==== 戻り値
  # string
  def formatted_value
    return nil if self.value.blank?
    reference.try(:name)
  end
end