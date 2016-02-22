#
#== 各マップAPIで使用するクラス
#
class Map
  include ActiveModel::Model

  attr_accessor :latitude, :longitude, :map_type, :element_id, :uneditable, :longitude_id, :latitude_id

  validates :latitude, presence: true
  validates :longitude, presence: true

  #
  #=== マーカータイトル
  #==== 戻り値
  # * String
  def title
    str = "#{I18n.t("activerecord.attributes.map.title.latitude")}: #{self.latitude}"
    str += ", #{I18n.t("activerecord.attributes.map.title.longitude")}: #{self.longitude}"
    str
  end

  #
  #=== マーカー位置の変更等が可能か？
  #==== 戻り値
  # * true: 変更可能, false: 変更不可
  def editable?
    !self.uneditable
  end
end
