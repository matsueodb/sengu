# == Schema Information
#
# Table name: kokudo_cities
#
#  id      :integer          not null, primary key
#  name    :string(255)
#  pref_id :integer
#
#
#== 国土地理院の市町村マスタ
#
class KokudoCity < ActiveRecord::Base
  belongs_to :pref,     foreign_key: :pref_id, class_name: KokudoPref.name
  has_many :addresses, ->{order("id")},  foreign_key: :city_id, class_name: KokudoAddress.name
end
