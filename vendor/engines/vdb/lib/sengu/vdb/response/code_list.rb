#
#== 語彙DBから取得したコードリストを管理するクラス
#
class Sengu::VDB::Response::CodeList
  attr_reader :name, :values, :node

  #
  #=== doc全体からのパース
  #
  # * doc全体からインスタンスを作成して、配列で返す
  #
  #==== 引数
  #
  # * :doc - 取得した結果をNokogiriでパースしたもの
  # * :domain - 'core' or 'domain'
  def self.parse_with_doc(doc, domain)
    namespaces = doc.collect_namespaces
    doc.xpath('.//xsd:complexType', namespaces).each_with_object([]) do |complex_node, code_lists|
      values = self.parse_values(doc, complex_node, namespaces)
      if values.present?
        code_lists << self.new(values, complex_node, namespaces)
      end
    end
  end

  #
  #=== 初期化
  #
  # * インスタンスを作成する
  #
  #==== 引数
  #
  # * :node - xsd:complexTypeのノード
  # * :namespaces - xmlのネームスペースのハッシュ(docから取得出来るが毎回取得すると遅い)
  def initialize(values, node, namespaces)
    @node = node
    @name = @node['name']
    @values = values
  end

  #
  #=== Vocabulary::Elementの作成
  #
  # * selfをもとにVocabulary::Elementのインスタンスを作成する　
  #
  def to_vocabulary_element
    v_element = Vocabulary::Element.new(name: self.name, from_vdb: true)
    self.values.each{|name| v_element.values.build(name: name)}
    return v_element
  end

  #
  #=== Vocabulary::Elementの保存
  #
  # * selfをもとにVocabulary::Elementのインスタンスを作成して保存する
  #
  def save_vocabulary_element
    element = self.to_vocabulary_element
    return element.save ? element : false
  end

private

  #
  #=== コードリスト値のパース
  #
  # * コードリストをxsd:documentationから取得してパースする
  #
  def self.parse_values(doc, node, namespaces)
    if extension_node = node.at('.//xsd:extension', namespaces)
      if simple_type_node = doc.at("//xsd:simpleType[@name='#{extension_node[:base].sub(/^.+:/, '')}']", namespaces)
        if simple_type_node.at('//xsd:restriction[@base="xsd:token"]', namespaces)
          return simple_type_node.xpath('.//xsd:enumeration', namespaces).map{|v| v.text.strip}
        end
      end
    end
    return []
  end
end

