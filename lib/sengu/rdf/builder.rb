#
#== RDF生成クラス
#
require "nokogiri"
class Sengu::Rdf::Builder
 include Rails.application.routes.url_helpers
  PROGRAM_NAME = 'Ruby 2.0.0'
  CREATIVECOMMONS_URL = "http://creativecommons.org/licenses/by/2.1/jp/"

  # xmlns:**
  XMLNS = {
    "xmlns:rdf"   => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "xml:base"    => "http://opendata-2014.netlab.jp/",
    "xmlns:mlod"  => "http://opendata-2014.netlab.jp/mlod/1.0",
    "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
    "xmlns:dcterms" => "http://purl.org/dc/terms/",
    "xmlns:geo" => "http://www.w3.org/2003/01/geo/wgs84_pos#",
    "xmlns:cc" => "http://web.resource.org/cc/"
  }
  # ライセンスに使用するタグ
  LICENSE_ELEMENTS = {
    permits: [
      {"rdf:resource" => "http://web.resource.org/cc/Reproduction"},
      {"rdf:resource" => "http://web.resource.org/cc/Distribution"},
      {"rdf:resource" => "http://web.resource.org/cc/DerivativeWorks"}
    ],
    requires: [
      {"rdf:resource" => "http://web.resource.org/cc/Notice"},
      {"rdf:resource" => "http://web.resource.org/cc/Attribution"}
    ]
  }
  attr_accessor :template, :elements

  #=== 初期化
  def initialize(template, records=[])
    @template = template
    @records = Array.wrap(records)
    @elements = @template.all_elements.root.publishes.includes(:children, :source)
    @cache_element_full_name = {}
    @cache_regular_expression = {}
    @cache_input_type = {}
    @inputable_elements = []
  end

  #=== RDF化
  def to_rdf(only_id = nil)
    builder = create_xml
    Nokogiri::XML(builder.to_xml, nil, 'utf-8').to_xml.toutf8
  end

private

  #
  #=== xmlを作成する
  #
  def create_xml
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml['rdf'].RDF(XMLNS) do
        xml['rdf'].Description('rdf:about' => "/templates/1/records/download_rdf") do
          set_template_name(xml)
          set_elements(xml)
          set_records(xml)
          set_rights(xml)
        end
        set_license(xml)
      end
    end
  end

  #
  #=== テンプレートの名前の表示部を表示する
  #
  def set_template_name(xml)
    xml['mlod'].name(@template.name)
  end

  #
  #=== 使用プログラミング言語部を表示する
  #
  def set_program_language(xml)
    xml['mlod'].programingLanguage(PROGRAM_NAME)
  end

  #
  #=== エレメント表示部のヘッダー部を作成する
  #
  def set_elements(xml)
    xml['mlod'].elementDefinition do
      xml['rdf'].Description('rdf:about' => show_elements_template_elements_path(@template)) do
        set_program_language(xml)
        set_element_description(@elements, xml)
      end
    end
  end

  #
  #=== エレメントの一覧のxmlを作成する
  #
  #
  def set_element_description(elements, xml, namespace_str='')
    xml['mlod'].elements('rdf:parseType' => 'Collection') do
      elements.each do |element|
        input_type = @cache_input_type[element.input_type_id]
        if input_type.blank?
          @cache_input_type[element.input_type_id] = element.input_type
          input_type = element.input_type
        end
        element.input_type = input_type
        if element.children.blank?
          @cache_element_full_name[element.id] =  namespace_str + element.name
          @inputable_elements << element
        end
        xml['rdf'].Description('rdf:about' => element.about_url_for_rdf(@template)) do
          xml['mlod'].name(element.name)
          xml['mlod'].entryName(element.entry_name)
          if element.namespace?
            xml['mlod'].multipleInput(Element.human_attribute_name(:multiple_input)) if element.multiple_input?
            xml['mlod'].restriction('rdf:parseType' => "Resource") do
              xml['mlod'].available(element.actually_available?)
            end
            set_element_description(element.children.publishes.includes(:children, :source), xml, "#{namespace_str}#{element.name}:")
          else
            xml['mlod'].inputType(input_type.label)
            if input_type.pulldown? || input_type.checkbox?
              xml['mlod'].dataInputWay(I18n.t("element.data_input_way_label.#{Element::DATA_INPUT_WAYS[input_type.name.to_sym].invert[element.data_input_way]}"))
            end
            xml['mlod'].description(element.description)
            xml['mlod'].restriction('rdf:parseType' => "Resource") do
              xml['mlod'].required(element.required?)
              xml['mlod'].unique(element.unique?)
              xml['mlod'].available(element.actually_available?)
              regular_expression = @cache_regular_expression[element.regular_expression_id]
              regular_expression = element.regular_expression if regular_expression.blank?
              xml['mlod'].format('rdf:parseType' => "Resource") do
                @cache_regular_expression[regular_expression.id] = regular_expression if regular_expression.present?
                xml['mlod'].name(regular_expression.try(:name))
                xml['mlod'].regularExpression(regular_expression.try(:format))
              end
              xml['mlod'].maxNumberOfChars(element.max_digit_number)
              xml['mlod'].minNumberOfChars(element.min_digit_number)
            end
            if input_type.referenced_type?
              xml['mlod'].codelist do
                resource_url = (element.source_element.try(:about_url_for_rdf, element.template, referenced: true) || element.source.try(:about_url_for_rdf))
                about = resource_url ? {'rdf:about' => resource_url} : {}
                xml['rdf'].Description(about) do
                  if element.source.is_a?(Vocabulary::Element) && !element.source.from_vdb?
                    # コードリスト(element参照ではない)でかつ語彙データベースから機械的に登録されていないもののみ、選択肢をrdfに直接記述する
                    element.code_list_values.each do |value|
                      xml['mlod'].code value
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  #
  #=== データ部のxmlを作成する
  #
  #
  def set_records(xml)
    xml['mlod'].data do
      xml['rdf'].Description('rdf:about' => template_records_path(@template)) do
        xml['mlod'].templateRecords('rdf:parseType' => 'Collection') do
          @records.each do |record|
            item_numbers_by_namespace = record.item_numbers_by_namespace
            element_values = record.values
            xml['rdf'].Description('rdf:about' => template_record_path(@template, record)) do
              xml['mlod'].recordID(record.id, 'rdf:parseType' => 'Literal')
              xml['mlod'].elementValues('rdf:parseType' => 'Resource') do
                @inputable_elements.each_with_index do |element|
                  xml['mlod'].elementValue('rdf:parseType' => element.input_type.referenced_type? ? 'Literal' : 'Resource') do
                    xml['mlod'].name(@cache_element_full_name[element.id])
                    multiple_input_namespace = element.multiple_input_ancestor
                    item_numbers = item_numbers_by_namespace[multiple_input_namespace.try(:id)]

                    # あるレコードの、ある項目に対しての入力データ
                    values = element_values.select{|e_v| e_v.element_id == element.id}

                    if values.blank?
                      # あるレコードの、ある項目に対して、入力データが無いとき
                       set_element_value(xml, element, [])
                    else
                      # 繰り返し入力が設定されていて、かつ実際に二回以上入力されている場合のみ、repeatをつける
                      if item_numbers == 1
                        set_element_value(xml, element, values)
                      else
                        (1..item_numbers).each do |item_number|
                          e_vs = values.select{|e_v| e_v.item_number == item_number }
                          xml['mlod'].repeat('rdf:parseType' => "Resource"){ set_element_value(xml, element, e_vs) }
                        end
                      end
                    end
                  end
                end
              end
              set_last_modified(xml, record)
              set_rights(xml, record)
            end
          end
        end
      end
    end
  end

  #
  #=== データの実際の値を表示する
  #
  def set_element_value(xml, element, values)
    if values.blank?
      xml['mlod'].value
    else
      i_t = element.input_type
      if i_t.upload_file?
        xml['mlod'].value do
          label_value = values.detect{|v| v.kind == ElementValue::LABEL_KIND}
          file_value = values.detect{|v| v.kind == ElementValue::FILE_KIND}
          mime_type = MIME::Types.type_for(file_value.try(:value).to_s).first.try(:content_type)
          xml['mlod'].label label_value.try(:value)
          xml['mlod'].name file_value.try(:value)
          xml['mlod'].mimeType mime_type
          xml['mlod'].binary Base64.encode64(File.read(file_value.content.path))
        end
      elsif i_t.location?
        if i_t.all_locations?
          ElementValue::ALL_LOCATIONS_KINDS.each do |k, v|
            xml['mlod'].value do
              xml['geo'].Point do
                lat_val = values.detect{|val| val.kind == v[:latitude] }
                lon_val = values.detect{|val| val.kind == v[:longitude] }
                if lat_val && lon_val
                  xml['geo'].lat(lat_val.formatted_value)
                  xml['geo'].long(lon_val.formatted_value)
                end
              end
            end
          end
        else
          xml['mlod'].value do
            xml['geo'].Point do
              values.sort_by(&:kind).each do |value|
                xml['geo'].lat(value.formatted_value) if value.kind == ElementValue::LATITUDE_KIND
                xml['geo'].long(value.formatted_value) if value.kind == ElementValue::LONGITUDE_KIND
              end
            end
          end
        end
      else
        values.each do |value|
          if i_t.referenced_type?
            xml['mlod'].value(value.formatted_value, 'mlod:ref' => value.content.value)
          else
            xml['mlod'].value(value.formatted_value)
          end
        end
      end
    end
  end

  #=== 作成者情報を設定
  def set_rights(xml, record = nil)
    if record
      user = record.user
      section = user.section
      copyright = section.copyright || user.copyright
      if copyright
        xml['dc'].rights do
          xml.Agent do
            xml['dc'].title do
              xml.text copyright
            end
          end
        end
      end
    else
      xml['dc'].rights do
        xml.Agent do
          xml['dc'].title do
            xml.text template.service.section.copyright
          end
        end
      end
    end
  end

  #=== ライセンスを設定
  def set_license(xml)
    xml['cc'].License('rdf:about' => CREATIVECOMMONS_URL) do
      LICENSE_ELEMENTS.each do |key, values|
        values.each{|v| xml.send(key, v) }
      end
    end
  end

  #=== 最終更新日を設定
  def set_last_modified(xml, record)
    # NOTE: time_zoneがutcで取得されるので、jstに変換してから日付を出す
    xml['dcterms'].modified(record.updated_at.in_time_zone("Tokyo").strftime("%Y-%m-%d"))
  end
end
