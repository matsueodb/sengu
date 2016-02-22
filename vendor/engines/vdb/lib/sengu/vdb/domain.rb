#
#== 語彙DBのドメイン情報を取得するためのクラス
#
# Sengu::VDB::Baseを継承している
module Sengu::VDB
  class Domain < ::Sengu::VDB::Base
    DOMAIN_ID = "domain"

    #
    #=== ドメインのIDを返す
    # 'domain'
    def self.domain_id
      DOMAIN_ID
    end

    #
    #=== 画面表示など、人がみてわかる名前を返す
    #
    def self.human_readable_name
      (Settings.vdb.domain_name.send(DOMAIN_ID) || "") rescue ""
    end
  end
end
