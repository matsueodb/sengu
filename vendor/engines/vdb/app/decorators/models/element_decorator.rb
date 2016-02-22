Element.class_eval do
  AVAILABLE_INPUT_TYPE = {
    "ic:テキスト型" => [:line, :multi_line]
  }

  attr_accessor :abstract, :original_data_type

  #
  #=== RDFで出力する際の'rdf:about'属性の値を返す
  #
  def about_url_for_rdf_with_vdb(template, referenced: false)
    # 項目Aの参照先として項目Bが設定されている場合、項目Aの「codelist」のリソースURIは語彙DBではなく、必ずsengu上のURIとする
    return about_url_for_rdf_without_vdb(template) if referenced

    case self.domain_id
    when Sengu::VDB::Core::DOMAIN_ID
      vdb_class = Sengu::VDB::Core
    when Sengu::VDB::Domain::DOMAIN_ID
      vdb_class = Sengu::VDB::Domain
    else
      return about_url_for_rdf_without_vdb(template)
    end
    vdb = Settings.vdb
    URI.join(vdb.server.host, vdb.server.path, "v#{vdb.version}/", "#{vdb.project_id}/", "#{self.domain_id}/")
    url = URI.join(vdb_class.url_base, vdb.api_ids.find_id)
    name = self.entry_name.gsub(/^.*:/, "")
    "#{url.to_s}?getname=#{name}&relateflg=#{Sengu::VDB::Base::RELATE_FLGS[true]}"
  end

  alias_method_chain :about_url_for_rdf, :vdb

  #
  #=== 使用不可能なInputTypeのIDを返す
  #
  def disabled_input_type_ids
    []
  end
end
