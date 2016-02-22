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
#== １行入力
#
class ElementValue::Line < ElementValue::StringContent

  #=== 引数の値以上の値がセットされている場合Trueが返ること
  #==== 引数
  # * val - String of num
  #==== 戻り値
  # * boolean
  def greater_than?(val)
    if attributes["value"] =~ /^[0-9]+$/
      num = val.respond_to?(:to_i) ? val.to_i : val
      return false if num.blank?
      attributes["value"].to_i >= num
    else
      false
    end
  end

  #=== 引数の値以下の値がセットされている場合Trueが返ること
  #==== 引数
  # * val - String of num
  #==== 戻り値
  # * boolean
  def less_than?(val)
    if attributes["value"] =~ /^[0-9]+$/
      num = val.respond_to?(:to_i) ? val.to_i : val
      return false if num.blank?
      attributes["value"].to_i <= num
    else
      false
    end
  end
end
