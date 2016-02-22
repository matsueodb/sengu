require 'csv'
require 'kconv'

#
#== テンプレートデータの検索を行うモデル
#
class ImportCSV
  include ActiveModel::Model

  ID_COL_IDX = 0
  ID_COL_NAME = 'id'

  attr_accessor :user, :template, :elements, :records, :csv, :rows, :header

  validates :csv, presence: true
  validate :header_valid, if: Proc.new{|i_c| i_c.csv.present?}
  validate :rows_valid, if: Proc.new{|i_c| i_c.csv.present?}
  validate :record_valid

  #
  #=== 初期化
  #
  # * csvファイルの読み込み・アクセッサへのセット
  # * csvヘッダーと行の取得
  # * 入力するテンプレート項目の取得
  #
  def initialize(attr={})
    super(attr)
    if self.template.present?
      @last_item_numbers, @repeat_idx_by_record = {}, {}
      self.records, self.rows = [], []
      self.elements = self.template.inputable_elements{|e| e.includes(:template, :parent, :input_type, :regular_expression, :source)}
      if self.csv = csv_file_read
        parse_csv
        build_csv_row
      end
    end
  end

  #
  #=== 保存する
  #
  def save
    if self.valid? && !self.records.any?{|r| r.errors.any? }
      ActiveRecord::Base.transaction do
        self.records.each{|r| r.save!(validate: false) }
        ImportCSV.remove_csv_file(self.user.id, self.template.id)
        return true
      end
    else
      return false
    end
  rescue
    return false
  end

  #
  #=== CSV行をもとにビルドする
  #
  def build_csv_row
    self.rows.each.with_index(2) do |row, row_idx|
      t_r = find_or_build_template_record(row)
      t_r.line_numbers << row_idx
      values_attributes, attributes_idx = {}, 0
      @repeat_idx_by_record[t_r.id] = 0 if t_r.id.present? && !@repeat_idx_by_record.has_key?(t_r.id)

      row.each_with_index do |values, value_idx|
        element = self.elements[value_idx - 1]
        if value_idx != ID_COL_IDX && element
          split_values = (values =~ /^".+"$/ ? values.gsub(/"/, '').split(',') : [values]).compact
          input_type = element.input_type
          item_number = get_current_item_number(t_r, element)
          record_values = t_r.values.select{|v| v.element_id == element.id && v.item_number == item_number }

          if split_values.count > record_values.count
            (split_values.count - record_values.count).times do
              record_values << ElementValue.new(
                record_id: t_r.id,
                element_id: element.id,
                content_type: input_type.content_class_name.constantize.superclass.to_s,
                template_id: self.template.id,
                item_number: item_number
              )
            end
            necessary_values = record_values
            unnecessary_values = []
          else
            necessary_values = record_values[0...split_values.count]
            unnecessary_values = record_values - necessary_values
          end

          necessary_values.each_with_index do |element_value, v_idx|
            unless split_values[v_idx].blank? && element_value.new_record?
              registered_value = split_values[v_idx]
              if input_type.location?
                if input_type.all_locations?
                  element_value.kind = ElementValue::ALL_LOCATIONS_KINDS.values.map(&:values).flatten[v_idx]
                else
                  element_value.kind = (v_idx == 0 ? ElementValue::LATITUDE_KIND : ElementValue::LONGITUDE_KIND)
                end
              elsif input_type.referenced_type?
                ref_values = element.code_list_id_with_values.detect{|id_and_val| id_and_val.has_key?(registered_value) }
                if ref_values
                  registered_value = ref_values[registered_value]
                  element_value.kind = registered_value
                end
              end
              attributes = element_value.attributes.merge(
                skip_reject: true,
                content_attributes: {
                  id: element_value.content.try(:id),
                  type: input_type.content_class_name,
                  value: registered_value
                }
              )
              values_attributes[attributes_idx] = attributes
              element_value.attributes = attributes
              attributes_idx += 1
            end
          end

          unnecessary_values.each do |element_value|
            values_attributes[attributes_idx] = element_value.attributes.merge(_destroy: 1)
            attributes_idx += 1
          end
        end
      end
      t_r.values_attributes = values_attributes
      @repeat_idx_by_record[t_r.id] += 1 if t_r.id.present? && @repeat_idx_by_record.has_key?(t_r.id)
    end
    self.records.each{|r| r.id = nil if r.new_record? }
  end

  #
  #=== 引数で渡されたCSVの行を基にTemplateRecordのインスタンスを取得する
  # idからレコードを検索し、無ければビルドする。その際にIDが指定されていたらそのIDも新規レコードにセットする。
  # IDはグループを識別するために使用される為、新規レコードでIDの指定があるものは保存時にそのIDは無効になる
  #
  def find_or_build_template_record(row)
    if record_id = row.first
      t_r = self.records.detect{|r| r.id == record_id.to_i} || build_template_record(record_id)
      @last_item_numbers[t_r.id] = {} unless @last_item_numbers.has_key?(t_r.id)
    else
      t_r = build_template_record
    end
    t_r.line_numbers ||= []
    return t_r
  end

  #
  #=== TemplateRecordインスタンスを作成する
  #
  def build_template_record(record_id=nil)
    t_r = self.template.template_records.build(id: record_id, template: self.template, user_id: self.user.id)
    self.records << t_r
    return t_r
  end

  #
  #=== 最後のitem_number + 1を取得する
  #
  def get_last_item_number(record, element)
    if record.id.present?
      item_number_by_elements = @last_item_numbers.fetch(record.id, {})
      if item_number_by_elements.has_key?(element.id)
        item_number = item_number_by_elements[element.id]
      else
        item_number = record.values.select{|v| v.element_id == element.id }.map(&:item_number).max.to_i
      end
      item_number_by_elements[element.id] = (item_number += 1)
      return item_number
    else
      return 1
    end
  end

  #
  #=== 現在のitem_numberを取得する
  #
  def get_current_item_number(record, element)
    repeat_idx = @repeat_idx_by_record.fetch(record.id, 0)

    item_number = record.values.select{|v| v.element_id == element.id }.sort_by(&:item_number).map(&:item_number).uniq.max
    if item_number
      if (repeat_idx + 1) > item_number
        item_number = get_last_item_number(record, element)
      else
        item_number = repeat_idx + 1
      end
    else
      item_number = get_last_item_number(record, element)
    end

    return item_number
  end

  #
  #=== TemplateRecordのバリデーション
  #
  # 本来のバリデーションは保存の際に呼び出さないので、このメソッドで明示的に呼び出す。
  # 本来のバリデーションメソッドではデータベースアクセスが大量に発生してしまうため
  #
  def record_valid
    self.records.each do |record|
      if record.editable?(self.user)
        self.elements.each do |element|
          element_values = record.values.select{|v| v.element_id == element.id && !v._destroy }
          record.validation_of_presence(element, element_values)
          record.validation_of_uniqueness_on_import_csv(element, element_values)
          record.validation_of_length(element, element_values)
          record.validation_by_regular_expression(element, element_values)
          record.validation_of_location(element, element_values)
          record.validation_by_reference_values(element, element_values)
          record.validation_of_line(element, element_values)
          if element_values.map(&:item_number).uniq.count > 1 && !element.all_parents.map(&:multiple_input).include?(true)
            record.errors.add(:base, I18n.t('errors.messages.not_multiple_input'))
          end
        end
      else
        record.errors.add(:base, I18n.t("errors.messages.no_permission_for_update"))
      end
    end
  end

  #
  #=== CSVファイルの削除
  #
  def self.remove_csv_file(user_id, template_id)
    path = csv_file_path(user_id, template_id)
    File.delete(path) if File.exists?(path)
  end

  #
  #=== 指定されたuser_idのディレクトリを削除する
  #
  def self.remove_user_dir(user_id)
    dir_path = File.join(Settings.files.csv_dir_path, user_id.to_s)
    if FileTest.exists?(dir_path)
      FileUtils.rm_rf(dir_path)
    end
  end

  #
  #=== ユーザIDとTemplateIDから既にアップロードされたCSVがあるかどうかを返す
  #
  def self.csv_exists?(user_id, template_id)
    File.exists?(csv_file_path(user_id, template_id))
  end

  #
  #=== エラーがあればfalseを返す
  #
  def valid?
    result = self.errors.any? ? false : super
    ImportCSV.remove_csv_file(self.user.id, self.template.id) unless result
    result
  end

  private

  #
  #=== アップロードしたファイルへのパスを返す
  #
  #  設定パス/ユーザID/テンプレートID.csv
  #
  def self.csv_file_path(user_id, template_id)
    File.join(Settings.files.csv_dir_path, user_id.to_s, "#{template_id.to_s}.csv")
  end

  #
  #=== CSVに入力されているヘッダーの情報がテンプレートの項目と
  #    一致していることを確認するバリデーション
  #
  def header_valid
    elements = self.elements.map(&:name).unshift(ID_COL_NAME)
    errors.add(:header, I18n.t('errors.messages.different_header')) unless self.header.sort == elements.sort
  end

  #
  #=== CSVに入力されている行ごとのデータ数が正しいことの確認バリデーション
  #
  def rows_valid
    element_count = self.elements.count + 1
    line_numbers = []
    rows.each.with_index(2){|row, idx| line_numbers << idx unless element_count == row.count }
    errors.add(:csv, I18n.t('errors.messages.different_row', line_number: line_numbers.join(','))) if line_numbers.present?
  end

  #
  #=== CSVのファイルパスからCSVを読み込む
  #
  # 直接CSVの文字列が指定されていた場合、CSVのパスにファイルを書き込む
  #
  def csv_file_read
    path = ImportCSV.csv_file_path(self.user.id, self.template.id)
    if self.csv.nil?
      File.exists?(path) ? File.read(path) : nil
    else
      FileUtils.mkdir_p(File.dirname(path))
      csv = self.csv.kconv(Kconv::UTF8, Kconv::SJIS)
      File.open(path, 'w'){|f| f.print csv} unless File.exists?(path)
      return csv
    end
  end

  #
  #=== CSVをパースする
  #
  # ヘッダーと行を別のアクセッサにセットする
  # IDが記述されている行のレコードを取得し、アクセサにセットする
  #
  def parse_csv
    rows, ids  = [], []
    begin
      CSV.parse(self.csv).each_with_index do |row, idx|
        if idx != 0
          ids << row.first
          rows << row
        else
          self.header = row
        end
      end
    rescue
      errors.add(:csv, I18n.t('errors.messages.csv_illegality'))
    end
    self.records = template.all_records.where(id: ids.uniq).includes(:template, {values: :content}).to_a
    self.rows = rows
  end
end
