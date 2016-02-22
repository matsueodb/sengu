# == Schema Information
#
# Table name: element_value_date_contents
#
#  id         :integer          not null, primary key
#  value      :datetime
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ElementValue::DateContent < ActiveRecord::Base
  include Concerns::ElementValueContent
  self.table_name = :element_value_date_contents

  TYPE_CLASSES = ["ElementValue::Dates", "ElementValue::Times"]
  validates :type, inclusion: {in: TYPE_CLASSES}

  #
  #=== valueを整形して返す
  # Override
  #==== 戻り値
  # string
  def formatted_value
    self.value
  end

  def included_by_keyword?(keyword)
    self.value.include?(keyword)
  end
end
