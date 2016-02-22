# == Schema Information
#
# Table name: element_values
#
#  id                :integer          not null, primary key
#  record_id         :integer
#  element_id        :integer
#  content_id        :integer
#  content_type      :string(255)
#  kind              :integer
#  template_id       :integer
#  created_at        :datetime
#  updated_at        :datetime
#  item_number       :integer          default(1)
#  repeat_element_id :integer
#

class ElementValue < ActiveRecord::Base
  LATITUDE_KIND = 1 # 緯度
  LONGITUDE_KIND = 2 # 経度
  LABEL_KIND = 1 # ラベル
  FILE_KIND = 2 # ファイル
  ALL_LOCATIONS_KINDS = {
    kokudo_location: {latitude: 1, longitude: 2},
    osm_location: {latitude: 3, longitude: 4},
    google_location: {latitude: 5, longitude: 6},
  }
  KINDS = {
    kokudo_location: {latitude: LATITUDE_KIND, longitude: LONGITUDE_KIND},
    osm_location: {latitude: LATITUDE_KIND, longitude: LONGITUDE_KIND},
    google_location: {latitude: LATITUDE_KIND, longitude: LONGITUDE_KIND},
    all_locations: ALL_LOCATIONS_KINDS,
    upload_file: {label: LABEL_KIND, file: FILE_KIND}
  }.with_indifferent_access

  ELEMENT_VALUE_CONTENT_CLASSES = [
    ElementValue::StringContent,
    ElementValue::TextContent,
    ElementValue::IdentifierContent,
    ElementValue::DateContent
  ]

  belongs_to :template
  belongs_to :template_record, foreign_key: :record_id
  belongs_to :element
  belongs_to :content, polymorphic: true, dependent: :destroy, autosave: true

  scope :by_elements, -> e_id{where(element_id: e_id).order("element_values.kind")}

  attr_writer :value, :skip_reject

  accepts_nested_attributes_for :content

  validates :item_number, presence: true
  validates :content_type,
    inclusion: {in: ELEMENT_VALUE_CONTENT_CLASSES.map(&:name)}

  before_validation :set_repeat_element_id

  #=== 値を返す
  # セッターに値がセットされている場合はその値を返す。
  # 値がセットされていない場合はcontentのvalueを返す。
  def value
    @value || self.content.try(:value)
  end

  #
  #=== valueを整形して返す
  #==== 戻り値
  # string
  def formatted_value
    self.content.try(:formatted_value)
  end

  #
  #=== 引数で渡したテンプレート上で編集が可能か？
  #==== 引数
  # * tp - Templateインスタンス
  #==== 戻り値
  # * boolean - true: 可, false: 不可
  def editable_on?(tp)
    self.template_id == tp.id
  end

  #
  #=== contentをbuildする。
  # polymorphicのときはbuild_+++のメソッドが作られないため定義している
  # 本メソッドはTemplateRecord.new(values_attributes:{content_attributes: {value: "example"}}
  # のようなときに呼ばれる。
  def build_content(attr = {})
    self.content = self.content_type.constantize.new(attr) if self.content.blank?
  end

  def included_by_keyword?(keyword)
    self.content.included_by_keyword?(keyword)
  end

private

  #repeat_element_idをセット
  def set_repeat_element_id
    return if self.element.parent_id.blank?
    el = self.element
    until el.multiple_input?
      el = el.parent
      return if el.blank?
    end

    self.repeat_element_id = el.id
  end
end
