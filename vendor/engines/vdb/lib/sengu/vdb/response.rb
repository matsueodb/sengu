require 'nokogiri'
#
#== 語彙データベースからのレスポンス
#
class Sengu::VDB::Response
  HTTP_STATUS_CODES = {success: "200", no_content: "204", not_found: "404", internal_server_error: "500"}
  DOMAIN_PREFIX = {
    Sengu::VDB::Core::DOMAIN_ID   => CORE_PREFIX_STR = 'ic',
    Sengu::VDB::Domain::DOMAIN_ID => DOMAIN_PREFIX_STR = 'mlod',
  }

  attr_accessor :complexes, :elements, :code_lists, :getname
  attr_reader :status, :message, :domain

  class ParseError < StandardError; end;

  #
  #=== RDFをパースする
  #
  def self.parse(response, domain, getname=nil)
    begin
      vdb_response = self.new(status: response.try(:code), getname: getname, domain: domain)
      if response.kind_of?(Net::HTTPOK)
        doc = Nokogiri::XML(response.body)
        vdb_response.complexes = Sengu::VDB::Response::ComplexType.parse_with_doc(doc, domain)
        vdb_response.elements = Sengu::VDB::Response::ElementItem.parse_with_doc(doc, domain)
        vdb_response.code_lists = Sengu::VDB::Response::CodeList.parse_with_doc(doc, domain)
      end
      vdb_response
    rescue => e
      Rails.logger.error "#{e.message}\n#{e.backtrace.join("\n")}"
      raise ::Sengu::VDB::Response::ParseError
    end
  end

  #
  #=== ドメインのプレフィックスを返す
  #
  def self.domain_prefix(domain)
    "#{DOMAIN_PREFIX[domain]}:"
  end

  #
  #=== 初期化
  #==== 引数
  # * url - アクセスするURL
  def initialize(attr = {})
    @complexes = Array(attr[:complexes])
    @elements = Array(attr[:elements])
    @code_lists = Array(attr[:code_lists])
    @status = attr[:status]
    @message = I18n.t("sengu.vdb.response.messages.#{@status.present? ? "code_#{@status}" : 'failure'}")
    @getname = attr[:getname]
    @domain = attr[:domain]
  end

  #
  #=== 全てのElementItemインスタンスを取得する
  #
  def all_elements
    all_els = self.complexes.map(&:elements).flatten
    all_els += self.elements
    all_els.map(&:all_elements).flatten
  end

  #
  #=== getnameで指定された名前をもつcomplex要素を返す
  #
  def find_complex_with_getname
    self.complexes.detect{|c| c.name == self.getname}
  end

  #
  #=== getnameで指定された名前をもつelement要素を返す
  #
  def find_element_with_getname
    self.all_elements.detect{|e| e.name == self.getname}
  end

  #
  #=== getnameで指定された名前をもつcode_list要素を返す
  #
  def find_code_list_with_getname
    self.code_lists.detect{|c| c.name == self.getname}
  end

  HTTP_STATUS_CODES.each do |k,v|
    define_method("#{k.to_s}?") do
      self.status == v
    end
  end

  #
  #=== 致命的なエラーかどうか
  #
  def fatal?
    self.not_found? || self.internal_server_error?
  end
end
