#
#== テンプレートの関連づけをしているデータの検索
#
class ElementRelationContentSearch
  include ActiveModel::Model

  attr_accessor :keyword, :element, :element_id, :input_type
  attr_reader :reference_template

  def initialize(attr = {})
    super
    self.element = Element.find(self.element_id)
    self.input_type = self.element.input_type
  end

  #
  #=== アクセサにセットされた情報をもとに検索を行う
  #==== 戻り値
  # Array
  def search
    @reference_template = self.element.source

    case self.element.source_type
    when Template.name
      vals = self.element.reference_values.group_by(&:record_id)
      return (self.keyword.present? ? vals.select{|r_id, evs|evs.any?{|ev|ev.included_by_keyword?(self.keyword)}} : vals)
    when Vocabulary::Element.name
      vals = @reference_template.records_referenced_from_element
      return (self.keyword.present? ? vals.where("name LIKE ?", "%#{self.keyword}%") : vals)
    end
  end
end
