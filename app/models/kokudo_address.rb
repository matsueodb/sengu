# == Schema Information
#
# Table name: kokudo_addresses
#
#  id        :integer          not null, primary key
#  street    :string(255)
#  city_id   :integer
#  latitude  :float
#  longitude :float
#
#
#== 国土地理院の住所、位置情報マスタ
#
class KokudoAddress < ActiveRecord::Base
  belongs_to :city, foreign_key: :city_id, class_name: KokudoCity.name

  scope :cities,  -> (city){where("city_id = ?", city.id)}
  scope :streets, -> (street){where("street LIKE ?", "#{street}%")}

  #=== 住所検索
  #==== 引数
  # * params - パラメータ
  # * - city_id - 市町村ID
  # * - address - 住所名
  #==== 戻り値
  # String(緯度), String(経度)
  def self.search_address_location(params)
    city = KokudoCity.find(params[:city_id])

    addresses = KokudoAddress.cities(city)
    if params[:address]
      addresses = addresses.streets(params[:address])
    end

    if address = addresses.first
      return address.latitude.to_s, address.longitude.to_s
    else
      return nil, nil
    end
  end
end
