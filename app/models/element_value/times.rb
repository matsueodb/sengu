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

#
#== 時間
#
class ElementValue::Times < ElementValue::DateContent
  # 時間形式の場合、時分のみを保存するが、保存するフィールドがdatetimeなので
  # 2014, 01, 01の日付で設定する。
  BASE_DATE = DateTime.new(2014, 01, 01)

  def formatted_value
    self["value"].try(:strftime, "%H:%M").to_s
  end

  #=== 引数の値以上の値がセットされている場合Trueが返ること
  #==== 引数
  # * val - String of Time
  #==== 戻り値
  # * boolean
  def greater_than?(val)
    date = DateTime.parse(val) rescue nil
    return false if date.blank?
    attributes["value"] >= date
  end

  #=== 引数の値以下の値がセットされている場合Trueが返ること
  #==== 引数
  # * val - String of Time
  #==== 戻り値
  # * boolean
  def less_than?(val)
    date = DateTime.parse(val) rescue nil
    return false if date.blank?
    attributes["value"] <= date
  end
end
