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

require 'spec_helper'

describe KokudoAddress do
  describe "association" do
    it {should belong_to(:city).class_name("KokudoCity")}
  end

  describe "scope" do
    describe "cities" do
      let(:city){create(:city_shimane)}
      let(:other_city){create(:city_tottori)}

      subject{KokudoAddress.cities(city)}

      before do
        (1..3).map do
          create(:kokudo_address, city_id: city.id)
          create(:kokudo_address, city_id: other_city.id)
        end
      end

      it "city_idが引数で渡したKokudoCityのIDと等しいレコードが取得されること" do
        expect(subject.to_a).to eq(KokudoAddress.where(city_id: city.id).to_a)
      end
    end
    
    describe "streets" do
      let(:keyword){"学園"}
      let(:addresses){(1..5).map{|n|create(:kokudo_address, street: "学園#{n}丁目")}}

      before do
        (1..5).map{|n|create(:kokudo_address, street: "松江学園#{n}丁目")}
      end

      subject{KokudoAddress.streets(keyword)}

      it "引数で渡した文字列に前方一致するKokudoAddressが返ること" do
        expect(subject).to eq(addresses)
      end
    end
  end

  describe "methods" do
    let(:pref){create(:kokudo_pref)}
    let(:city){create(:kokudo_city, pref_id: pref.id)}
    let(:other_pref){create(:kokudo_pref)}
    let(:other_city){create(:kokudo_city, pref_id: other_pref.id)}
    let(:address){"学園町"}

    describe "self.search_address_location" do
      context "params[:address]がある場合" do
        before do
          create(:kokudo_address, city_id: city.id, street: "西津田１丁目", latitude: 3.4, longitude: 4.3)
          create(:kokudo_address, city_id: other_city.id, street: address + "１丁目", latitude: 5.6, longitude: 6.5)
          create(:kokudo_address, city_id: city.id, street: address + "１丁目", latitude: 1.2, longitude: 2.1)
        end
        let(:params){{pref_id: pref.id, city_id: city.id, address: address}}
        subject{KokudoAddress.search_address_location(params)}

        it "pref_id=params[:pref_id]&&city_id=params[:city_id]で、streetがparams[:address]に前方一致する最初のレコードの経度、緯度が取得されること" do
          expect(subject).to eq(["1.2", "2.1"])
        end
      end

      context "params[:address]がない場合" do
        before do
          create(:kokudo_address, city_id: city.id, street: "西津田１丁目", latitude: 3.4, longitude: 4.3)
          create(:kokudo_address, city_id: other_city.id, street: address + "１丁目", latitude: 5.6, longitude: 6.5)
          create(:kokudo_address, city_id: city.id, street: address + "１丁目", latitude: 1.2, longitude: 2.1)
        end
        let(:params){{pref_id: pref.id, city_id: city.id}}
        subject{KokudoAddress.search_address_location(params)}

        it "pref_id=params[:pref_id]&&city_id=params[:city_id]に一致する最初のレコードの経度、緯度が取得されること" do
          expect(subject).to eq(["3.4", "4.3"])
        end
      end


    end
  end
end
