#
#=== ElmenetValue::XXXTemplateの共通処理
#
module Concerns::ElementValueTemplate
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
    reference.values.find_by(record_id: self.value, element_id: self.element_value.element.source_element_id).try(:content).try(:value)
  end
end
