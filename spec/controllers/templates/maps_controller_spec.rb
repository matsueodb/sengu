require 'spec_helper'

describe Templates::MapsController do
  let(:section){create(:section)}
  let(:current_user){create(:section_manager_user, section_id: section.id)}
  let(:service){create(:service, section_id: section.id)}
  let(:template){create(:template, user_id: current_user.id, service_id: service.id)}
  
  describe "filter" do
    let(:filters){[:authenticate_user!]}
    controller do
      [
        :display, :display_search, :search_address_location, :search_city_id_select, :load_content
      ].each do |act|
        define_method(act) do
          render text: "ok"
        end
      end
    end

    before do
      @routes.draw do
        resources :anonymous, only: [] do
          collection do
            post :display_search # 住所検索地図表示
            get :display # 地図表示
            get :search_city_id_select # 市町村セレクトの都道府県きりかえ
            post :search_address_location # 住所検索
            get :load_content # 国土地理院の画像を表示するためのアクション
          end
        end
      end
    end

    describe "#authenticate_user!" do
      shared_examples_for "未ログイン時のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、ログイン画面が表示されること" do
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      shared_examples_for "ログイン時のアクセス制限" do |met, act|
        before{ login_user }
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          expect(response.body).to eq("ok")
        end
      end

      before do
        filters.reject{|f|f == :authenticate_user!}.each do |f|
          controller.stub(f)
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :display) {before{patch :display}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :display_search) {before{post :display_search}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :search_city_id_select) {before{get :search_city_id_select}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :search_address_location) {before{post :search_address_location}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :load_content) {before{get :load_content}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :display) {before{patch :display}}
        it_behaves_like("ログイン時のアクセス制限", :post, :display_search) {before{post :display_search}}
        it_behaves_like("ログイン時のアクセス制限", :get, :search_city_id_select) {before{get :search_city_id_select}}
        it_behaves_like("ログイン時のアクセス制限", :post, :search_address_location) {before{post :search_address_location}}
        it_behaves_like("ログイン時のアクセス制限", :get, :load_content) {before{get :load_content}}
      end
    end
  end

  describe "action" do
    before do
      login_user(current_user)
    end

    describe "GET display" do
      let(:map_params){
        {latitude: "35.442593", longitude: "133.066472", map_type: "kokudo"}.stringify_keys
      }
      subject{xhr :get, :display, map: map_params}

      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "displayがrenderされること" do
          expect(subject).to render_template("display")
        end

        context "@mapの検証" do
          it "params[:map]の値をもとにMapクラスのインスタンスがセットされること" do
            map = Map.new(map_params)
            Map.stub(:new).with(map_params){map}
            subject
            expect(assigns[:map]).to eq(map)
          end

          it "uneditable==trueであること" do
            subject
            expect(assigns[:map].uneditable).to be_true
          end
        end
      end
    end
    
    describe "POST display_search" do
      let(:el){create(:element_by_it_kokudo_location)}
      let(:map_params){
        {latitude: "35.442593", longitude: "133.066472", map_type: "kokudo_location", element_id: el.id.to_s}.stringify_keys
      }
      subject{xhr :post, :display_search, map: map_params, item_number: 1}

      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "search_{map_type}がrenderされること" do
          expect(subject).to render_template("_search_kokudo_location")
        end

        it "@item_numberにparams[:item_number]の値が入ること" do
          subject
          expect(assigns[:item_number]).to eq("1")
        end

        context "@mapの検証" do
          it "params[:map]の値をもとにMapクラスのインスタンスがセットされること" do
            map = Map.new(map_params)
            Map.stub(:new).with(map_params){map}
            subject
            expect(assigns[:map]).to eq(map)
          end
        end
      end
    end

    describe "POST search_address_location" do
      let(:keyword){"学園"}
      let(:latitude){"35.476"}
      let(:longitude){"133.066"}
      let(:city){create(:kokudo_city)}
      let(:address){create(:address_shimane, city_id: city.id, latitude: latitude, longitude: longitude)}

      before do
        address # let call
      end

      describe "正常系" do
        subject{xhr :post, :search_address_location, city_id: city.id, address: keyword, uniq_id: "100"}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "search_address_locationがrenderされること" do
          expect(subject).to render_template(:search_address_location)
        end

        it "@latitudeに検索した結果の緯度が入ること" do
          subject
          expect(assigns[:latitude]).to eq(address.latitude.to_s)
        end

        it "@longitudeに検索した結果の緯度が入ること" do
          subject
          expect(assigns[:longitude]).to eq(address.longitude.to_s)
        end

        it "@uniq_idにparams[:uniq_id]がセットされること" do
          subject
          expect(assigns[:uniq_id]).to eq("100")
        end
      end
    end

    describe "GET search_city_id_select" do
      let(:pref){create(:pref_shimane)}
      let(:cities){
        (1..5).map{|a|create(:kokudo_city, pref_id: pref.id)}
      }

      before do
        cities # let_call
        # 以下は取得されない市町村
        pr = create(:pref_tottori)
        (1..5).map{|a|create(:kokudo_city, pref_id: pr.id)}
      end

      describe "正常系" do
        subject{xhr :get, :search_city_id_select, pref_id: pref.id, uniq_id: "100"}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "search_city_id_selectがrenderされること" do
          expect(subject).to render_template(:_search_city_id_select)
        end

        it "@citiesにparams[:pref_id]のpref_idをもつKokudoCityインスタンス配列がセットされること" do
          subject
          expect(assigns[:cities]).to match_array(cities)
        end
      end
    end

    describe "GET load_content" do
      let(:c_type){"image/png"}
      let(:content){"image!"}
      let(:address){"http://rubyonrails.org/images/rails.png"}
      
      describe "正常系" do
        subject{get :load_content, address: address}

        it "params[:address]のアドレスを開き、コンテントタイプをセットしてsend_dataが呼ばれること" do
          uri = double(:url, content_type: c_type, read: content)
          controller.stub(:open){uri}
          controller.should_receive(:send_data).with(uri.read, type: c_type)
          controller.should_receive(:render)
          subject
        end
      end
    end

    describe "private" do
      describe "display_params" do
        let(:valid_params){
          {latitude: "35.442593", longitude: "133.066472", map_type: "kokudo"}.stringify_keys
        }
        let(:invalid_params){valid_params.merge(element_id: 500)}
        subject{controller.send(:display_params)}
        before do
          controller.params[:map] = invalid_params
        end

        it "valid_paramsのみが残ること" do
          expect(subject).to eq(valid_params.stringify_keys)
        end
      end

      describe "display_search_params" do
        let(:valid_params){
          {latitude: "35.442593", longitude: "133.066472", map_type: "kokudo", element_id: 500}.stringify_keys
        }
        let(:invalid_params){valid_params.merge(uneditable: true)}
        subject{controller.send(:display_search_params)}
        before do
          controller.params[:map] = invalid_params
        end

        it "valid_paramsのみが残ること" do
          expect(subject).to eq(valid_params.stringify_keys)
        end
      end
    end
  end
end
