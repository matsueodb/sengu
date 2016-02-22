# == Schema Information
#
# Table name: template_records
#
#  id          :integer          not null, primary key
#  template_id :integer
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class TemplateRecord < ActiveRecord::Base
  belongs_to :template
  belongs_to :user
  has_many :values, foreign_key: :record_id, class_name: "ElementValue", dependent: :destroy, autosave: true

  accepts_nested_attributes_for :values, reject_if: :reject_multiple_records, allow_destroy: true

  validate :validation_based_on_element

  attr_accessor :line_numbers

  #
  #=== 子要素のビルドを引数で渡されたテンプレートをもとに行う
  #
  def build_element_values(template = nil)
    temp = template || self.template
    build_element_values_by_elements(temp.inputable_elements{|e|e.includes(:input_type, :source)}, temp.id)
  end

  #
  #=== 子要素のビルドを項目を基におこなう
  #
  def build_element_values_by_elements(elements, template_id)
    elements.each do |el|
      it = el.input_type
      build_attr = {
        element_id: el.id,
        # valuesのcontent_typeにはbuild_content実行後にel.input_type.content_class_nameの親クラスがセットされる
        content_type: el.input_type.content_class_name,
        template_id: template_id
      }
      el_vals = self.values.select{|v|v.element_id == el.id}
      case
      when it.location? # 位置情報
        ElementValue::KINDS[el.input_type.name].each do |key, value|
          if !el_vals.any?{|v|v.kind == value}
            self.values.build(build_attr.merge(kind: value)).build_content
          end
        end
      when it.checkbox_template?, it.checkbox_vocabulary? # チェックボックス（テンプレート）
        el.source.records_referenced_from_element.each do |ins|
          if !el_vals.any?{|v|v.kind == ins.id}
            self.values.build(build_attr.merge(kind: ins.id)).build_content
          end
        end
      else
        if el_vals.empty?
          self.values.build(build_attr).build_content
        end
      end
    end
  end

  #
  #=== element_idとkindでソートしたvaluesを返す。
  # 同じインスタンスに対して２回目以降に本メソッドを呼んだ場合は@sortable_valuesの値を返す
  #==== 戻り値
  # * ElementValueインスタンス配列
  def sortable_values
    if @sortable_values.nil?
      @sortable_values = self.values.sort{|a,b|[a.element_id, a.kind] <=> [b.element_id, b.kind]}
    end
    return @sortable_values
  end

  #
  #=== ユーザが削除できるか？
  # ユーザの所属のサービスのテンプレートでかつ、管理者か所属管理者
  # もしくは、自分が作成したデータ
  #==== 引数
  # * user - 削除をしようとしているユーザ
  #==== 戻り値
  # true: 可, false: 不可
  def destroyable?(user)
    editable?(user)
  end

  #
  #=== 編集できるか？
  # ユーザの所属のサービスのテンプレートでかつ、管理者か所属管理者
  # もしくは、自分が作成したデータ
  #==== 引数
  # * user - 編集をしようとしているユーザ
  #==== 戻り値
  # true: 可, false: 不可
  def editable?(user)
    se = self.template.service
    return self.user_id == user.id || (se.section_id == user.section_id && (user.manager?))
  end

  #
  #=== userがデータの作成者かどうかを返す。
  #==== 戻り値
  # * true: 作成者, false: 作成者以外
  def creator?(user)
    self.user_id == user.id
  end

  #
  #=== 参照されているか？
  # 他のテンプレートからselfのレコードが参照されているか？
  #==== 戻り値
  # * true: 参照されている, false: 参照されていない
  def is_referenced?
    types = InputType::REFERENCED_TEMPLATE_NAMES.map{|name|InputType::TYPE_CLASS_NAME[name].name}
    ElementValue::IdentifierContent
      .where("element_value_identifier_contents.type IN (?)", types)
      .where("element_value_identifier_contents.value = ?", self.id)
      .exists?
  end

  #
  #=== elementに対応するvalueを整形して返す
  #==== 引数
  # * element - Elementインスタンス
  # * temp - Templateインスタンス
  #==== 戻り値
  # * string
  def formatted_value(element, temp = nil)
    formatted_values(element, temp).join(",")
  end

  #
  #=== elementに対応するvalueを整形して配列で返す
  #==== 引数
  # * element - Elementインスタンス
  # * temp - Templateインスタンス
  #==== 戻り値
  # * Array(string, string..
  def formatted_values(element, temp = nil)
    record_values_by_element(element, temp).map(&:formatted_value).compact
  end

  #
  #=== TemplateRecordに対応するvaluesを返す
  # 拡張基にデータがある場合は、拡張基のElementValueを返す
  #==== 引数
  # * temp - Templateインスタンス
  #==== 戻り値
  # * Array(element_value, element_value...
  def record_values(temp = nil)
    tp = temp.blank? ? self.template : temp
    tp.all_elements.map{|e|record_values_by_element(e, tp)}.flatten.compact
  end

  #
  #=== elementに対応するvaluesを返す
  # 拡張基にデータがある場合は、拡張基のElementValueを返す
  #==== 引数
  # * element - Elementインスタンス
  # * temp - Templateインスタンス
  #==== 戻り値
  # * Array(element_value, element_value...
  def record_values_by_element(element, temp = nil)
    tp = temp.blank? ? self.template : temp
    # NOTE:
    # 以下はSQLで絞り込まない。SQLで絞り込むとDBに保存されていないがセットされている値が取得出来ないため
    vals, pa_vals = self.values.select{|v|v.element_id == element.id}.sort_by(&:item_number).partition{|v|v.template_id == tp.id}


    # 拡張基のデータ
    pa_vals = pa_vals.select{|v|v.template_id == tp.parent_id}
    if tp.has_parent? && !pa_vals.empty?
      # NOTE: 拡張基にデータがある場合はそのデータが返る。
      # 原則として拡張基にデータがある場合に、拡張側ではその項目の入力ができない
      pa_vals
    else
      vals
    end
  end

  #
  #=== 引数で渡したテンプレートで使用するvaluesを返す。
  #
  #==== 引数
  # * temp - Templateインスタンス
  #
  def all_values(temp = nil)
    tp = temp || self.template
    ids = [tp.id]
    ids << tp.parent_id if tp.has_parent?
    # 以下はSQLで絞り込まない。SQLで絞り込むとDBに保存されていないがセットされている値が取得出来ないため
    self.values.select{|v|v.template_id.in?(ids)}
  end

  #
  #=== 引数で渡したキーワードを含むvaluesが存在するか？
  #==== 引数
  # * keyword - キーワード
  #==== 戻り値
  # boolean: true or false
  def included_by_keyword?(keyword)
    self.values.any?{|r|r.included_by_keyword?(keyword)}
  end

  #
  #=== 重複の検証
  #
  def validation_of_uniqueness_on_import_csv(element, vals)
    tp_ids = self.template.has_parent? ? [self.template_id, self.template.parent.id] : [self.template_id]
    if element.unique? # uniqueness
      # self.templateに登録されたデータかまたは拡張基に登録されたデータから
      e_vs = element.load_values_by_template_ids(tp_ids, vals)
      e_vs = e_vs - vals

      vs = vals.map{|v| v.try(:value) }.reject(&:blank?).sort

      unless vs.empty?
        if e_vs.group_by(&:record_id).any?{|r_id, evs|vs == evs.map{|v|v.try(:value)}.reject(&:blank?).sort}
          errors.add(:base, element.full_name + I18n.t("errors.messages.taken"))
        end
      end
    end
  end

  #
  #=== 未入力の検証
  #
  def validation_of_presence(element, vals)
    if element.required?
      if element.input_type.all_locations?
        # 位置情報全種類の場合、すべての緯度、経度が必須
        size = ElementValue::KINDS[:all_locations].sum{|k,v|v.values.size}
        unless vals.group_by(&:item_number).all?{|num, vs|
            vs.map{|v|v.try(:value)}.reject(&:blank?).size == size
          }
          errors.add(:base, element.full_name + I18n.t("errors.messages.all_locations.blank"))
        end
      else
        if vals.map{|v|v.try(:value)}.reject(&:blank?).empty?
          errors.add(:base, element.full_name + I18n.t("errors.messages.blank"))
        end
      end
    end
  end

  #
  #=== 文字数の検証
  #
  def validation_of_length(element, vals)
    if element.max_digit_number.present? || element.min_digit_number.present?
      # 最大&最小が指定
      if element.max_digit_number == element.min_digit_number
        if vals.map{|v|v.try(:value)}.compact.any?{|v|v.length != element.max_digit_number}
          # 最大と最小が等しい
          errors.add(:base, element.full_name + I18n.t("errors.messages.wrong_length", count: element.max_digit_number))
        end
      else
        if element.max_digit_number.present?
          if vals.map{|v|v.try(:value)}.compact.any?{|v|v.length > element.max_digit_number} # 最大以上
            errors.add(:base, element.full_name + I18n.t("errors.messages.too_long", count: element.max_digit_number))
          end
        end

        if element.min_digit_number.present?
          if vals.map{|v|v.try(:value)}.compact.any?{|v|v.length < element.min_digit_number} # 最小以下
            errors.add(:base, element.full_name + I18n.t("errors.messages.too_short", count: element.min_digit_number))
          end
        end
      end
    end
  end

  #
  #=== 正規表現を基にバリデーション
  #
  def validation_by_regular_expression(element, vals)
    return if element.regular_expression.blank?
    if vals.map{|v|v.try(:value)}.reject(&:blank?).any?{|v|v.to_s !~ element.regular_expression.to_regexp}
      errors.add(:base, element.full_name + I18n.t("errors.messages.invalid"))
    end
  end

  #
  #=== 位置情報項目のバリデーション
  #
  def validation_of_location(element, vals)
    it = element.input_type
    return unless it.location?

    if it.all_locations?
      ElementValue::KINDS[:all_locations].each do |name, kinds|
        if vals.select{|v|v.kind.in?(kinds.values)}.map{|v|v.try(:value)}.reject(&:blank?).size == 1
          errors.add(:base, element.full_name + I18n.t("errors.messages.location.please_enter_both_latitude_and_longitude"))
        end
      end
    else
      if vals.map{|v|v.try(:value)}.reject(&:blank?).size == 1 # 1件ということは緯度か経度片方だけ入力されているのでエラー
        errors.add(:base, element.full_name + I18n.t("errors.messages.location.please_enter_both_latitude_and_longitude"))
      end
    end
  end

  #
  #=== 参照先のデータが正しいかどうかのバリデーション
  #
  def validation_by_reference_values(element, vals)
    return unless element.input_type.referenced_type?

    vals.each do |val|
      value = val.content.try(:value)
      if value.present?
        unless element.registerable_reference_ids.include?(val.content.value.to_i)
          errors.add(:base, element.full_name + I18n.t("errors.messages.invalid"))
        end
      end
    end
  end

  #
  #=== 1行入力項目のバリデーション
  #
  def validation_of_line(element, vals)
    return unless element.input_type.line?
    if vals.map{|v|v.try(:value)}.reject(&:blank?).any?{|v|v.to_s.length >= 256} # 256文字以上はエラー
      errors.add(:base, element.full_name + I18n.t("errors.messages.line.please_enter_up_to_255_characters"))
    end
  end

  #
  #=== ファイルアップロード時のバリデーション
  #
  def validation_of_upload_file(element, vals)
    return unless element.input_type.upload_file?

    max_size = Settings.files.upload_file.max_file_size
    if vals.map{|v|v.try(:content).try(:temp)}.reject(&:blank?).any?{|uf|uf.size > max_size}
      errors.add(:base, element.full_name + I18n.t("errors.messages.upload_file.less_than_or_equal_to", count: (max_size / 1.megabyte)))
    end

    vals.group_by(&:item_number).each do |num, vs|
      label_v = vs.detect{|v|v.kind == ElementValue::KINDS[:upload_file][:label]}
      file_v = vs.detect{|v|v.kind == ElementValue::KINDS[:upload_file][:file]}
      if label_v.try(:value).present?
        # ラベルが長過ぎる場合エラー
        if label_v.try(:value).to_s.length >= 256
          errors.add(:base, element.full_name + I18n.t("errors.messages.upload_file.label.please_enter_up_to_255_characters"))
        end

        # ラベルだけ入力されている場合、エラー
        if (file_v.try(:value).blank? || file_v._destroy)
          errors.add(:base, element.full_name + I18n.t("errors.messages.upload_file.please_select_a_file"))
        end
      end
    end
  end

  #
  #=== パラメータから保存する。
  def save_from_params!(parameters = {}, temp = self.template)
    v_attrs = {}
    #[:element_id][:item_number][:kind][:id, :value]
    index = 0
    parameters.each do |element_id, item_numbers|
      element = Element.find(element_id)
      it = element.input_type
      content_class = it.content_class_name.constantize

      ids = item_numbers.map{|num, kinds|kinds.map{|k, at|at["id"]}}.flatten.compact

      # idが送られていないものは削除（既存のデータが削除ボタン(-)で項目が消された場合にidがこないので）
      self.values.where(template_id: self.template_id, element_id: element_id).where.not(id: ids).destroy_all

      item_numbers.sort_by{|k,v|k.to_i}.each.with_index(1) do |(item_number, kinds), new_item_number|
        kinds.each do |kind, attr|
          content_id = attr["content_id"]
          content_attr = {"type" => content_class.name}
          content_attr.merge!("id" => content_id) if content_id

          if attr.has_key?("upload_file") # ファイルアップロード時
            if attr["upload_file"]
              content_attr.merge!("upload_file" => attr["upload_file"], "value" => attr["upload_file"].try(:original_filename))
            end
          else
            if attr.has_key?("value(4i)") && attr.has_key?("value(5i)")
              if attr["value(4i)"].blank? || attr["value(5i)"].blank?
                content_attr.merge!("value" => "")
              else
                to = ElementValue::Times::BASE_DATE
                d = DateTime.new(to.year, to.month, to.day, attr["value(4i)"].to_i, attr["value(5i)"].to_i, 0)
                content_attr.merge!("value" => d)
              end
            elsif attr["value"]
              content_attr.merge!("value" => attr["value"])
            end
          end

          id = attr["id"]

          # .editable_on?メソッドを使用して、拡張基のデータが更新されることを防ぐ
          if id.blank? || (ElementValue.exists?(id) && ElementValue.find(id).editable_on?(temp))
            v_attrs[index.to_s] = {
              id: id,
              template_id: attr["template_id"],
              kind: kind.to_i,
              element_id: element_id.to_i,
              item_number: new_item_number.to_i, # パラメータのitem_numberではなく、あくまでも１から連番になるようにセット
              content_type: content_class.superclass.name,
              content_attributes: content_attr,
              content_id: content_id
            }.stringify_keys
            # 削除チェックが入っていて、upload_fileがないとき
            v_attrs[index.to_s].merge!("_destroy" => "1") if attr["upload_file"].blank? && attr["_destroy"]
            index += 1
          end
        end
      end
    end

    # fields_forで作成するようなパラメータを整形して.attributesにセット
    self.attributes = {"values_attributes" => v_attrs}
    self.save!
  end

  #
  #=== 繰り返し入力となっている各namespaceがもつ繰り返し回数を算出する
  # 対応していないものは、繰り返し回数として1を返す
  #
  def item_numbers_by_namespace
    repeat_element_ids = self.record_values.map(&:repeat_element_id).compact.uniq
    repeat_element_ids.each_with_object(Hash.new(1)) do |namespace_id, hash|
      count = ElementValue.where(repeat_element_id: namespace_id, record_id: self.id).maximum(:item_number)
      hash[namespace_id] = count
    end
  end

  private

    #
    #=== 複数データが入る場合の不要なレコードの削除
    #
    def reject_multiple_records(attributes)
      if attributes['skip_reject'].blank?
        exists = attributes['id'].present?
        empty = attributes[:content_attributes].try(:fetch, :value, {}).blank?
        attributes.merge!({:_destroy => 1}) if exists && empty

        return (!exists && empty)
      else
        return false
      end
    end

    #
    #=== Elementを基にバリデーションをかける
    #
    def validation_based_on_element
      self.template.inputable_elements.each do |element|
        vals = self.values.select{|v|v.element_id == element.id}
        validation_of_presence(element, vals)
        validation_of_uniqueness(element, vals)
        validation_of_length(element, vals)
        validation_by_regular_expression(element, vals)
        validation_of_location(element, vals)
        validation_of_line(element, vals)
        validation_by_reference_values(element, vals)
        validation_of_upload_file(element, vals)
      end
    end

    #
    #=== 重複の検証
    #
    def validation_of_uniqueness(element, vals)
      tp_ids = self.template.has_parent? ? [self.template_id, self.template.parent.id] : [self.template_id]
      if element.unique? # uniqueness
        # self.templateに登録されたデータかまたは拡張基に登録されたデータから
        element_values = ElementValue.where("template_id IN (?) AND element_id = ?", tp_ids, element.id).includes(:content)
        element_values.where!("record_id <> ?", self.id) if self.persisted?

        vs = vals.map{|v|v.try(:value)}.reject(&:blank?).sort
        unless vs.empty?
          if element_values.group_by(&:record_id).any?{|r_id, evs|vs == evs.map{|v|v.try(:value)}.reject(&:blank?).sort}
            errors.add(:base, element.full_name + I18n.t("errors.messages.taken"))
          end
        end
      end
    end
end
