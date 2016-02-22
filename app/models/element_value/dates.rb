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
#== 日付
#
class ElementValue::Dates < ElementValue::DateContent
  after_initialize :set_value

  # String
  # super
  def value
    self["value"].try(:strftime, "%Y-%m-%d").to_s
  end

  #=== 引数の値以上の値がセットされている場合Trueが返ること
  #==== 引数
  # * val - String of Date
  #==== 戻り値
  # * boolean
  def greater_than?(val)
    date = val.respond_to?(:to_date) ? val.to_date : val
    return false if date.blank?
    attributes["value"].to_date >= date
  end

  #=== 引数の値以上の値がセットされている場合Trueが返ること
  #==== 引数
  # * val - String of Date
  #==== 戻り値
  # * boolean
  def less_than?(val)
    date = val.respond_to?(:to_date) ? val.to_date : val
    return false if date.blank?
    attributes["value"].to_date <= date
  end

private

  #
  #=== self["value"]をセット。
  # after_initializeでセットされる
  # DBが日時分秒をもつため、YYYY-MM-DD形式で値が返るようにセットする
  # この処理でデータ編集画面の初期表示の値がYYYY-MM-DDになる
  def set_value
    self["value"] = self.value
  end
end
