require 'spec_helper'

describe ServicesController do
  describe "フィルタ" do
    describe "authenticate_user!" do
      before do
        controller.stub(:set_service).and_return(true)
        controller.stub(:section_check).and_return(true)
        controller.stub(:destroy_check).and_return(true)
      end

      shared_examples_for "未ログイン時のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、ログイン画面が表示されること" do
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      shared_examples_for "ログイン時のアクセス制限"  do |met, act|
        before{ login_user }
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          (response.body == "ok").should be_true
        end
      end

      controller do
        %w(index new edit create update destroy template_list search).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous do
            collection do
              post :search
            end

            member do
              get :template_list
            end
          end
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :template_list) {before{get :template_list, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :search) {before{post :search}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :template_list) {before{get :template_list, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :search) {before{post :search}}
      end
    end

    describe "#manager_required" do
      before do
        controller.stub(:authenticate_user!).and_return(true)
        controller.stub(:section_check).and_return(true)
        controller.stub(:set_service).and_return(true)
        controller.stub(:destroy_check).and_return(true)
      end

      shared_examples_for "データ登録者がアクセスした場合のアクセス制限" do |met, act|
        before{ login_user(create(:editor_user)) }
        it "#{met.upcase} #{act}にアクセスしたときトップ画面が表示されること" do
          expect(response).to redirect_to(root_path)
        end
      end

      shared_examples_for "管理者がアクセスした場合のアクセス制限"  do |met, act|
        before{ login_user(create(:super_user)) }
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          (response.body == "ok").should be_true
        end
      end

      shared_examples_for "所属管理者がアクセスした場合のアクセス制限"  do |met, act|
        before{ login_user(create(:section_manager_user)) }
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          (response.body == "ok").should be_true
        end
      end

      controller do
        %w(new edit create update destroy).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous, except: [:index, :show]
        end
      end

      context "データ登録者の場合" do
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
      end

      context "管理者の場合" do
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
      end

      context "所属管理者の場合" do
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
      end
    end

    describe "#section_check" do
      before do
        controller.stub(:authenticate_user!).and_return(true)
        controller.stub(:destroy_check).and_return(true)
      end

      shared_examples_for "違う所属のユーザがアクセスした場合のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたときトップ画面が表示されること" do
          expect(response).to redirect_to(services_path)
        end
      end

      controller do
        %w(edit update destroy).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        login_user
        @service = create(:service, section_id: 99999999)
        @routes.draw do
          resources :anonymous, only: [:edit, :update, :destroy]
        end
      end

      it_behaves_like("違う所属のユーザがアクセスした場合のアクセス制限", :get, :edit) {before{get :edit, id: @service.id}}
      it_behaves_like("違う所属のユーザがアクセスした場合のアクセス制限", :patch, :update) {before{patch :update, id: @service.id}}
      it_behaves_like("違う所属のユーザがアクセスした場合のアクセス制限", :delete, :destroy) {before{delete :destroy, id: @service.id}}
    end

    describe "set_service" do
      shared_examples_for "インスタンス変数へのセット" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@serivceに正しい値が設定されること" do
          expect(assigns[:service]).to eq(@serivce)
        end
      end

      controller do
        %w(index new edit create update destroy template_list).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous do
            member do
              get :template_list
            end
          end
        end

        login_user
        @serivce = create(:service)
      end

      it_behaves_like("インスタンス変数へのセット", :get, :edit) {before{get :edit, id: @serivce.id}}
      it_behaves_like("インスタンス変数へのセット", :patch, :update) {before{patch :update, id: @serivce.id}}
      it_behaves_like("インスタンス変数へのセット", :delete, :destroy) {before{delete :destroy, id: @serivce.id}}
      it_behaves_like("インスタンス変数へのセット", :get, :template_list) {before{get :template_list, id: @serivce.id}}
    end
  end

  describe "アクション" do
    let!(:user) { login_user }

    describe "GET index" do
      context "HTMLフォーマットでのアクセスの場合" do
        let(:service) { create(:service, section_id: user.section_id) }
        let(:services) { 3.times.map{ create(:service, section_id: user.section_id) } }

        before do
          get :index, id: service.id
        end

        it "@servicesに正しい値を設定していること" do
          expect(assigns[:services].to_a).to match_array(Service.displayables(user).to_a)
        end

        it "params[:id]に指定されているサービスを@serviceに設定していること" do
          expect(assigns[:service]).to eq(service)
        end
      end
    end

    describe "GET new" do
      before do
        get :new
      end

      it "新しいServiceインスタンスを作成していること" do
        expect(assigns[:service]).to be_a_new(Service)
      end

      it "newをrenderしていること" do
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      let!(:service) { create(:service, section_id: user.section_id) }

      subject{ get :edit, id: service.id}

      it "editをrenderしていること" do
        expect(subject).to render_template(:edit)
      end
    end

    describe "POST create" do
      let(:service_params) { build(:service).attributes }

      describe "正常系" do
        before do
          post :create, service: service_params
        end

        it "@serviceが保存されていること" do
          expect(assigns[:service]).to be_persisted
        end

        it "所属IDが正しくセットされていること" do
          expect(assigns[:service].section_id).to eq(user.section_id)
        end

        it "正しくリダイレクトすること" do
          expect(subject).to redirect_to(services_path(id: assigns[:service].id))
        end

        it "flash[:notice]が正しくセットされていること" do
          expect(flash[:notice]).to eq(I18n.t('services.create.success'))
        end
      end

      describe "異常系" do
        context "saveに失敗した場合" do
          before do
            Service.any_instance.stub(:save).and_return(false)
            post :create, service: service_params
          end

          it "保存されていないこと" do
            expect(assigns[:service]).to be_a_new(Service)
          end

          it "newをrenderしていること" do
            expect(response).to render_template(:new)
          end
        end
      end
    end

    describe "PUT update" do
      let(:service) { create(:service, section_id: user.section_id) }
      let(:service_params) { service.attributes.merge(name: 'new-name') }

      describe "正常系" do
        before do
          patch :update, id: service.id, service: service_params
        end

        it "@serviceが更新されていること" do
          expect(assigns[:service]).to eq(Service.new(service_params))
        end

        it "正しくリダイレクトすること" do
          expect(subject).to redirect_to(services_path(id: assigns[:service].id))
        end

        it "flash[:notice]が正しくセットされていること" do
          expect(flash[:notice]).to eq(I18n.t('services.update.success'))
        end
      end

      describe "異常系" do
        context "saveに失敗した場合" do
          before do
            Service.any_instance.stub(:update).and_return(false)
            patch :update, id: service.id, service: service_params
          end

          it "editをrenderしていること" do
            expect(response).to render_template(:edit)
          end
        end
      end
    end

    describe "DELETE destroy" do
      let!(:service) { create(:service, section_id: user.section_id) }

      subject{ delete :destroy, id: service.id }

      it "Serviceの数が減っていること" do
        expect{subject}.to change(Service, :count).by(-1)
      end

      it "正しくリダイレクトすること" do
        expect(subject).to redirect_to(services_path)
      end
    end

    describe "GET template_list" do
      before do
        service = create(:service, section_id: user.section_id)
        other_service = create(:service, section_id: user.section_id)
        @templates = create_list(:template, 5, service_id: service.id, user_id: user.id)
        create_list(:template, 5, service_id: other_service.id, user_id: user.id)

        get :template_list, id: service.id, format: :js
      end

      it "サービスに関連するテンプレートを@templatesに設定していること" do
        expect(assigns[:templates]).to match_array(@templates)
      end
    end

    describe "POST search" do
      before do
        @services = []
        @services << create(:service, name: '県のサービス', description: '県が行なっている観光ーサービスです', section_id: user.section_id)
        @services << create(:service, name: '観光のサービス', description: '施設のサービスです', section_id: user.section_id)
        create_list(:service, 10, name: '防災サービス', description: '防災のサービスです')
      end

      context "サービスがヒットする場合" do
        let(:keyword) { '観光' }

        before do
          post :search, service_search: {keyword: keyword}, format: :js
        end

        it "名前と詳細に一致するサービスを返すこと" do
          expect(assigns[:services]).to match_array(@services)
        end

        it "searchをrenderしていること" do
          expect(response).to render_template(:search)
        end
      end

      context "サービスがヒットしない場合" do
        let(:keyword) { '人' }

        before do
          post :search, service_search: {keyword: keyword}, format: :js
        end

        it "searchをrenderしていること" do
          expect(response).to render_template(:search)
        end
      end
    end
  end
end
