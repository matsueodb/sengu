#
#== 地図表示用コントローラ
#
require 'open-uri'
class Templates::MapsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  #=== 地図の表示画面
  #
  # GET /maps/display
  #
  # 各地図モーダルにて表示する機能
  #link:../captures/templates/maps/display.png
  def display
    @map = Map.new(display_params)
    @map.uneditable = true
  end

  #=== 地図から位置情報検索画面
  #
  # POST /maps/display_search
  #
  # 各地図モーダルを表示して、位置情報を検索する画面
  #link:../captures/templates/maps/display_search.png
  def display_search
    @map = Map.new(display_search_params)
    @item_number = params[:item_number]
    render partial: "search_#{params[:map][:map_type]}"
  end

  #=== 住所から経度、緯度をセットする。
  #
  # POST /maps/search_address_location
  #
  # Ajax: 入力された住所情報から該当する経度、緯度情報を返し、フォームにセットする機能
  def search_address_location
    @latitude, @longitude = KokudoAddress.search_address_location(params)
    @uniq_id = params[:uniq_id]
  end

  #=== 都道府県のセレクトを変更したときに市を切り替える処理
  #
  # GET /maps/search_city_id_select
  #
  # Ajax: 都道府県のプルダウンを変更したときに、
  # 関連する市町村を取得して描画し直す処理
  def search_city_id_select
    @cities = KokudoCity.where("pref_id = ?", params[:pref_id])
    return render partial: "search_city_id_select", locals: {uniq_id: params[:uniq_id]}
  end

  #=== 国土地理院の画像がhttpsだと読み込めないので、本アクションからsend_dataする。
  #
  # GET /maps/load_content
  #
  # Ajax: httpsで国土地理院の地図を表示した場合に
  # 地図画像等が取得出来なくなるので、メソッド化して取得するように変更
  def load_content
    # 以下のアドレスにアクセスする場合には、.jsアクセスでくる。
    # IEの場合、JSでアクセスがブロックされるため
    # * #http://cyberjapandata.gsi.go.jp/cgi-bin/get-available-maps.php
    uri = open(params[:address])
    send_data(uri.read, type: uri.content_type)
  end

private

  #=== 地図表示時のparams
  def display_params
    params[:map].permit(:latitude, :longitude, :map_type)
  end

  #=== 地図表示時のparams
  def display_search_params
    params[:map].permit(:latitude, :longitude, :map_type, :element_id, :latitude_id, :longitude_id)
  end
end
