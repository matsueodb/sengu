require 'kconv'
require 'csv'
# == Schema Information
#
# Table name: templates
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  user_id        :integer
#  user_group_id  :integer
#  service_id     :integer
#  parent_id      :integer
#  status         :integer          default(1)
#  display_number :integer
#  updated_at     :datetime
#

#
#== テンプレート
#
class Template < ActiveRecord::Base
  @@statuses = {
    publish: 1, # 公開
    close: 0   # 非公開
  }

  cattr_reader :statuses

  has_many :template_records, dependent: :destroy, autosave: true
  has_many :elements, -> { order(:display_number) }, dependent: :destroy
  has_many :element_values, dependent: :destroy
  has_many :template_record_select_conditions, dependent: :destroy
  belongs_to :user
  belongs_to :user_group
  belongs_to :service
  belongs_to :parent, foreign_key: :parent_id, class_name: "Template"
  has_many :extensions, foreign_key: :parent_id, class_name: "Template", dependent: :destroy

  has_many :referenced_elements, as: :source, class_name: "Element"

  # 拡張テンプレート
  scope :extensions, -> {where("parent_id IS NOT NULL")}
  # マスタテンプレート
  scope :masters, -> {where("parent_id IS NULL")}
  # サービスに登録されているもの
  scope :in_service, -> {where("service_id IS NOT NULL")}
  # 非公開（サービスに登録されていないもの)
  scope :privates, -> {masters.where("service_id IS NULL")}
  # 閲覧出来るもの
  # ユーザの所属のサービスに登録されているテンプレートもしくは、参加しているグループが割り当てられているテンプレート
  scope :displayables, -> (user) {
    ids = UserGroup.joins(:user_groups_members).where("user_id = ?", user.id).pluck(:id)
    joins(:service).where("services.section_id = ? OR templates.user_group_id IN (?)", user.section_id, ids)
  }

  accepts_nested_attributes_for :elements, update_only: true

  validates :name,
    presence: true,
    length: {maximum: 255}
  validates :service_id,
    presence: true

  validate :validate_change_service, :validate_change_user_group_id

  before_validation :set_display_number

  #
  #=== userがテンプレートの作成者かどうかを返す。
  #==== 戻り値
  # * true: 作成者, false: 作成者以外
  def creator?(user)
    self.user_id == user.id
  end

  #
  #=== Serviceがあるか
  #==== 戻り値
  # * true: Service有り, false: Serviceなし
  def has_service?
    !!service_id
  end

  #
  #=== 拡張基があるか
  #==== 戻り値
  # * true: 拡張基有り, false: 拡張基なし
  def has_parent?
    !!parent_id
  end

  #
  #=== ユーザグループがあるか
  #==== 戻り値
  # * true: ユーザグループ有り, false: ユーザグループなし
  def has_user_group?
    !!user_group_id
  end

  #
  #=== selfを基に拡張しているテンプレートが存在するか？
  #==== 戻り値
  # * true: あり, false: なし
  def has_extension?
    extensions.exists?
  end

  #
  #=== 関連する全てのレコードを返す。
  # 拡張テンプレートの場合は、拡張基のテンプレートのレコードを含めて返す。
  #==== 戻り値
  # * Array(TemplateRecordインスタンス...)
  def all_records
    if self.extension?
      trscs = self.template_record_select_conditions
      if trscs.exists?
        re_ids = []
        # 拡張時の条件に一致するレコードを取得
        re_id_array = trscs.map do |trsc|
          trsc.target_class.constantize.joins(:element_value)
                                       .where(trsc.condition)
                                       .where("element_values.template_id = ?", self.parent_id)
                                       .pluck(:record_id)
                                       .uniq
        end

        re_ids = re_id_array.first
        re_id_array.each{|ids|re_ids = (re_ids & ids)} # 全ての条件に該当するIDを取得
        if re_ids.blank? || re_ids.empty?
          self.template_records
        else
          TemplateRecord.where("id IN (?) OR template_id = ?", re_ids, self.id)
        end
      else
        # 拡張基に対しての取得条件を未設定=全データ参照
        TemplateRecord.where("template_id IN (?)", [self.id, self.parent_id])
      end
    else
      self.template_records
    end
  end

  #
  #=== 関連する全てのレコードを返す。
  # 拡張テンプレートの場合は、拡張基のエレメントを含めて返す。
  #==== 戻り値
  # * Array(Elementインスタンス...)
  def all_elements
    if self.extension?
      # 拡張テンプレートのidが小さい前提
      Element.where("elements.template_id IN (?)", [self.id, self.parent_id]).order("template_id, display_number")
    else
      self.elements.order("elements.display_number")
    end
  end

  #
  #=== 入力対象のエレメントを取得する
  #
  def inputable_elements(options={}, &block)
    options = {available: true, publish: false}.merge(options)
    els = self.all_elements.root.includes(:children)
    els = els.availables if options[:available]
    els = els.publishes if options[:publish]
    els = yield(els) if block_given?
    els = els.map{|e| e.last_children(options, &block) }.flatten
  end

  #
  #=== テンプレートの編集、削除ができるユーザか？
  # ユーザの所属の管理するサービスでかつ、管理者か所属管理者
  #==== 戻り値
  # * true or false
  def operator?(user)
    self.service.section_id == user.section_id && user.manager?
  end

  #
  #=== 引数で渡したユーザがテンプレートを削除できるか？
  # 操作者 && 関連づけされていない場合 && 非拡張基
  #==== 戻り値
  # * true: 削除可, false: 削除不可
  def destroyable?(uesr)
    operator?(uesr) && !related_reference? && !has_extension?
  end

  #
  #=== selfが他のテンプレートから参照されているか？
  #==== 戻り値
  # * true: 参照されている, false: 参照されていない
  def related_reference?
    self.referenced_elements.exists?
  end

  #
  #=== selfのelementsが他のテンプレートを参照しているか？
  #==== 戻り値
  # * true: 参照している, false: 参照していない
  def referring_to_other_template?
    self.elements.includes(:input_type).any?{|e|e.input_type.template?}
  end

  #
  #=== selfが他のテンプレートから参照、または他のテンプレートを参照しているか？
  #==== 戻り値
  # * true: 参照, false: 非参照
  def related?
    self.referenced_elements.exists? || referring_to_other_template?
  end

  #
  #=== 状態の文字を返す。
  #==== 戻り値
  # * String
  def self.status_label(key)
    I18n.t("activerecord.attributes.template.status_label.#{@@statuses.invert[key]}")
  end

  #
  #=== 拡張されたテンプレートかどうかを返す
  #==== 戻り値
  # * true: 拡張されたテンプレート, false: 拡張されていないテンプレート
  def extension?
    !!self.parent_id
  end

  #
  #=== selfをもとに、拡張テンプレートを作成することができるか
  # 拡張テンプレートでない場合True
  #==== 戻り値
  # * true: 拡張可能, false: 不可
  def add_extension?
    !extension?
  end

  #
  #=== selfと同じサービスに属するテンプレートを返す
  #==== 戻り値
  # * [同じサービスに属するTemplateインスタンス..., ..]
  def same_service_templates(include_self=true)
    templates = Template.where(service_id: self.service_id)
    templates.where!.not(id: self.id) unless include_self
    templates
  end

  #
  #=== サービスを選択出来るか？
  # 新規 or !拡張基 && 関連づけ参照されていない
  #==== 戻り値
  # boolean - true: 変更可能, false: 変更不可
  def editable_of_service?
    new_record? || (!has_extension? && !related?)
  end

  #
  #=== ユーザグループを変更できるか？
  # ElementValueにデータがある場合、変更できない
  #==== 戻り値
  # boolean - true: 変更可能, false: 変更不可
  def editable_of_user_group?
    !ElementValue.where(template_id: self.id).exists?
  end

  #
  #=== キーワードに該当するデータが存在するか？
  #
  def included_by_keyword?(keyword)
    self.template_records.any?{|r|r.included_by_keyword?(keyword)}
  end

  #
  #=== キーワードに該当するレコードを返す。
  def included_by_keyword_records(keyword)
    self.template_records.select{|r|r.included_by_keyword?(keyword)}
  end

  #
  #=== テンプレートの項目からCSVフォーマットを作成する
  #
  def convert_csv_format
    elements = self.inputable_elements{|e| e.includes(:input_type, :regular_expression)}
    csv_str = CSV.generate('', encoding: 'SJIS'){|csv| csv << elements.map(&:name).unshift(ImportCSV::ID_COL_NAME)}
    csv_str.kconv(Kconv::SJIS,Kconv::UTF8)
  end

  #
  #=== 登録データをCSV出力する
  #
  def convert_records_csv
    els = self.inputable_elements{|e| e.includes(:input_type, :regular_expression)}
    csv_str = CSV.generate(row_sep: "\r\n") do |csv|
      csv << els.map(&:name).unshift(ImportCSV::ID_COL_NAME)
      self.all_records.includes(values: [:content]).each do |t_r|
        t_r.values.to_a.group_by{|v| v.item_number}.each do |item_number, t_r_values|
          csv << els.each_with_object([t_r.id]) do |el, contents|
            values = t_r_values.select{|v| v.element_id == el.id && v.content.value.present?}.sort_by{|v| v.kind }
            if values.size > 1
              contents << values.map(&:formatted_value).join(',')
            else
              value = values.first
              contents << (value.nil? ? '' : value.formatted_value)
            end
          end
        end
      end
    end
    csv_str.kconv(Kconv::SJIS,Kconv::UTF8)
  end

  #
  #=== Elementから実際に参照されるデータを返す。
  # Elementとsourceでリレーションしているクラスでは必ず必要なメソッド
  #==== 戻り値
  # * TemplateRecordリレーション
  def records_referenced_from_element
    self.all_records
  end

  def find_or_build_template_record_by(condition)
    t_r = TemplateRecord.find_by(condition)
    t_r.present? ? t_r : self.template_records.build(condition)
  end

  #
  #=== 非公開？
  # 非公開のテンプレートの場合、trueが返ること
  #==== 戻り値
  # * boolean
  def close?
    self.status == @@statuses[:close]
  end

  #
  #=== データを扱える人
  def data_register?(user)
    (self.service.section_id == user.section_id) || self.user_group.try(:member?, user)
  end

  #
  #=== 引数で渡されたidの格納順にdisplay_numberを更新する
  #
  #=== 戻り値
  #
  # * 成功 => true
  # * 失敗 => false
  def self.change_order(service, ids)
    self.transaction do
      ids.each_with_index do |id, idx|
        Template.where(id: id, service_id: service.id).update_all(display_number: idx)
      end
      return true
    end
    rescue
      return false
  end

  #=== 項目の並び順（一覧表示したときの、上からの並び順）を計算する
  def calculate_flat_display_numbers
    current_number = 0  # 実際の並び順の最小値は1
    flat_display_numbers = { } # idをキー、並び順を値
    self.elements.root.each do |root|
      flat_display_numbers[root.id] = current_number += 1
      current_number = root.calculate_flat_display_numbers(current_number, flat_display_numbers)
    end
    flat_display_numbers
  end

  #
  #=== RDFで使用するURLを返す
  #
  def about_url_for_rdf
    Rails.application.routes.url_helpers.template_records_path(self)
  end

  private

    #
    #=== 保存時にdisplay_numberを更新する
    #
    def set_display_number
      if self.display_number.nil?
        max_num = Template.where(service_id: self.service_id).maximum(:display_number)
        self.display_number = max_num.nil? ? 0 : max_num + 1
      end
    end

    #=== Serviceが変更出来るか検証
    def validate_change_service
      # 既存でかつ、service_idを変更した場合
      if self.service_id_changed? && !self.editable_of_service?
        errors.add(:service_id, I18n.t("errors.messages.template.service_id.it_cannot_be_changed_because_it_is_related"))
      end
    end

    #=== UserGroupIDが変更出来るか検証
    def validate_change_user_group_id
      if self.user_group_id_changed? && !self.editable_of_user_group?
        errors.add(:user_group_id, I18n.t("errors.messages.template.user_group_id.it_cannot_be_changed_because_it_has_the_data"))
      end
    end
end
