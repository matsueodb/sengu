#
#== 語彙データベースから取得したElementインスタンス
#
class Sengu::VDB::Response::ElementItem
  LINE_TYPE = InputType.find_line
  VOCABULARY_TYPE = InputType.find_pulldown_vocabulary

  # データタイプを展開していくと無限ループすることがあるので、階層の数で制限をかける
  # nilの場合は無制限
  MAX_DEPTH = nil

  attr_reader :name,  # 項目名
    :entry_name,      # エントリー名
    :data_type,       # データタイプ(ic:テキスト型..)
    :description,     # 項目説明
    :parent,            # VDB::Response::Elementインスタンス
    :abstract,
    :children,
    :node,
    :depth,
    :error_messages,
    :code_list,
    :domain

  attr_accessor :complex

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
    doc.xpath('//xsd:element[@name]', namespaces).each_with_object([]) do |element, elements|
      ref_name = Sengu::VDB::Response.domain_prefix(domain) + element['name']
      if !doc.at("//xsd:complexType//xsd:element[@ref='#{ref_name}']", namespaces)
        elements << Sengu::VDB::Response::ElementItem.new(element, doc, namespaces, domain, 1)
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
  # * :node - xsd:elementのノード
  # * :doc - 取得した結果をNokogiriでパースしたもの
  # * :namespaces - xmlのネームスペースのハッシュ(docから取得出来るが毎回取得すると遅い)
  # * :domain - 'core' or 'domain'
  # * :depth - 要素の深さ
  def initialize(node, doc, namespaces, domain, depth = 1)
    @domain = domain
    @node = node
    @entry_name = parse_entry_name(domain)
    @depth = depth
    detail_node = detail_element_node(doc, namespaces)
    @name = detail_node['name'].present? ? detail_node['name'] : @entry_name.sub(/^.+:/, '')
    @data_type = detail_node['type']
    @abstract = detail_node['abstract'].present?
    @description = parse_description(detail_node, namespaces)
    @children = parse_children_element(detail_node, doc, namespaces, domain)
  end

  #
  #=== Element(AR)への変換　
  #
  # * selfの情報を基にElementインスタンスを作成する
  #
  #==== 引数
  #
  # * :template_id - テンプレートのID
  def to_element(template_id)
    element = element_new(template_id: template_id)
    Sengu::VDB::Mapping.mapping(element)
    self.children.each do |child_el|
      element.children << child_el.to_element(template_id)
    end
    return element
  end

  #=== elementを保存する。
  # 子エレメントについても順に作成していく
  # to_element.saveでは、子エレメントのparent_idがnilの状態でname, uniqueness:trueのエラーが出てしまう。
  def save_to_element(template_id, parent_id = nil)
    error_messages = []
    element = element_new(template_id: template_id, parent_id: parent_id)
    if source = element.source
      if vocabulary_element = Vocabulary::Element.find_by(name: source.name, from_vdb: true)
        element.source = vocabulary_element
      else
        source.from_vdb = true
        source.save
        element.source = source
      end
    end
    Sengu::VDB::Mapping.mapping(element)
    if element.valid?
      element.save
      self.children.each do |child_el|
        result = child_el.save_to_element(template_id, element.id)
        if result.kind_of?(Array) # error_messages
          error_messages << result
        end
      end

      return error_messages.empty? ? element : error_messages
    else
      return element.errors.full_messages.map{|fm|"【#{element.name}】#{fm}"}
    end
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
    element = self.to_element(template_id)
    if element.save
      return true
    else
      @error_messages = element.errors.full_messages.map{|fm|"【#{element.name}】#{fm}"}
      return false
    end
  end

  #
  #=== 全てのエレメントを配列で返す
  #
  def all_elements
    self_and_children = self.children.dup
    self_and_children << self
  end

  #
  #=== 要素として除外するかどうか
  #
  def excluded?
    return false if self.data_type.blank? || self.name.blank?

    case self.data_type.sub(/^.+:/, '')
    when "活動型"
      case self.name
      when *%w(活動_上位活動 活動_サブ活動)
        return true
      end
    when "組織型"
      case self.name
        when *%w(連絡先_組織 組織_支店 組織_部門 組織_サブ部門 組織_代理人)
        return true
      end
    else
      return false
    end
  end

private

  #
  #=== 詳細情報をもつxsd:elementノードを返す
  #
  # * 詳細情報をもつxsd:elementノードを返す
  # * refで参照している場合は参照先のノードを返す
  #
  #==== 引数
  #
  # * :doc - 取得した結果をNokogiriでパースしたもの
  # * :namespaces - xmlのネームスペースのハッシュ(docから取得出来るが毎回取得すると遅い)
  def detail_element_node(doc, namespaces)
    if ref_node?
      node = doc.at("//xsd:element[@name='#{self.entry_name.sub(/^.+:/, '')}']", namespaces)
      node.nil? ? self.node : node
    else
      self.node
    end
  end

  #
  #=== エントリー名をノードから取得すする
  #
  def parse_entry_name(domain)
    if ref_node?
      self.node['ref']
    else
      domain_prefix = Sengu::VDB::Response.domain_prefix(domain)
      domain_prefix + self.node['name']
    end
  end

  #
  #=== 詳細情報をノードから取得する
  #
  def parse_description(node, namespaces)
    node.xpath('./xsd:annotation//xsd:documentation[@xml:lang="ja"]', namespaces).text
  end

  #
  #=== 参照先を持つノードかどうか
  #
  def ref_node?
    self.node['ref'].present?
  end

  #
  #=== 要素が深すぎるかどうか
  #
  def too_deep?
    return false unless MAX_DEPTH
    @depth >= MAX_DEPTH
  end

  #
  #=== 子ElementItemの作成
  #
  # * 代替要素の場合もあるので考慮する
  #
  #==== 引数
  #
  # * :node - xsd:elementのノード
  # * :doc - 取得した結果をNokogiriでパースしたもの
  # * :namespaces - xmlのネームスペースのハッシュ(docから取得出来るが毎回取得すると遅い)
  # * :domain - 'core' or 'domain'
  def parse_children_element(node, doc, namespaces, domain)
    child_els = []

    # 自身が除外される要素である、または深さの制限にかかるとき、子要素を作らない。緯度、経度は特別に型展開を行わない
    return child_els if self.excluded? || too_deep? || self.data_type.in?(["ic:緯度型", "ic:経度型"])

    if name = node['name']
      if self.data_type.present?
        if child_el_node = doc.at("//xsd:complexType[@name='#{self.data_type.sub(/^.+:/, '')}']", namespaces)
          if extension_node = child_el_node.at('.//xsd:extension', namespaces)
            if simple_type_node = doc.at("//xsd:simpleType[@name='#{extension_node[:base].sub(/^.+:/, '')}']", namespaces)
              if simple_type_node.at('//xsd:restriction[@base="xsd:token"]', namespaces)
                values = Sengu::VDB::Response::CodeList.parse_values(doc, child_el_node, namespaces)
                @code_list = Sengu::VDB::Response::CodeList.new(values, child_el_node, namespaces).to_vocabulary_element
              end
            end
          end

          child_el_node.xpath(".//xsd:element", namespaces).each do |el_node|
            child_els << Sengu::VDB::Response::ElementItem.new(el_node, node, namespaces, domain, @depth + 1)
          end
        end
      end

      # 抽象要素のchildrenは代替要素となる。
      group_name = Sengu::VDB::Response.domain_prefix(domain) + name
      child_el_nodes = doc.xpath("//xsd:element[@substitutionGroup='#{group_name}']", namespaces)
      child_el_nodes.each do |el_node|
        child_el = Sengu::VDB::Response::ElementItem.new(el_node, node, namespaces, domain, @depth + 1)
        next if child_el.excluded?
        child_els << child_el
      end
    end
    return child_els
  end

  #
  # === Element.newを共通化
  def element_new(attr = {})
    Element.new(
      {name: self.name,
       entry_name: self.entry_name,
       input_type_id: self.code_list ? VOCABULARY_TYPE.id : LINE_TYPE.id,
       description: self.description,
       abstract: self.abstract,
       original_data_type: (self.data_type.present? ? self.data_type.sub(/^.+:/, '') : ""),
       data_type: self.data_type,
       domain_id: self.domain,
       source: self.code_list ? code_list : nil}.merge(attr))
  end
end
