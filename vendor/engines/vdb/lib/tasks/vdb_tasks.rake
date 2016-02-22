namespace :vdb do
  desc "check all elements from vocabulary databaase"
  task check_all: :environment do
    prepare("/tmp/check_all")

    # Whole検索をして、そのxmlから個別検索の対象を抽出する
    response = Sengu::VDB::Core.get_vocabulary(Settings.vdb.api_ids.all_id)
    doc = Nokogiri::XML(response.body)
    namespaces = doc.collect_namespaces

    # xsd:complextype name="xxx"を取り出し、そのnameで個別検索して取得できるか、を試す。
    doc.xpath("//xsd:complexType", namespaces).each do |complex_type_node|
      name = complex_type_node["name"]
      res = find(Sengu::VDB::Core, name)
      analyze_response(res, Sengu::VDB::Core.domain_id, name)
    end

    # xsd:element name="yyy"を取り出し、そのnameで個別検索して取得できるか、を試す。
    # ただし、ref属性がついているものは、対象にしない
    doc.xpath("//xsd:element[not(@ref)]", namespaces).each do |element_node|
      name = element_node["name"]
      element_info = element_node.to_xml.split("\n").first
      res = find(Sengu::VDB::Core, name)
      analyze_response(res, Sengu::VDB::Core.domain_id, name, true, element_info)
    end
  end

  desc "check complex type existence"
  task check_complex_type_existence: :environment do
    prepare("/tmp/check_complex_type_existence")

    complex_types.each do |name|
      res = find(Sengu::VDB::Core, name)
      analyze_response(res, Sengu::VDB::Core.domain_id, name)
    end
  end

  desc "check_too_depth_copmlex_type"
  task check_too_depth_copmlex_type: :environment do
    complex_types.each do |name|
      begin
        Sengu::VDB::Core.find(name)
      rescue
        puts name
      end
    end
  end
end

def complex_types(addition: [], redution: [])
  # REF: IMI20130821ref1MI_Core_rev2.xlsx
  base_complex_types = %w(人型 氏名型 住所型 構造化住所型 方書型 連絡先型 電話番号型 組織型 組織関連型 関連型 系列型 場所型 証明型 物型 有体物型 輸送機関型 航空機型 自動車型 船舶型 輸送関連型 輸送関連型 建物型 施設型 建物構造型 活動型 測定単位型 数量型 容量型 面積型 重量型 長さ型 物品価値型 金額型 実体型 状況型 期間型 日付型 スケジュール型 経緯度座標系型 UTM座標系型 MGRS座標系型 緯度型 経度型 緯度値型 経度値型 緯度値単純型 経度値単純型 分型 秒型 分単純型 秒単純型 パーセンテージ型 パーセンテージ単純型 固有名型 テキスト型 カタカナテキスト型)
  base_complex_types << addition if addition.present?
  base_complex_types.reject! { |name| name.in?(redution) } if redution.present?
  base_complex_types
end

def prepare(path)
  @path = path
  FileUtils.rm_r @path if File.exists? @path
  FileUtils.mkdir @path
end

def find(vdb_class, name, relate_flg=true)
  sleep 0.5
  relate_flg = Sengu::VDB::Base::RELATE_FLGS[relate_flg]
  vdb_class.get_vocabulary(Settings.vdb.api_ids.find_id, getname: name, relateflg: relate_flg)
end

def analyze_response(response, domain, name, relate_flg=true, element_info="")
  status = response.try(:code)

  unless status == "200"
    if relate_flg
      write_log("INVALID STATUS CODE", name, domain, status, relate_flg, element_info)

      # statusが200以外で、かつrelate_flgがtrueの場合は、relate_flgをfalseにして、再度アクセスする
      res = find(TemplateElementSearch.new(domain_id: domain).vdb_class, name, false)
      return analyze_response(res, domain, name, false, element_info)
    else
      return write_log("INVALID STATUS CODE", name, domain, status, relate_flg, element_info)
    end
  end

  return write_log("BLANK RESPONSE BODY", name, domain, status, relate_flg) if response.body.blank?

  write_xml(response, name)
  write_log("SUCCESS", name, domain, status, relate_flg)
end

def write_xml(response, name)
  name = name.encode("UTF-8")
  path = File.join(@path, "#{name}.xml")
  xml = Nokogiri::XML(response.body).to_xml
  File.open(path, "w") { |f| f.print xml }
end

def write_log(result, name, domain, status = "不明", relate_flg=true, element_info="")
  str = "result: %s, name: %s, domain: %s, status: %s, relateflg: %s"
  path = File.join(@path, "result.log")

  File.open(path, "a") do |f|
    f.puts str % [result, name, domain, status, relate_flg]
    if element_info.present?
      f.puts "        #{element_info}"
    end
  end
end
