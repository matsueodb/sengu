#
#=== テンプレートのPDF出力処理を行う
#
require 'prawn/table'
class Sengu::Template::PDF < Prawn::Document
  FONT_FILE_PATH = Rails.root.join('vendor', 'fonts', 'ipam.ttf')
  DATA_LIST_HEADER = [
    I18n.t('sengu.template.pdf.number'),
    I18n.t('sengu.template.pdf.item_name'),
    I18n.t('sengu.template.pdf.entry_name'),
    I18n.t('sengu.template.pdf.description'),
    I18n.t('sengu.template.pdf.restrict')
  ]
  CHILD_EXISTS_MARK = "▼"
  STRUCTURE_BASIC_TABLE =
    {"./rdf:Description" => [{content: :description_whole, colspan: 4, rowspan: 12},
                             {"./mlod:name" => {content: :template_name, colspan: 3},
                               "./mlod:elementDefinition" => [{content: :element_definition, colspan: 3, rowspan: 4},
                                                              {"./rdf:Description" => [{content: :description_definition, colspan: 2, rowspan: 3},
                                                                                       {"./mlod:programingLanguage" => {content: :programing_language},
                                                                                         "./mlod:elements" => {content: :description_elements}}]
                                                              }],
                               "./mlod:data" => [{content: :data, colspan: 3, rowspan: 3},
                                                 {"./rdf:Description" => [{content: :description_data, colspan: 2, rowspan: 2},
                                                                          {"./mlod:templateRecords" => {content: :description_template_records}}]
                                                 }],
                               "./dc:rights" => [{content: :whole_rights, colspan: 3, rowspan: 3},
                                                 {"./Agent" => [{content: :agent, colspan: 2, rowspan: 2},
                                                                {"./dc:title" => {content: :agent_title}}]
                                                 }]
                             }],
    "./cc:License" => {content: :license, colspan: 4}}

  STRUCTURE_DEFINITION_TABLE =
    {"./rdf:Description" => [{content: :definition, colspan: 4, rowspan: 18},
                           {"./mlod:name" => {content: :element_name, colspan: 3},
                               "./mlod:entryName" => {content: :entry_name, colspan: 3},
                               "./mlod:inputType" => {content: :input_type, colspan: 3},
                               "./mlod:dataInputWay" => {content: :data_input_way, colspan: 3},
                               "./mlod:multipleInput" => {content: :multiple_input, colspan: 3},
                               "./mlod:restriction" => [{content: :restriction, colspan: 3, rowspan: 9},
                                                        {"./mlod:required" => {content: :required, colspan: 2},
                                                          "./mlod:unique" => {content: :unique, colspan: 2},
                                                          "./mlod:available" => {content: :available, colspan: 2},
                                                          "./mlod:format" => [{content: :format, colspan: 2, rowspan: 5},
                                                                            {"./mlod:name" => {content: :format_name},
                                                                              "./mlod:regularExpression" => {content: :regular_expression}}],
                                                        "./mlod:maxNumberOfChars" => {content: :max_number_of_chars},
                                                        "./mlod:minNumberOfChars" => {content: :min_number_of_chars},
                                                      }],
                             "./mlod:codelist" => [{content: :codelist, colspan: 3, rowspan: 3},
                                                   {"./rdf:Description" => [{content: :description_code, colspan: 2, rowspan: 2},
                                                                            {"./mlod:code" => {content: :code}}]
                                                   }]
                           }]
  }

  STRUCTURE_DATA_TABLE =
    {"./rdf:Description" => [{content: :data_description, colspan: 5, rowspan: 10},
                             {"./mlod:recordID" => {content: :record_id, colspan: 4},
                               "./mlod:elementValues" => [{content: :element_values, colspan: 4, rowspan: 4},
                                                          {"./mlod:elementValue" => [{content: :element_value, colspan: 3, rowspan: 3},
                                                                                     {"./mlod:name" => {content: :element_value_name, colspan: 2},
                                                                                       "./mlod:value" => {content: :element_value_value, colspan: 2}}]
                                                          }],
                               "./dcterms:modified" => {content: :modified, colspan: 4},
                               "./dc:rights" => [{content: :rights, colspan: 4, rowspan: 3},
                                                 {"./Agent" => [{content: :agent, colspan: 3, rowspan: 2},
                                                                {"./dc:title" => {content: :agent_title, colspan: 2}}]
                                                 }]
                             }]
  }

  #
  #=== 初期化
  #
  def initialize(template)
    super()
    @template = template
    font FONT_FILE_PATH
  end

  #
  #=== PDFデータを作成して返す
  #
  def render
    draw
    super()
  end

  #
  #=== PDFに出力する内容を書き込む
  #
  def draw
    draw_header
    draw_data_description
    draw_data_list
    draw_rdf_structure
    draw_rdf_sample
  end

private

  #
  #=== ヘッダーを描画する
  #
  # * タイトル
  # * 出力日付
  #
  def draw_header
    font_size(22){ text I18n.t('sengu.template.pdf.title', template_name: @template.name) }
    font_size(15){ text Date.today.strftime(I18n.t('date.formats.normal')), align: :right }
    move_down 10
  end

  #
  #== データ説明を描画する
  #
  # * サブタイトル
  # * 説明
  #
  def draw_data_description
    subtitle_draw(I18n.t('sengu.template.pdf.data_description_title'))
    font_size(11){ text nbsp(2) + I18n.t('sengu.template.pdf.data_description_content', distributor: @template.service.section.name, template_name: @template.name) }
    move_down 10
  end

  #
  #=== データ項目一覧を描画する
  #
  def draw_data_list
    subtitle_draw(I18n.t('sengu.template.pdf.data_list_title'))
    number = 0
    data = @template.all_elements.root.each_with_object([]) do |e, datas|
      number = set_row_element_data(e, datas, number, 1)
    end.unshift(DATA_LIST_HEADER)
    font_size(8) do
      table(data, header: true, column_widths: [25, 120, 115, 160, 120]) do
        row(0).style align: :center, background_color: 'b0c4de'
      end
    end
    move_down 10
  end

  #
  #=== RDFの基本構造
  #
  def draw_rdf_structure
    subtitle_draw(I18n.t('sengu.template.pdf.rdf_structure_title'))
    font_size(11){ text nbsp(2) + I18n.t('sengu.template.pdf.rdf_structure_basic_table') }
    move_down 3

    data = STRUCTURE_BASIC_TABLE.each_with_object([]) do |(k, v), datas|
      make_structure_table(datas, k, v)
    end
    font_size(8) do
      table(data)
    end

    start_new_page
    font_size(11){ text nbsp(2) + I18n.t('sengu.template.pdf.rdf_structure_definition_table') }
    move_down 3
    data = STRUCTURE_DEFINITION_TABLE.each_with_object([]) do |(k, v), datas|
      make_structure_table(datas, k, v)
    end
    font_size(8) do
      table(data)
    end

    start_new_page
    font_size(11){ text nbsp(2) + I18n.t('sengu.template.pdf.rdf_structure_data_table') }
    move_down 3
    data = STRUCTURE_DATA_TABLE.each_with_object([]) do |(k, v), datas|
      make_structure_table(datas, k, v)
    end
    font_size(8) do
      table(data)
    end

    move_down 10
  end

  #
  #=== RDFサンプルの描画
  #
  # 先頭の一件のデータを使用して、サンプルとして表示する
  #
  def draw_rdf_sample
    subtitle_draw(I18n.t('sengu.template.pdf.rdf_sample_title'))
    template_record =  @template.all_records.includes(values: :content).first
    rdf = Sengu::Rdf::Builder.new(@template, template_record)
    font_size(9) do text(rdf.to_rdf.gsub("&amp;", "&").gsub(' ', Prawn::Text::NBSP)) end
  end

  #
  #=== 各サブタイトルを描画する
  #
  def subtitle_draw(str)
    font_size(14){ text str }
    move_down 5
  end

  #
  #=== スペースを返す
  #
  def nbsp(repeat_time = 1)
    Prawn::Text::NBSP * repeat_time
  end

  #
  #=== 入力条件を配列にして返す
  #
  def restricts(element)
    array = []
    array << I18n.t('sengu.rdf.builder.restriction.not_available') unless element.actually_available?
    array << I18n.t('sengu.rdf.builder.restriction.required') if element.required?
    array << I18n.t('sengu.rdf.builder.restriction.unique') if element.unique?
    array << element.regular_expression.name if element.regular_expression.present?
    array
  end

  #
  #=== データ項目一覧の１行分を配列に格納する
  #
  def set_row_element_data(e, datas, number, depth)
    name = e.children.present? ? CHILD_EXISTS_MARK + e.name : e.name
    default_padding = 5 # Prawn::Table::Cellのデフォルトのpadding値
    cell_texts = [number += 1, name, e.entry_name, e.description, restricts(e).join("\n")]
    background_color = e.actually_available? ? "ffffff" : "f5f5f5"
    datas << cell_texts.map.with_index do |text, column_number|
      if column_number == 1
        padding = [default_padding, default_padding, default_padding, default_padding + 8 * (depth - 1)]
        Prawn::Table::Cell.make(self, text, background_color: background_color, padding: padding)
      else
        Prawn::Table::Cell.make(self, text, background_color: background_color)
      end
    end
    e.children.each do |child|
      number = set_row_element_data(child, datas, number, depth + 1)
    end
    number
  end

  #
  #=== RDFの構造を表す表を作成する
  #
  def make_structure_table(datas, xpath, array_or_hash)
    case array_or_hash
    when Hash
      colspan = array_or_hash[:colspan] || 1
      datas << [{content: xpath, background_color: "ffff99"},
                {content: translate(array_or_hash[:content]), colspan: colspan}]
    when Array
      colspan = array_or_hash.first[:colspan] || 1
      rowspan = array_or_hash.first[:rowspan] || 1
      datas << [{content: xpath, rowspan: rowspan, background_color: "ffff99"},
                {content: translate(array_or_hash.first[:content]), colspan: colspan}]

      array_or_hash.second.each do |_xpath, v|
        make_structure_table(datas, _xpath, v)
      end
    end
  end

  #
  #=== RDFの構造を表す表の中の説明を翻訳する
  #
  def translate(label)
    return "" unless label
    I18n.t("sengu.template.pdf.rdf_structure.#{label.to_s}")
  end
end
