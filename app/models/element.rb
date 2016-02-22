# == Schema Information
#
# Table name: elements
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  entry_name            :string(255)
#  template_id           :integer
#  regular_expression_id :integer
#  parent_id             :integer
#  input_type_id         :integer
#  max_digit_number      :integer
#  description           :string(255)
#  data_example          :string(255)
#  required              :boolean          default(FALSE)
#  unique                :boolean          default(FALSE)
#  confirm_entry         :boolean          default(FALSE)
#  display               :boolean          default(TRUE)
#  source_type           :string(255)
#  source_id             :integer
#  display_number        :integer
#  created_at            :datetime
#  updated_at            :datetime
#  data_input_way        :integer          default(0)
#  source_element_id     :integer
#  min_digit_number      :integer
#  multiple_input        :boolean
#  available             :boolean          default(TRUE)
#  publish               :boolean          default(TRUE)
#  data_type             :string(255)
#  domain_id             :string(255)
#

#
#== RDF目的語
#
class Element < ActiveRecord::Base
  DATA_INPUT_WAY_CHECKBOX = 0 # checkbox
  DATA_INPUT_WAY_PULLDOWN = 0 # pulldown
  DATA_INPUT_WAY_POPUP = 1 # Popup Modal
  DATA_INPUT_WAY_RADIO_BUTTON = 2 # radio button
  DATA_INPUT_WAYS = {
    checkbox_template: {checkbox: DATA_INPUT_WAY_CHECKBOX, popup: DATA_INPUT_WAY_POPUP},
    checkbox_vocabulary: {checkbox: DATA_INPUT_WAY_CHECKBOX, popup: DATA_INPUT_WAY_POPUP},
    pulldown_template: {pulldown: DATA_INPUT_WAY_PULLDOWN, popup: DATA_INPUT_WAY_POPUP, radio: DATA_INPUT_WAY_RADIO_BUTTON},
    pulldown_vocabulary: {pulldown: DATA_INPUT_WAY_PULLDOWN, popup: DATA_INPUT_WAY_POPUP, radio: DATA_INPUT_WAY_RADIO_BUTTON}
  }.with_indifferent_access
  belongs_to :template
  belongs_to :input_type
  belongs_to :regular_expression
  belongs_to :source, polymorphic: true
  belongs_to :source_element, foreign_key: :source_element_id, class_name: "Element"
  belongs_to :parent, foreign_key: :parent_id, class_name: "Element"

  has_many :children, ->{order("display_number")}, foreign_key: :parent_id, class_name: "Element", dependent: :destroy
  has_many :values, foreign_key: :element_id, class_name: "ElementValue",  dependent: :destroy

  delegate :label, to: :input_type, prefix: true
  delegate :template?, to: :input_type, prefix: true

  scope :locations, -> {joins(:input_type).merge(InputType.locations)}
  scope :lines, -> {joins(:input_type).merge(InputType.lines)}
  scope :referenced, -> {joins(:input_type).merge(InputType.referenced)}
  scope :root, -> {where("parent_id IS NULL")}
  scope :displays, -> {where(display: true)}
  scope :availables, -> {where(available: true)}
  scope :publishes, -> {where(publish: true)}

  before_validation :set_display_number
  before_validation :set_regular_expression_id
  before_validation :set_value_for_source_type

  attr_writer :full_name

  validates :name,
    presence: true,
    length: { maximum: 255 },
    uniqueness: {
      scope: [:template_id, :parent_id]
    }
  validates :input_type_id,
    presence: true
  validates :max_digit_number,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: Proc.new{|e| (e.min_digit_number? && e.min_digit_number >= 0 && e.min_digit_number <= 10000) ? e.min_digit_number : 1},
      less_than_or_equal_to: 10000
    },
    allow_blank: true
  validates :min_digit_number,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: Proc.new{|e| (e.max_digit_number && e.max_digit_number >= 1 && e.max_digit_number <= 10000) ? e.max_digit_number : 10000 }
    },
    allow_blank: true
  validates :source_id,
    presence: {
      if: Proc.new{|e| e.input_type.try(:referenced_type?) }
    }
  validates :source_element_id,
    presence: {
      if: Proc.new{|e| e.input_type.try(:template?) }
    }
  validates :description,
    length: { maximum: 255 }
  validates :data_example,
    length: { maximum: 255 }
  validates :data_input_way,
    inclusion: {
      :in => proc{|e|DATA_INPUT_WAYS[e.input_type.name].values},
      :if => proc{|e|DATA_INPUT_WAYS[e.input_type.try(:name)].present?}
    }

  validate :uniqueness_name_valid, if: Proc.new{|e| self.parent_id.nil? }
  validate :change_attribute_valid,
    on: :update,
    if: Proc.new{|e| self.values.exists? }
  validate :parent_depth_valid,
    on: :update,
    if: Proc.new{|e| self.parent_id.present? && self.entry_name.blank?}
  validate :multiple_input_valid,
    on: :update
  validate :illegality_name_valid

  #
  #=== 入力条件を文字列の配列で返す。
  #==== 戻り値
  # * Array(string..)
  def input_conditions
    lists = []
    if re = self.regular_expression
      lists << re.name
    end
    lists << Element.human_attribute_name(:unique) if self.unique
    lists << Element.human_attribute_name(:required) if self.required
    if self.max_digit_number.present?
      str = Element.human_attribute_name(:max_digit_number) + I18n.t("element.input_conditions.max_digit_number", count: self.max_digit_number)
      lists << str
    end
    if self.min_digit_number.present?
      str = Element.human_attribute_name(:min_digit_number) + I18n.t("element.input_conditions.min_digit_number", count: self.min_digit_number)
      lists << str
    end
    lists
  end

  #
  #=== 引数で渡されたidの格納順にdisplay_numberを更新する
  #
  #=== 戻り値
  #
  # * 成功 => true
  # * 失敗 => false
  def self.change_order(ids)
    self.transaction do
      ids.each_with_index do |id, idx|
        Element.where('id = ?', id).update_all(display_number: idx)
      end
      return true
    end
    rescue
      return false
  end

  #
  #=== 子要素を全て返す
  # 無ければ自分自身を返す
  #
  def last_children(options={}, &block)
    options = {available: true, publish: false}.merge(options)
    last_elements = self.children
    last_elements = last_elements.availables if options[:available]
    last_elements = last_elements.publishes if options[:publish]

    last_elements = (block_given? ? block.call(last_elements).to_a : last_elements.to_a)
    if last_elements.blank?
      last_elements << self
    else
      last_elements = last_elements.map{|e| e.last_children(options, &block) }.flatten
    end
    return last_elements.flatten
  end

  #=== データ入力方法がチェックボックスか？
  def data_input_way_checkbox?
    self.data_input_way == DATA_INPUT_WAY_CHECKBOX
  end

  #=== データ入力方法がプルダウンか？
  def data_input_way_pulldown?
    self.data_input_way == DATA_INPUT_WAY_PULLDOWN
  end

  #=== データ入力方法がラジオボタンか？
  def data_input_way_radio?
    self.data_input_way == DATA_INPUT_WAY_RADIO_BUTTON
  end

  #=== データ入力方法がポップアップか？
  def data_input_way_popup?
    self.data_input_way == DATA_INPUT_WAY_POPUP
  end

  #
  #=== 関連先のデータを返す。
  # Templateの場合は、返す値はsource_element_idの値に該当するElementValue
  #
  def reference_values
    case self.source_type
    when Template.name
      so = self.source
      template_ids = so.has_parent? ? [self.source_id, so.parent_id] : [self.source_id]
      ElementValue.includes(:content)
                  .where(element_id: self.source_element_id)
                  .where("element_values.template_id IN (?)", template_ids)
                  .order("record_id")
    when Vocabulary::Element.name
      self.source.values
    end
  end

  #
  #=== 再利用する為にコピーしてビルドを行う
  #
  def reuse_build(template_id)
    parent_element = self.dup
    parent_element.attributes = {template_id: template_id, parent_id: nil, display_number: nil}
    self.children.each do |child_element|
      parent_element.children << child_element.reuse_build(template_id)
    end
    parent_element
  end

  #
  #== 再利用する
  #
  def reuse(template_id)
    element = self.reuse_build(template_id)
    element.save
  end

  #
  #=== 関連データのラジオボタンやプルダウンで使用する一覧を返す。
  #
  def selection_of_reference_values
    reference_values = self.reference_values
    case self.source_type
    when Template.name
      return reference_values.group_by(&:record_id).map do |record_id, vals|
        [vals.sort_by(&:item_number).map(&:formatted_value).join(","), record_id]
      end
    when Vocabulary::Element.name
      return reference_values.map{|v|[v.name, v.id]}
    end
  end

  #
  #=== 指定されたテンプレートのIDと、項目にひもづくElementValueをoptional_valuesアクセサにセットする
  #
  # 項目にユニーク制限がかけれた場合に使用する(登録予定のデータ全体でのユニークにする)
  #
  def load_values_by_template_ids(template_ids, override_values=[])
    if @optional_values.nil?
      @optional_values = self.values.where(template_id: template_ids).includes(:content).to_a
    end
    override_values.each do |e_v|
      if e_v.new_record?
        @optional_values << e_v
      else
        index = @optional_values.index{|o_v| o_v.id == e_v.id}
        @optional_values[index] = e_v
      end
    end
    @optional_values
  end

  #
  #=== 参照データを登録される場合に登録可能なIDの一覧を返す
  #  二回目以降は以前に取得したデータを返す(CSV一括登録の際に必要)
  #
  def registerable_reference_ids
    if @reference_value_ids.nil?
      case self.source_type
      when Template.name
        ids = self.source.all_records.pluck(:id)
      when Vocabulary::Element.name
        ids = self.reference_values.pluck(:id)
      else
        ids = []
      end
      @reference_value_ids = ids
    end
    @reference_value_ids
  end

  #
  #=== コードリストの値の配列を返却する
  #
  def code_list_values
    if self.input_type.referenced_type?
      source = self.source
      case self.source_type
      when Template.name
        ElementValue.where(record_id: source.all_records.pluck(:id), element_id: self.source_element_id).map(&:formatted_value)
      when Vocabulary::Element.name
        source.values.pluck(:name)
      end
    else
      []
    end
  end

  #
  #=== コードリストの値とIDをセットにした配列を返す
  #
  def code_list_id_with_values
    if @id_and_values.nil?
      if self.input_type.referenced_type?
        source = self.source
        case self.source_type
        when Template.name
          vals = ElementValue.where(record_id: source.all_records.pluck(:id), element_id: self.source_element_id)
          @id_and_values = vals.map{|v| {v.formatted_value => v.record_id} }
        when Vocabulary::Element.name
          @id_and_values = source.values.map{|v| {v.name => v.id} }
        end
      else
        @id_and_values = []
      end
    else
      @id_and_values
    end
  end

  #
  #=== 削除することができるエレメントかを返す
  #  自分だけではなく、自分を含めた子孫全てが削除条件を満たす必要がある。
  #  拡張基ではなく、関連づけされていない項目の場合削除できる
  def destroyable?
    self.descendent.all? do |e|
      !e.template.has_extension? && !Element.where(source_element_id: e.id).exists?
    end
  end

  #
  #=== 子孫要素を全て返す
  #
  def descendent(include_self = true)
    ret = []
    ret << self if include_self
    children.each { |e| ret += e.descendent }
    ret
  end

  def all_parents(cache = false)
    if cache && all_parents
      @all_parents
    else
      p = self.parent
      parents = [p]
      if p.nil?
        @all_parents = []
      else
        parents.unshift(p.all_parents)
        @all_parents = parents.flatten
      end
    end
  end

  #
  #=== 子孫要素を全て返す
  #
  def children_multiple_inputable(skip_self = true)
    els = self.children.includes(:children)
    if els.present?
      if !skip_self && self.multiple_input?
        return false
      else
        els.all?{|e| e.children_multiple_inputable(false) }
      end
    else
      return true
    end
  end

  #
  #=== エレメントがネームスペースか？
  #
  def namespace?
    if self.persisted? && !self.children.loaded?
      # .childrenがロードされていない場合は、DBアクセス
      self.children.exists?
    else
      self.children.present?
    end
  end

  #
  #=== 自身と、その子要素の並び順（一覧表示したときの、上からの並び順）を計算する
  # current_numberは、現在の並び順の最大値
  def calculate_flat_display_numbers(current_number, flat_display_numbers)
    self.children.each do |child_el|
      flat_display_numbers[child_el.id] = current_number += 1
      current_number = child_el.calculate_flat_display_numbers(current_number, flat_display_numbers)
    end
    current_number
  end

  #
  #=== RDFで出力する際の'rdf:about'属性の値を返す
  #
  def about_url_for_rdf(template)
    Rails.application.routes.url_helpers.template_element_path(template, self)
  end

  #
  #=== 祖先が入力可能かどうか
  #
  def ancestor_available?
    !self.all_parents.any?{ |e| !e.available }
  end

  #
  #=== 自身がavailableでも、祖先がavailableで無ければ入力できないため、その判定をする
  #
  def actually_available?
    self.available && self.ancestor_available?
  end

  #
  #=== ネームスペース入りのフルネームを返す
  #
  def full_name
    self.all_parents(true).push(self).map(&:name).join(':')
  end

  #
  #=== 祖先の中で複数入力に設定されている項目を返す
  #
  def multiple_input_ancestor(element = nil)
    target = element || self
    return target if target.multiple_input?
    return nil unless target.parent
    multiple_input_ancestor(target.parent)
  end

private

  #
  #=== 保存時にdisplay_numberを更新する
  # display_numberがnilか、parent_idが変更された際に最大値を格納する
  #
  def set_display_number
    if self.display_number.nil? || self.parent_id_changed?
      max_num = Element.where(template_id: self.template_id, parent_id: self.parent_id).maximum(:display_number)
      self.display_number = max_num.nil? ? 0 : max_num + 1
    end
  end

  #
  #=== 保存時にregular_expression_idを更新する
  # regular_expression_idがnilの場合、input_typeに対応するregular_expression_idを格納する
  #
  def set_regular_expression_id
    input_type = self.input_type
    if input_type.try(:regular_expression_id).present?
      self.regular_expression_id = input_type.regular_expression_id
    end
  end

  #
  #=== 保存時にsource_typeを更新する
  # input_typeに対応するsource_typeをセットして他の項目を調整する
  #
  def set_value_for_source_type
    if input_type = self.input_type
      if input_type.referenced_type?
        self.max_digit_number, self.min_digit_number = nil, nil
        if input_type.template?
          self.source_type = Template.name
        elsif input_type.vocabulary?
          self.source_type = Vocabulary::Element.name
          self.source_element_id = nil
        end
      else
        if input_type.dates? || input_type.location? || input_type.upload_file?
          self.max_digit_number, self.min_digit_number = nil, nil
        end
        self.unique, self.data_example, self.regular_expression_id = nil, nil, nil if input_type.upload_file?
        self.source_element_id = nil
        self.source = nil
      end
    end
  end

  #
  #=== name属性のカスタムバリデーション
  # 拡張基のテンプレートに同じ名前の項目名がないかをチェックする
  #
  def uniqueness_name_valid
    if parent = self.template.try(:parent)
      if parent.elements.root.exists?(name: self.name)
        errors.add(:name, I18n.t('errors.messages.taken'))
      end
    end
  end

  #
  #=== 各属性のカスタムバリデーション
  # 更新かつ、自身のIDをもつElementValueがある場合に呼び出される
  #
  # 既にデータが登録されている場合は、下記の項目は変更不可にする
  # * 項目名
  # * 入力タイプ
  # * 入力値制限
  # * 桁数
  # * 親要素
  # * 必須項目
  # * ユニーク
  def change_attribute_valid
    errors.add(:name, I18n.t('errors.messages.exist_data')) if self.name_changed?
    errors.add(:input_type_id, I18n.t('errors.messages.exist_data')) if self.input_type_id_changed?
    errors.add(:regular_expression_id, I18n.t('errors.messages.exist_data')) if self.regular_expression_id_changed?
    errors.add(:max_digit_number, I18n.t('errors.messages.exist_data')) if self.max_digit_number_changed?
    errors.add(:min_digit_number, I18n.t('errors.messages.exist_data')) if self.min_digit_number_changed?
    errors.add(:parent_id, I18n.t('errors.messages.exist_data')) if self.parent_id_changed?
    errors.add(:required, I18n.t('errors.messages.exist_data')) if self.required_changed?
    errors.add(:unique, I18n.t('errors.messages.exist_data')) if self.unique_changed?
  end

  #
  #=== 親子関係のバリデーション
  # 親子関係は深さ1までしか許容しない
  #
  def parent_depth_valid
    errors.add(:parent_id, I18n.t('errors.messages.parent_too_depth')) if self.parent.try(:parent).present?
  end

  #
  #=== 複数入力のバリデーション
  # 親、または子に複数入力を使用しているネームスペースが無いかを検証する
  #
  def multiple_input_valid
    if self.multiple_input? && self.all_parents.any?{|e| e.multiple_input? } || !self.children_multiple_inputable
      errors.add(:multiple_input, I18n.t('errors.messages.already_multiple_input_availability'))
    end
  end

  #
  #=== 名前に不正な文字が使用されていないかのバリデーション
  #
  def illegality_name_valid
    errors.add(:name, I18n.t('errors.messages.illegality_character')) if self.name.to_s.include?(':')
  end
end
