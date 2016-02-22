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

class ElementValue::IdentifierContent < ActiveRecord::Base
  include Concerns::ElementValueContent
  self.table_name = :element_value_identifier_contents

  TYPE_CLASSES = ["ElementValue::CheckboxTemplate", "ElementValue::CheckboxVocabulary",
    "ElementValue::PulldownTemplate", "ElementValue::PulldownVocabulary"]
  validates :type, inclusion: {in: TYPE_CLASSES}

  #
  #=== 参照先のレコードを取得
  #
  def reference
    reference_class.find(self.value) if self.value
  end
end
