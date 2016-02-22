# == Schema Information
#
# Table name: kokudo_prefs
#
#  id   :integer          not null, primary key
#  name :string(255)
#

#
#== 国土地理院の都道府県マスタ
#
class KokudoPref < ActiveRecord::Base
  has_many :cities, ->{order("id")}, foreign_key: :pref_id, class_name: KokudoCity.name
end
