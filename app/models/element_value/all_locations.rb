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

#
#== 位置情報（全種類）
#
class ElementValue::AllLocations < ElementValue::StringContent
end
