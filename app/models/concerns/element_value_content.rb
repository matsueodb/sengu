#
#=== ElmenetValue::XXXContentの共通処理
#
module Concerns::ElementValueContent
  extend ActiveSupport::Concern

  included do
    has_one :element_value, as: :content
  end

  #
  #=== valueを整形して返す
  # クラスによってはオーバーライドして使用する
  #==== 戻り値
  # string
  def formatted_value
    self.value
  end

  #=== 引数の値以上の値がセットされている場合Trueが返ること
  #==== 引数
  # * val - String of Date
  #==== 戻り値
  # * boolean
  def greater_than?(val)
    false
  end

  #=== 引数の値以上の値がセットされている場合Trueが返ること
  #==== 引数
  # * val - String of Date
  #==== 戻り値
  # * boolean
  def less_than?(val)
    false
  end
end