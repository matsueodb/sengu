# == Schema Information
#
# Table name: element_value_string_contents
#
#  id         :integer          not null, primary key
#  value      :string(255)
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ElementValue::StringContent < ActiveRecord::Base
  include Concerns::ElementValueContent
  self.table_name = :element_value_string_contents

  TYPE_CLASSES = [
    "ElementValue::Line",
    "ElementValue::KokudoLocation",
    "ElementValue::GoogleLocation",
    "ElementValue::OsmLocation",
    "ElementValue::AllLocations",
    "ElementValue::UploadFile"
  ]
  validates :type, inclusion: {in: TYPE_CLASSES}

  def included_by_keyword?(keyword)
    self.value.include?(keyword)
  end
end
