# == Schema Information
#
# Table name: element_value_text_contents
#
#  id         :integer          not null, primary key
#  value      :text
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ElementValue::TextContent < ActiveRecord::Base
  include Concerns::ElementValueContent
  self.table_name = :element_value_text_contents

  TYPE_CLASSES = ["ElementValue::MultiLine"]
  validates :type, inclusion: {in: TYPE_CLASSES}

  def included_by_keyword?(keyword)
    self.value.include?(keyword)
  end
end
