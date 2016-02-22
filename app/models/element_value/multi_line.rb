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

#
#== 複数行入力
#
class ElementValue::MultiLine < ElementValue::TextContent
end
