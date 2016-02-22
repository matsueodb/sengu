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

#
#== プルダウン（テンプレート）
#
class ElementValue::PulldownTemplate < ElementValue::IdentifierContent
  include Concerns::ElementValueTemplate
  REFERENCE_CLASS = "TemplateRecord"

  #
  #=== 参照先のクラスを返す。
  #
  def reference_class
    REFERENCE_CLASS.constantize
  end

  def included_by_keyword?(keyword)
    # 関連付けデータは検索対象にしない
    false
  end
end
