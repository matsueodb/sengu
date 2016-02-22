#
#== 語彙DBからデータを取得するベースクラス
#
module Sengu::VDB
  class Base
    DOMAIN_ID = 'core'
    RELATE_FLGS = {
      false => "0",
      true => "1"
    }

    class ConnectionError < StandardError; end;

    #
    #=== APIの個別取得機能を利用する
    #
    #==== 引数
    # * name - 個別取得したい要素の名前
    # * relate_flg - 関連要素も取得するかどうか(default: true)
    #
    #==== 戻り値
    #
    # Sengu::VDB::Responseインスタンス
    def self.find(name, relate_flg=true)
      response = self.get_vocabulary(Settings.vdb.api_ids.find_id, getname: name, relateflg: RELATE_FLGS[relate_flg])
      Sengu::VDB::Response.parse(response, self.domain_id, name)
    end

    #
    #=== APIの全件取得機能を利用する
    #
    #==== 戻り値
    #
    # Sengu::VDB::Responseインスタンス
    def self.all
      response = self.get_vocabulary(Settings.vdb.api_ids.all_id)
      Sengu::VDB::Response.parse(response, self.domain_id)
    end

    #
    #=== APIの検索機能を利用する
    #
    #==== 引数
    # * name - 検索したい名前
    #
    #==== 戻り値
    #
    # Sengu::VDB::Responseインスタンス
    def self.search(name)
      response = self.get_vocabulary(Settings.vdb.api_ids.search_id, getname: name)
      Sengu::VDB::Response.parse(response, self.domain_id, name)
    end

    #
    #=== APIのベースのアドレスを返す
    #
    # {サーバアドレス}/v+{バージョン}/{プロジェクト識別子}/{domain}
    def self.url_base
      vdb = Settings.vdb
      URI.join(vdb.server.host, vdb.server.path, "v#{vdb.version}/", "#{vdb.project_id}/", "#{self.domain_id}/")
    end

    def self.get_vocabulary_url(api_id, params={})
      url = URI.join(self.url_base, api_id)
      url.query = URI.encode_www_form(params.to_a).force_encoding('utf-8') if params.present?
      url
    end

    #
    #=== パイロットシステムへアクセスする(60秒でタイムアウト)
    #
    #==== 引数
    # * api_id - 利用するAPIのID
    # * params - パラメータ
    #
    #==== 戻り値
    #
    # Sengu::VDB::Responseインスタンス
    def self.get_vocabulary(api_id, params={})
      begin
        url = self.get_vocabulary_url(api_id, params)
        pkcs_settings = Settings.vdb.pkcs12
        password = File.read(pkcs_settings.password_file_path).strip
        p12 = OpenSSL::PKCS12.new(File.read(pkcs_settings.path), password)

        https = Net::HTTP.new(url.host, 443)
        https.use_ssl = true
        https.key = p12.key
        https.cert = p12.certificate

        https.verify_mode = OpenSSL::SSL::VERIFY_PEER
        https.verify_depth = 5
        Rails.logger.debug "VDB => #{url}"
        response = https.start{ https.get("#{url.path}?#{url.query}") }
      rescue => e
        Rails.logger.error "#{e.message}\n#{e.backtrace.join("\n")}"
        raise ConnectionError
      end
      return response
    end

    #
    #=== ドメインのIDを返す
    # 本来はサブクラスのメソッドが呼び出される為、呼び出されない
    #
    #==== 戻り値
    #
    # 'core'
    def self.domain_id
      DOMAIN_ID
    end
  end
end
