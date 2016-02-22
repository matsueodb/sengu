#
#=== 語彙データベースから取得した項目に対してSengu側の制限を対応付ける
#
module Sengu::VDB
  class Mapping
    FOR_DATA_TYPE = YAML.load(ERB.new(IO.read(Vdb::Engine.root.join('config', 'mapping', 'data_type', "#{Rails.env}.yml"))).result)
    FOR_ENTRY_NAME = YAML.load(ERB.new(IO.read(Vdb::Engine.root.join('config', 'mapping', 'entry_name', "#{Rails.env}.yml"))).result)
    INPUT_TYPES = YAML.load(IO.read(Rails.root.join('db', 'fixtures', "003_input_types.yml")))
    REGULAR_EXPRESSIONS = YAML.load(IO.read(Rails.root.join('db', 'fixtures', "002_regular_expression.yml")))
    CODE_LISTS = YAML.load(IO.read(Vdb::Engine.root.join('db', 'fixtures', 'vocabulary', "006_elements.yml")))

    #
    #=== マッピング情報を取得して、Elementインスタンスに設定する
    #
    def self.mapping(element)
      attributes = element.attributes.merge(self.find_by_data_type(element.data_type))
      self.find_by_entry_name(element.entry_name)
      attributes.merge!(self.find_by_entry_name(element.entry_name))
      element.attributes = attributes
      element
    end

  private

    #
    #=== エントリーネームをキーにしてマッピング情報を取得する
    #
    def self.find_by_entry_name(entry_name)
      attr = FOR_ENTRY_NAME[entry_name] || {}
      self.set_value_by_label(attr)
      return attr
    end

    #
    #=== データタイプをキーにしてマッピング情報を取得する
    #
    def self.find_by_data_type(data_type)
      attr = FOR_DATA_TYPE[data_type] || {}
      self.set_value_by_label(attr)
      return attr
    end

    #
    #=== マッピングYMLから取得した値に実際の値を埋め込む
    #
    def self.set_value_by_label(attr)
      self.set_input_type_id(attr)
      self.set_regular_expression_id(attr)
      self.set_code_list(attr)
    end

    #
    #=== マッピングYMLのinput_type項目を実際の値に置き換える
    #
    def self.set_input_type_id(attr)
      if it_label = attr.delete("input_type")
        attr.merge!(input_type_id: INPUT_TYPES[it_label]["id"])
      end
    end

    #
    #=== マッピングYMLのregular_expression項目を実際の値に置き換える
    #
    def self.set_regular_expression_id(attr)
      if it_label = attr.delete("regular_expression")
        attr.merge!(regular_expression_id: REGULAR_EXPRESSIONS[it_label]["id"])
      end
    end

    #
    #=== マッピングYMLのcode_list項目を実際の値に置き換える
    #
    def self.set_code_list(attr)
      if it_label = attr.delete("code_list")
        if id = CODE_LISTS[it_label]["id"]
          attr.merge!(source_id: id, source_type: "Vocabulary::Element") if Vocabulary::Element.where(id: id).exists?
        end
      end
    end
  end
end
