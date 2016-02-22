# == Schema Information
#
# Table name: input_types
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  label                 :string(255)
#  content_class_name    :string(255)
#  regular_expression_id :integer
#  created_at            :datetime
#  updated_at            :datetime
#

class InputType < ActiveRecord::Base
  before_create :set_content_class_name

  belongs_to :regular_expression

  #=== 位置情報項目
  LOCATION_NAMES = [:kokudo_location, :osm_location, :google_location, :all_locations]

  #=== 他のデータを参照する型
  REFERENCED_NAMES = [:checkbox_template, :checkbox_vocabulary, :pulldown_template, :pulldown_vocabulary]

  #=== checkboxの型
  CHECKBOX_NAMES = [:checkbox_template, :checkbox_vocabulary]

  #=== pulldownの型
  PULLDOWN_NAMES = [:pulldown_template, :pulldown_vocabulary]

  #=== 語彙情報を使用する項目
  VOCABULARY_NAMES = [:checkbox_vocabulary, :pulldown_vocabulary]

  #=== テンプレートのデータを参照する型
  REFERENCED_TEMPLATE_NAMES = [:checkbox_template, :pulldown_template]

  MULTIPLE_TYPE_NAMES = [:line, :multi_line, :dates, :upload_file]

  #
  #=== 入力のタイプ情報
  #
  #* :line 一行入力
  #* :multi_line 複数行入力
  #* :checkbox_template チェックボックス(テンプレートから選択)
  #* :checkbox_vocabulary チェックボックス(語彙から選択)
  #* :pulldown_template プルダウン(テンプレートから選択)
  #* :pulldown_vocabulary プルダウン(語彙から選択)
  #* :kokudo_location 位置情報(国土地理院から選択)
  #* :osm_location 位置情報(OpenStreetMapから選択)
  #* :google_location 位置情報(GoogleMapから選択)
  #* :dates 日付入力
  #* :uplaod_file ファイル
  #* :times 時間入力
  #* :all_locations 位置情報全種類
  #
  TYPE_HUMAN_NAME = {
    line: I18n.t('input_types.types.line'),
    multi_line: I18n.t('input_types.types.multi_line'),
    checkbox_template: I18n.t('input_types.types.checkbox_template'),
    checkbox_vocabulary: I18n.t('input_types.types.checkbox_vocabulary'),
    pulldown_template: I18n.t('input_types.types.pulldown_template'),
    pulldown_vocabulary: I18n.t('input_types.types.pulldown_vocabulary'),
    kokudo_location: I18n.t('input_types.types.kokudo_location'),
    osm_location: I18n.t('input_types.types.osm_location'),
    google_location: I18n.t('input_types.types.google_location'),
    dates: I18n.t('input_types.types.dates'),
    upload_file: I18n.t('input_types.types.upload_file'),
    times: I18n.t('input_types.types.times'),
    all_locations: I18n.t('input_types.types.all_locations')
  }.with_indifferent_access

  TYPE_CLASS_NAME = {
    line: ElementValue::Line,
    multi_line: ElementValue::MultiLine,
    checkbox_template: ElementValue::CheckboxTemplate,
    checkbox_vocabulary: ElementValue::CheckboxVocabulary,
    pulldown_template: ElementValue::PulldownTemplate,
    pulldown_vocabulary: ElementValue::PulldownVocabulary,
    kokudo_location: ElementValue::KokudoLocation,
    osm_location: ElementValue::OsmLocation,
    google_location: ElementValue::GoogleLocation,
    dates: ElementValue::Dates,
    upload_file: ElementValue::UploadFile,
    times: ElementValue::Times,
    all_locations: ElementValue::AllLocations
  }.with_indifferent_access

  scope :locations, -> {where("input_types.name IN (?)", LOCATION_NAMES)}
  scope :vocabularies, -> {where("input_types.name IN (?)", VOCABULARY_NAMES)}
  scope :lines, -> {where("input_types.name = ?", "line")}
  scope :referenced, -> {where("input_types.name IN (?)", REFERENCED_NAMES)}
  scope :referenced_templates, -> {where("input_types.name IN (?)", REFERENCED_TEMPLATE_NAMES)}

  #=== 位置情報か？
  #==== 戻り値
  # * boolean - true: Yes, false: No
  def location?
    self.name.to_sym.in?(LOCATION_NAMES)
  end

  #=== 他のデータを参照する型か？
  #==== 戻り値
  # * boolean - true: Yes, false: No
  def referenced_type?
    self.name.to_sym.in?(REFERENCED_NAMES)
  end

  #=== checkboxの型か？
  #==== 戻り値
  # * boolean - true: Yes, false: No
  def checkbox?
    self.name.to_sym.in?(CHECKBOX_NAMES)
  end

  #=== pulldownの型か？
  #==== 戻り値
  # * boolean - true: Yes, false: No
  def pulldown?
    self.name.to_sym.in?(PULLDOWN_NAMES)
  end

  #=== テンプレートを参照する型か？
  #==== 戻り値
  # * boolean - true: Yes, false: No
  def template?
    self.checkbox_template? || self.pulldown_template?
  end

  #=== 語彙を参照する型か？
  #==== 戻り値
  # * boolean - true: Yes, false: No
  def vocabulary?
    self.checkbox_vocabulary? || self.pulldown_vocabulary?
  end

  #
  #=== selfの入力タイプに、入力制限をかけらるかどうか
  #
  def limitable?
    self.line? || self.multi_line?
  end

  #=== 複数入力が可能なフィールドか
  #==== 戻り値
  # * boolean - true: Yes, false: No
  def multiple?
    self.name.to_sym.in?(MULTIPLE_TYPE_NAMES)
  end

  TYPE_HUMAN_NAME.keys.each do |key|
    define_method("#{key}?") do
      self.name == key.to_s
    end
  end

  class << self
    TYPE_HUMAN_NAME.keys.each do |key|
      define_method("find_#{key}") do
        self.find_by(name: key.to_s)
      end
    end
  end

private

  def set_content_class_name
    self.content_class_name = TYPE_CLASS_NAME[self.name].name
  end
end
