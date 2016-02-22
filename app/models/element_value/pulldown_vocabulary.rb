# == Schema Information
#
# Table name: element_value_identifier_contents
#
#  id         :integer          not null, primary key
#  value      :integer
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

#
#== プルダウン（語彙）
#
class ElementValue::PulldownVocabulary < ElementValue::IdentifierContent
  include Concerns::ElementValueVocabulary
  REFERENCE_CLASS = "Vocabulary::ElementValue"

  #
  #=== 参照先のクラスを返す。
  #
  def reference_class
    REFERENCE_CLASS.constantize
  end

  def included_by_keyword?(keyword)
    self.reference.name.include?(keyword)
  end
end
