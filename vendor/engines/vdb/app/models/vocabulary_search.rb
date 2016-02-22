#
#== 語彙データの検索を行うモデル
#
class VocabularySearch
  include ActiveModel::Model

  attr_accessor :name

  validates :name, presence: true

  #
  #=== 語彙データのID検索を行う
  #
  def self.find(attr)
    response = Sengu::VDB::Domain.find(attr[:name])
    response.find_code_list_with_getname
  end


  #
  #=== 語彙データの検索を行う
  #
  def search
    if valid?
      Sengu::VDB::Domain.search(self.name)
    else
      return false
    end

  end
end
