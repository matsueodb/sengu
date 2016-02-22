# == Schema Information
#
# Table name: template_record_select_conditions
#
#  id           :integer          not null, primary key
#  template_id  :integer
#  target_class :string(255)
#  condition    :text
#

class TemplateRecordSelectCondition < ActiveRecord::Base
  validates :target_class, inclusion: {within: InputType::TYPE_CLASS_NAME.values.map(&:name)}
  validates :template_id, presence: true
  validates :condition, presence: true
  belongs_to :template

  # 文字列の条件句
  STRING_CONDITION = {
    forward_match: %q({key}%),
    exact_match: %q({key}),
    backward_match: %q(%{key}),
    middle_match: %q(%{key}%),
  }

  #
  #=== パラメータをもとにSQLを組み立てる
  # {element_id} => {{kind} => {...}}
  def self.make_sqls(params = {})
    params.map do |element_id, values|
      next if values.all?{|kind, vals|vals["value"].blank?}
      sql = ""
      element = Element.includes(:input_type).find(element_id)
      it = element.input_type
      case 
      when it.line?, it.multi_line?
        val = values.values.first
        cond_v = STRING_CONDITION[val["string_condition"].to_sym].sub("{key}", val["value"])
        sql += "#{element.input_type.content_class_name.constantize.table_name}.value LIKE '#{cond_v}'"
      when it.dates?
        if values.count{|kind, vals|vals["value"].present?} == 2 # BETWEEN
          s, f = values.map{|kind, vals|vals["value"]}
          s_date = Date.parse(s) rescue false
          f_date = Date.parse(f) rescue false
          if s_date && f_date
            sql += "#{element.input_type.content_class_name.constantize.table_name}.value BETWEEN '#{s}' AND '#{f}'"
          end
        else
          kind, v = values.detect{|kind, vals|vals["value"].present?}
          s = v["value"]
          date_s = Date.parse(s) rescue false
          if date_s
            if kind == "0" # 先
              sql += "#{element.input_type.content_class_name.constantize.table_name}.value >= '#{date_s}'"
            else # 後
              sql += "#{element.input_type.content_class_name.constantize.table_name}.value <= '#{date_s}'"
            end
          end
        end
      when it.times? #時間
        bt = ElementValue::Times::BASE_DATE
        if values["0"] && values["0"].has_key?("value") && values["0"]["value"].all?{|k,v|v.present?}
          s_time = DateTime.new(bt.year, bt.month, bt.day, values["0"]["value"]["hour"].to_i, values["0"]["value"]["min"].to_i)
        end
        if values["1"] && values["1"].has_key?("value") && values["1"]["value"].all?{|k,v|v.present?}
          f_time = DateTime.new(bt.year, bt.month, bt.day, values["1"]["value"]["hour"].to_i, values["1"]["value"]["min"].to_i)
        end
        if s_time && f_time # BETWEEN
          sql += "#{element.input_type.content_class_name.constantize.table_name}.value BETWEEN '#{s_time}' AND '#{f_time}'"
        elsif s_time
          sql += "#{element.input_type.content_class_name.constantize.table_name}.value >= '#{s_time}'"
        elsif f_time
          sql += "#{element.input_type.content_class_name.constantize.table_name}.value <= '#{f_time}'"
        else
          next
        end
      when it.checkbox?, it.pulldown?
        # or
        vals = values.map{|kind, vals|vals["value"]}.uniq.join(",")
        sql += "#{element.input_type.content_class_name.constantize.table_name}.value IN (#{vals})"
      else
        next
      end
      sql = "(element_values.element_id = '#{element_id}' AND " + sql + ")", element.input_type.content_class_name
    end.compact
  end

  #
  #=== パラメータをもとにSQLを組み立てて、保存する
  # {element_id} => {{kind} => {value}}
  def self.create_sql(template, params = {})
    self.make_sqls(params).each do |sql, target_class|
      self.create(template_id: template.id, condition: sql, target_class: target_class)
    end
  end

  #
  #=== 引数で渡したテンプレートの親テンプレートからparamsの条件に一致するTemplateRecordを取得する
  def self.get_records(template, params = {})
    re_ids = []
    # 拡張時の条件に一致するレコードを取得
    sqls = self.make_sqls(params)
    records = template.parent.template_records
    
    if sqls.present?
      re_id_array = sqls.map do |sql, target_class|
        target_class.constantize.joins(:element_value)
                                .where(sql)
                                .where("element_values.template_id = ?", template.parent_id)
                                .pluck(:record_id)
                                .uniq
      end

      re_ids = re_id_array.first
      re_id_array.each{|ids|re_ids = (re_ids & ids)} # 全ての条件に該当するIDを取得
      re_ids = [] if re_ids.blank?

      records.where("id IN (?)", re_ids)
    else
      records
    end
  end
end
