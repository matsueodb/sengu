#
#== 語彙DBから取得したRDFのxsd:Complex要素の部分(型)のインスタンス
#
class Sengu::VDB::Response::ComplexType
  attr_reader :name, :description, :node, :domain, :error_messages
  attr_accessor :elements

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
    doc.xpath('//xsd:complexType', namespaces).each_with_object([]) do |complex_type, complexes|
      complexes << Sengu::VDB::Response::ComplexType.new(complex_type, doc, namespaces, domain)
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
  # * :doc - 取得した結果をNokogiriでパースしたもの
  # * :namespaces - xmlのネームスペースのハッシュ(docから取得出来るが毎回取得すると遅い)
  # * :domain - 'core' or 'domain'
  def initialize(node, doc, namespaces, domain)
    @node = preprocess_node(doc, node, namespaces)
    @name = node[:name]
    @description = parse_description(namespaces)
    @elements = parse_elements(doc, namespaces, domain)
    @domain = domain
  end

  #
  #=== Element(AR)への変換　
  #
  # * selfの情報を基にElementインスタンスを作成する
  #
  #==== 引数
  #
  # * :template_id - テンプレートのID
  def to_elements(template_id)
    self.elements.map{|element| element.to_element(template_id)}
  end

  #
  #=== Element(AR)への変換し、保存する
  #
  # * selfの情報を基にElementインスタンスを作成し保存する
  #
  #==== 引数
  #
  # * :template_id - テンプレートのID
  def save_element(template_id)
    @error_messages = []
    ActiveRecord::Base.transaction do
      prefix = Sengu::VDB::Response.domain_prefix(@domain)
      e = Element.new(
        template_id: template_id,
        name: self.name,
        entry_name: prefix + self.name,
        input_type: InputType.find_line,
        description: self.description,
        domain_id: self.domain
      )
      Sengu::VDB::Mapping.mapping(e)
      @error_messages += e.errors.full_messages.map{|m| "【#{e.name}】#{m}"} unless e.save
      self.elements.map do |element|
        result = element.save_to_element(template_id, e.id)
        @error_messages += result if result.kind_of?(Array)
      end.flatten.compact
      unless @error_messages.flatten.compact.empty?
        raise
      end
      return true
    end
    rescue
      return false
  end

private

  #
  #=== 詳細情報をノードから取得する
  #
  def parse_description(namespaces)
    self.node.xpath('xsd:annotation//xsd:documentation[@xml:lang="ja"]', namespaces).text
  end

  #
  #=== 子ElementItemの作成
  #
  #==== 引数
  #
  # * :doc - 取得した結果をNokogiriでパースしたもの
  # * :namespaces - xmlのネームスペースのハッシュ(docから取得出来るが毎回取得すると遅い)
  # * :domain - 'core' or 'domain'
  def parse_elements(doc, namespaces, domain)
    element_nodes(self.node, doc, namespaces).each_with_object([]) do |element, elements|
      element_item = Sengu::VDB::Response::ElementItem.new(element, doc, namespaces, domain, 1)
      # 型を展開していくとループすることがある。その原因となる要素を含まないようにする
      next if element_item.excluded?

      elements << element_item
    end
  end

  #
  #=== 子xsd:elementノードの取得
  #
  # * extensionで拡張されている場合は、拡張基からも取得(拡張の深さが1では無いため再帰的に処理する)
  #
  #==== 引数
  #
  # * :doc - 取得した結果をNokogiriでパースしたもの
  # * :namespaces - xmlのネームスペースのハッシュ(docから取得出来るが毎回取得すると遅い)
  def element_nodes(node, doc, namespaces)
    nodes = node.xpath('.//xsd:element', namespaces)
    if extension = node.at('.//xsd:extension[@base]', namespaces)
      name = extension['base'].sub(/^.+:/, '')
      if extension_complex_node = doc.at("//xsd:complexType[@name='#{name}']", namespaces)
        nodes += element_nodes(extension_complex_node, doc, namespaces)
        nodes += extension_complex_node.xpath(".//xsd:element", namespaces)
      end
    end
    return nodes
  end

  #
  #=== senguで扱うためにnodeを加工する
  #
  def preprocess_node(doc, node, namespaces)
    # 型が要素を持たない場合、型のnodeにelementを作る
    unless node.at('.//xsd:element', namespaces)
      type_name = "ic:テキスト型"
      return node if node[:name] == type_name.sub(/^.+:/, '')  # ic:テキスト型に対して、要素にic:テキスト型が入ると無限ループする
      e = Nokogiri::XML::Node.new("xsd:element", doc)
      e.set_attribute("name", node[:name].sub(/型\z/, ""))
      e.set_attribute("type", type_name)
      if node.at(".//xsd:complexContent", namespaces)
        node.at(".//xsd:complexContent", namespaces).add_child(e)
      elsif node.at(".//xsd:simpleContent", namespaces)
        node.at(".//xsd:simpleContent", namespaces).add_child(e)
      end
    end

    node
  end
end
