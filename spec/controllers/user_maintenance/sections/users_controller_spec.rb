require 'spec_helper'

describe UserMaintenance::Sections::UsersController do
  describe "filter" do
    let(:section){create(:section)}
    let(:user){create(:editor_user, section_id: section.id)}
    let(:filters){[
      :authenticate_user!, :set_section, :section_accessible_check, :set_breadcrumbs,
      :set_user, :set_index_breadcrumbs, :set_user_list,
      :set_form_assigns, :accessible_check, :destroyable_check, :inherit_data_accessible_check,
      :creatable_check
    ]}
    controller do
      %w(index show new edit create update destroy inherit_data inherit_data_form edit_password update_password).each do |act|
        define_method(act) do
          render text: "ok"
        end
      end
    end

    before do
      @routes.draw do
        devise_for :users, {
          controllers: {registrations: "users"},
          path_names: {sign_up: :new}
        }

        devise_scope :anonymous do
          resources :anonymous do
            collection do
              get :inherit_data_form
              post :inherit_data
              get :edit_password
              patch :update_password
            end
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
        it_behaves_like("未ログイン時のアクセス制限", :get, :index) {before{get :index, section_id: section.id}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :new) {before{get :new, section_id: section.id}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create, section_id: section.id}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :inherit_data_form) {before{get :inherit_data_form, section_id: section.id}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :inherit_data) {before{post :inherit_data, section_id: section.id}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit_password) {before{get :edit_password, section_id: section.id}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update_password) {before{patch :update_password, section_id: section.id}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :index) {before{get :index, section_id: section.id}}
        it_behaves_like("ログイン時のアクセス制限", :get, :new) {before{get :new, section_id: section.id}}
        it_behaves_like("ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create, section_id: section.id}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
        it_behaves_like("ログイン時のアクセス制限", :get, :inherit_data_form) {before{get :inherit_data_form, section_id: section.id}}
        it_behaves_like("ログイン時のアクセス制限", :post, :inherit_data) {before{post :inherit_data, section_id: section.id}}
        it_behaves_like("ログイン時のアクセス制限", :get, :edit_password) {before{get :edit_password, section_id: section.id}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update_password) {before{patch :update_password, section_id: section.id}}
      end
    end

    describe "#set_section" do
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@sectionがセットされていること" do
          expect(assigns[:section]).to eq(section)
        end
      end

      before do
        filters.reject{|f|f == :set_section}.each do |f|
          controller.stub(f)
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :index) {before{get :index, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :new) {before{get :new, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :show) {before{get :show, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :post, :create) {before{post :create, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :inherit_data_form) {before{get :inherit_data_form, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :post, :inherit_data) {before{post :inherit_data, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit_password) {before{get :edit_password, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update_password) {before{patch :update_password, section_id: section.id}}
    end

    describe "#set_breadcrumbs" do
      shared_examples_for "パンくずの確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@breadcrumbsに所属管理画面へのパンくずががセットされていること" do
          path = sections_path
          name = I18n.t("user_maintenance.sections.index.title")
          expect(assigns[:breadcrumbs].any?{|a|a.path == path && a.name == name}).to be_true
        end

        it "#{met.upcase} #{act}にアクセスしたとき、@breadcrumbsに所属詳細画面へのパンくずががセットされていること" do
          path = section_path(section.id)
          name = I18n.t("user_maintenance.sections.show.title", section_name: section.name)
          expect(assigns[:breadcrumbs].any?{|a|a.path == path && a.name == name}).to be_true
        end
      end

      before do
        login_user(user)
        filters.reject{|f|f == :set_breadcrumbs}.each do |f|
          controller.stub(f)
        end
        sec = section
        controller.instance_eval do
          @section = sec
        end
      end

      it_behaves_like("パンくずの確認", :get, :index) {before{get :index, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :new) {before{get :new, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :show) {before{get :show, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :create) {before{post :create, section_id: section.id}}
      it_behaves_like("パンくずの確認", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :inherit_data_form) {before{get :inherit_data_form, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :inherit_data) {before{post :inherit_data, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :edit_password) {before{get :edit_password, section_id: section.id}}
      it_behaves_like("パンくずの確認", :patch, :update_password) {before{patch :update_password, section_id: section.id}}
    end

    describe "#section_accessible_check" do
      shared_examples_for("アクセス権がない場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、トップページ画面が表示されること" do
          expect(subject).to redirect_to(root_path)
        end
      end

      shared_examples_for("アクセス権がある場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        login_user(user)
        filters.reject{|f|f == :section_accessible_check}.each do |f|
          controller.stub(f)
        end
        sec = section
        controller.instance_eval do
          @section = sec
        end
      end

      context "ログインユーザが管理者の場合" do
        before{login_user(create(:super_user))}
        
        it_behaves_like("アクセス権がある場合の処理", :get, :index) {subject{get :index, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :new) {subject{get :new, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :show) {subject{get :show, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :edit) {subject{get :edit, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :create) {subject{post :create, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :patch, :update) {subject{patch :update, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {subject{delete :destroy, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :inherit_data_form) {subject{get :inherit_data_form, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :inherit_data) {subject{post :inherit_data, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :edit_password) {before{get :edit_password, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :patch, :update_password) {before{patch :update_password, section_id: section.id}}
      end

      context "ログインユーザが管理者では無い場合" do
        before do
          login_user(user)
        end

        context "ログインユーザが所属の管理者の場合" do
          before do
            user.update!(section_id: section.id, authority: User.authorities[:section_manager])
          end

          it_behaves_like("アクセス権がある場合の処理", :get, :index) {subject{get :index, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :new) {subject{get :new, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :show) {subject{get :show, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :edit) {subject{get :edit, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :create) {subject{post :create, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :patch, :update) {subject{patch :update, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {subject{delete :destroy, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :inherit_data_form) {subject{get :inherit_data_form, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :inherit_data) {subject{post :inherit_data, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :edit_password) {before{get :edit_password, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :patch, :update_password) {before{patch :update_password, section_id: section.id}}
        end

        context "ログインユーザが所属の管理者では無い場合" do
          context "ログインユーザが所属のメンバーである場合" do
            it_behaves_like("アクセス権がある場合の処理", :get, :index) {subject{get :index, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :get, :new) {subject{get :new, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :get, :show) {subject{get :show, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :get, :edit) {subject{get :edit, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :post, :create) {subject{post :create, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :patch, :update) {subject{patch :update, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {subject{delete :destroy, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :get, :inherit_data_form) {subject{get :inherit_data_form, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :post, :inherit_data) {subject{post :inherit_data, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :get, :edit_password) {before{get :edit_password, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :patch, :update_password) {before{patch :update_password, section_id: section.id}}
          end

          context "ログインユーザが所属のメンバーでない場合" do
            before do
              user.update!(section_id: 0)
            end
            
            it_behaves_like("アクセス権がない場合の処理", :get, :index) {subject{get :index, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :get, :new) {subject{get :new, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :get, :show) {subject{get :show, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :get, :edit) {subject{get :edit, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :post, :create) {subject{post :create, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :patch, :update) {subject{patch :update, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :delete, :destroy) {subject{delete :destroy, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :get, :inherit_data_form) {subject{get :inherit_data_form, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :post, :inherit_data) {subject{post :inherit_data, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :get, :edit_password) {before{get :edit_password, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :patch, :update_password) {before{patch :update_password, section_id: section.id}}
          end
        end
      end
    end

    describe "#set_user" do
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@userがセットされていること" do
          expect(assigns[:user]).to eq(user)
        end
      end

      before do
        login_user(user)
        filters.reject{|f|f == :set_user}.each do |f|
          controller.stub(f)
        end
        sec = section
        controller.instance_eval do
          @section = sec
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :edit){before{get :edit, id: user.id, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update){before{patch :update, id: user.id, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy){before{delete :destroy, id: user.id, section_id: section.id}}
    end

    describe "#set_user_list" do
      let(:users){(1..21).map{create(:editor_user, section_id: section.id)}}
      
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@userがページネーションされてセットされていること" do
          us = [user, users].flatten.sort_by(&:id)
          expect(assigns[:users]).to match_array(us[10, 10])
        end
      end

      before do
        login_user(user)
        filters.reject{|f|f == :set_user_list}.each do |f|
          controller.stub(f)
        end
        sec = section
        controller.instance_eval do
          @section = sec
        end

        users
        # 取得されないユーザを作成
        10.times{create(:editor_user, section_id: 0)}
      end

      it_behaves_like("インスタンス変数の確認", :get, :index){before{get :index, page: 2, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :new){before{get :new, page: 2, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit){before{get :edit, id: user.id, page: 2, section_id: section.id}}
    end

    describe "#set_index_breadcrumbs" do
      shared_examples_for "パンくずの確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@breadcrumbsにユーザ一覧画面へのパンくずががセットされていること" do
          path = section_users_path(section_id: section.id)
          name = I18n.t("user_maintenance.sections.users.index.title", section_name: section.name)
          expect(assigns[:breadcrumbs].any?{|a|a.path == path && a.name == name}).to be_true
        end
      end

      before do
        login_user(user)
        filters.reject{|f|f == :set_index_breadcrumbs}.each do |f|
          controller.stub(f)
        end
        sec = section
        controller.instance_eval do
          @section = sec
        end
      end

      it_behaves_like("パンくずの確認", :get, :new) {before{get :new, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :show) {before{get :show, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :create) {before{post :create, section_id: section.id}}
      it_behaves_like("パンくずの確認", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :inherit_data_form) {before{get :inherit_data_form, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :inherit_data) {before{post :inherit_data, section_id: section.id}}
    end

    describe "#set_form_assigns" do
      let(:sections){(1..5).map{create(:section)}.sort_by(&:id)}
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@sectionsがセットされていること" do
          se = [section, sections].flatten
          expect(assigns[:sections]).to match_array(se)
        end
      end

      before do
        login_user(user)
        filters.reject{|f|f == :set_form_assigns}.each do |f|
          controller.stub(f)
        end
        sec = section
        controller.instance_eval do
          @section = sec
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :new){before{get :new, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit){before{get :edit, id: user.id, section_id: section.id}}
    end

    describe "#accessible_check" do
      let(:alert){I18n.t("alerts.can_not_access")}
      let(:manager){create(:section_manager_user, section_id: section.id)}

      shared_examples_for("アクセス権がない場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、ユーザ一覧画面が表示されること" do
          expect(subject).to redirect_to(section_users_path(section_id: section.id))
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          expect(flash[:alert]).to eq(alert)
        end
      end

      shared_examples_for("アクセス権がある場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        filters.reject{|f|f == :accessible_check}.each do |f|
          controller.stub(f)
        end
        sec, us = section, manager
        controller.instance_eval do
          @section = sec
          @user = us
        end
      end

      context "ログインユーザが管理者の場合" do
        before{controller.stub(:current_user){create(:super_user)}}

        it_behaves_like("アクセス権がある場合の処理", :get, :show){before{get :show, id: user.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :edit){before{get :edit, id: user.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :patch, :update){before{patch :update, id: user.id, section_id: section.id}}
      end

      context "ログインユーザが所属管理者の場合" do
        context "選択した所属の所属管理者の場合" do
          before{controller.stub(:current_user){create(:section_manager_user, section_id: section.id)}}

          it_behaves_like("アクセス権がある場合の処理", :get, :show){before{get :show, id: user.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :edit){before{get :edit, id: user.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :patch, :update){before{patch :update, id: user.id, section_id: section.id}}
        end

        context "選択した所属以外の所属管理者の場合" do
          before{controller.stub(:current_user){create(:section_manager_user, section_id: create(:section).id)}}

          it_behaves_like("アクセス権がない場合の処理", :get, :show){before{get :show, id: user.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :get, :edit){before{get :edit, id: user.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :patch, :update){before{patch :update, id: user.id, section_id: section.id}}
        end
      end

      context "ログインユーザがデータ登録者の場合" do
        context "ログインユーザと選択したユーザが等しい場合" do
          before do
            manager.update!(authority: User.authorities[:editor])
            controller.stub(:current_user){manager}
          end

          it_behaves_like("アクセス権がある場合の処理", :get, :show){before{get :show, id: user.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :edit){before{get :edit, id: user.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :patch, :update){before{patch :update, id: user.id, section_id: section.id}}
        end

        context "ログインユーザと選択したユーザが等しくない場合" do
          before do
            controller.stub(:current_user){create(:editor_user)}
          end

          it_behaves_like("アクセス権がない場合の処理", :get, :show){before{get :show, id: user.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :get, :edit){before{get :edit, id: user.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :patch, :update){before{patch :update, id: user.id, section_id: section.id}}
        end
      end
    end

    describe "#destroyable_check" do
      let(:alert){I18n.t("alerts.can_not_access")}
      let(:manager){create(:section_manager_user, section_id: section.id)}
      shared_examples_for("アクセス権がない場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、ユーザ一覧画面が表示されること" do
          expect(subject).to redirect_to(section_users_path(section_id: section.id))
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          expect(flash[:alert]).to eq(alert)
        end
      end

      shared_examples_for("アクセス権がある場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        login_user(user)
        filters.reject{|f|f == :destroyable_check}.each do |f|
          controller.stub(f)
        end
        sec = section
        sec, us = section, manager
        controller.instance_eval do
          @section = sec
          @user = us
        end
      end

      context "ログインユーザが管理者の場合" do
        before{controller.stub(:current_user){create(:super_user)}}

        it_behaves_like("アクセス権がある場合の処理", :delete, :destroy){before{delete :destroy, id: user.id, section_id: section.id}}
      end

      context "ログインユーザが所属管理者の場合" do
        context "選択した所属の所属管理者の場合" do
          before{controller.stub(:current_user){create(:section_manager_user, section_id: section.id)}}

          it_behaves_like("アクセス権がある場合の処理", :delete, :destroy){before{delete :destroy, id: user.id, section_id: section.id}}
        end

        context "選択した所属以外の所属管理者の場合" do
          before{controller.stub(:current_user){create(:section_manager_user, section_id: create(:section).id)}}

          it_behaves_like("アクセス権がない場合の処理", :delete, :destroy){before{delete :destroy, id: user.id, section_id: section.id}}
        end
      end

      context "ログインユーザがデータ登録者の場合" do
        before{controller.stub(:current_user){create(:editor_user, section_id: section.id)}}
        it_behaves_like("アクセス権がない場合の処理", :delete, :destroy){before{delete :destroy, id: user.id, section_id: section.id}}
      end
    end
    
    describe "#inherit_data_accessible_check" do
      let(:alert){I18n.t("alerts.can_not_access")}
      shared_examples_for("アクセス権がない場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、ユーザ一覧画面が表示されること" do
          expect(subject).to redirect_to(section_users_path(section_id: section.id))
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          expect(flash[:alert]).to eq(alert)
        end
      end

      shared_examples_for("アクセス権がある場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        login_user(user)
        filters.reject{|f|f == :inherit_data_accessible_check}.each do |f|
          controller.stub(f)
        end
        sec = section
        controller.instance_eval do
          @section = sec
        end
      end
      
      context "ログインユーザが管理者の場合" do
        before{controller.stub(:current_user){create(:super_user)}}

        it_behaves_like("アクセス権がある場合の処理", :get, :inherit_data_form){before{get :inherit_data_form, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :inherit_data){before{post :inherit_data, section_id: section.id}}
      end

      context "ログインユーザが所属管理者の場合" do
        context "選択した所属の所属管理者の場合" do
          before{controller.stub(:current_user){create(:section_manager_user, section_id: section.id)}}

          it_behaves_like("アクセス権がある場合の処理", :get, :inherit_data_form){before{get :inherit_data_form, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :inherit_data){before{post :inherit_data, section_id: section.id}}
        end

        context "選択した所属以外の所属管理者の場合" do
          before{controller.stub(:current_user){create(:section_manager_user, section_id: create(:section).id)}}

          it_behaves_like("アクセス権がない場合の処理", :get, :inherit_data_form){before{get :inherit_data_form, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :post, :inherit_data){before{post :inherit_data, section_id: section.id}}
        end
      end

      context "ログインユーザがデータ登録者の場合" do
        before{controller.stub(:current_user){create(:editor_user, section_id: section.id)}}
        it_behaves_like("アクセス権がない場合の処理", :get, :inherit_data_form){before{get :inherit_data_form, section_id: section.id}}
        it_behaves_like("アクセス権がない場合の処理", :post, :inherit_data){before{post :inherit_data, section_id: section.id}}
      end
    end

    describe "#creatable_check" do
      let(:alert){I18n.t("alerts.can_not_create")}

      shared_examples_for("アクセス権がない場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、所属一覧画面が表示されること" do
          expect(subject).to redirect_to(sections_path)
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          expect(flash[:alert]).to eq(alert)
        end
      end

      shared_examples_for("アクセス権がある場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        filters.reject{|f|f == :creatable_check}.each do |f|
          controller.stub(f)
        end
        sec = section
        controller.instance_eval do
          @section = sec
        end
      end

      context "ログインユーザが管理者の場合" do
        before{controller.stub(:current_user){create(:super_user)}}

        it_behaves_like("アクセス権がある場合の処理", :get, :new){before{get :new, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :create){before{post :create, section_id: section.id}}
      end

      context "ログインユーザが所属管理者の場合" do
        context "選択した所属の所属管理者の場合" do
          before{controller.stub(:current_user){create(:section_manager_user, section_id: section.id)}}

          it_behaves_like("アクセス権がある場合の処理", :get, :new){before{get :new, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :create){before{post :create, section_id: section.id}}
        end

        context "選択した所属以外の所属管理者の場合" do
          before{controller.stub(:current_user){create(:section_manager_user, section_id: create(:section).id)}}

          it_behaves_like("アクセス権がない場合の処理", :get, :new){before{get :new, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :post, :create){before{post :create, section_id: section.id}}
        end
      end

      context "ログインユーザがデータ登録者の場合" do
        before do
          controller.stub(:current_user){create(:editor_user, section_id: section.id)}
        end

        it_behaves_like("アクセス権がない場合の処理", :get, :new){before{get :new, section_id: section.id}}
        it_behaves_like("アクセス権がない場合の処理", :post, :create){before{post :create, section_id: section.id}}
      end
    end
  end

  describe "action" do
    let(:section){create(:section)}
    let(:current_user){create(:super_user, section_id: section.id)}
    before do
      login_user(current_user)
    end

    describe "GET index" do
      before do
        current_user
      end

      describe "正常系" do
        subject{get :index, section_id: section.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        context "通常のアクセスの場合" do
          it "indexがrenderされること" do
            expect(subject).to render_template("index")
          end
        end

        context "Ajaxのアクセスの場合" do
          subject{xhr :get, :index, section_id: section.id}

          it "_listがrenderされること" do
            expect(subject).to render_template("_list")
          end
        end
      end
    end

    describe "GET new" do
      describe "正常系" do
        subject{get :new, section_id: section.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "@userがUserクラスの新規インスタンスであること" do
          subject
          expect(assigns[:user]).to be_a_new(User)
        end
      end
    end

    describe "POST create" do
      context "正常系" do
        let(:user_params){
          {
            name: "松江 太郎", login: "user0001",
            password: "password", password_confirmation: "password",
            remarks: "このシステムの管理者です。", authority: User.authorities[:admin],
            section_id: create(:section).id
          }
        }
        subject{post :create, user: user_params, section_id: section.id}

        context "バリデーションに成功した場合" do
          it "Userレコードが追加されること" do
            expect{subject}.to change(User, :count).by(1)
          end

          it "indexにリダイレクトすること" do
            expect(subject).to redirect_to section_users_path(section_id: section.id)
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("devise.users.user.signed_up")
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      context "異常系" do
        let(:user_params){
          {
            name: "松江 太郎", login: "",
            password: "password", password_confirmation: "password",
            remarks: "このシステムの管理者です。", authority: User.authorities[:admin]
          }
        }
        subject{post :create, user: user_params, section_id: section.id}

        context "バリデーションに失敗した場合" do
          it "Userレコードが追加されないこと" do
            expect{subject}.to change(User, :count).by(0)
          end

          it "set_user_listが呼ばれること" do
            controller.should_receive(:set_user_list)
            subject
          end

          it "newがrenderされること" do
            expect(subject).to render_template("new")
          end

          it "set_form_assignsが呼ばれること" do
            controller.should_receive(:set_form_assigns)
            subject
          end
        end
      end
    end

    describe "GET edit" do
      subject{get :edit, id: current_user.id, section_id: section.id}

      it "200が返ること" do
        expect(subject).to be_success
      end

      it "editがrenderされること" do
        expect(subject).to render_template("edit")
      end
    end

    describe "PATCH update" do
      context "正常系" do
        let(:user_params){
          {
            name: "松江 太郎",
            password: "password1", password_confirmation: "password1",
            remarks: "このシステムの管理者です。", authority: User.authorities[:admin],
            section_id: create(:section).id
          }
        }
        
        subject{patch :update, id: current_user.id, user: user_params, section_id: section.id}
        context "バリデーションに成功した場合" do
          it "indexにリダイレクトすること" do
            expect(subject).to redirect_to section_users_path(section_id: section.id)
          end

          it "ユーザが更新されること" do
            subject
            expect(User.find(current_user.id)).to eq(User.new(user_params.merge(id: current_user.id, login: current_user.login)))
          end


          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("devise.users.user.updated")
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      context "異常系" do
        let(:user_params){
          {
            name: "松江 太郎",
            password: "password", password_confirmation: "password2",
            remarks: "このシステムの管理者です。", authority: User.authorities[:admin]
          }
        }

        subject{patch :update, id: current_user.id, user: user_params, section_id: section.id}
        context "バリデーションに失敗した場合" do
          it "set_user_listが呼ばれること" do
            controller.should_receive(:set_user_list)
            subject
          end

          it "editがrenderされること" do
            expect(subject).to render_template("edit")
          end

          it "set_form_assignsが呼ばれること" do
            controller.should_receive(:set_form_assigns)
            subject
          end
        end
      end
    end

    describe "DELETE destroy" do
      subject{delete :destroy, id: current_user.id, section_id: section.id}

      describe "正常系" do
        before do
          User.any_instance.stub(:destroyable?){true}
        end
        
        it "@user.destroyが呼ばれること" do
          User.any_instance.should_receive(:destroy)
          subject
        end

        it "Userレコードが１件削除されること" do
          expect{subject}.to change(User, :count).by(-1)
        end

        it "flash[:notice]がセットされること" do
          subject
          expect(flash[:notice]).to eq(I18n.t("user_maintenance.sections.users.destroy.complete"))
        end

        context "ログイン中のユーザを削除した場合" do
          it "ログイン画面に遷移すること" do
            expect(subject).to redirect_to(new_user_session_path)
          end
        end

        context "ログイン中のユーザ以外を削除した場合" do
          subject{delete :destroy, id: create(:editor_user, section_id: section.id).id, section_id: section.id}
          
          it "indexへリダイレクトすること" do
            expect(subject).to redirect_to section_users_path(section_id: section.id)
          end
        end
      end

      describe "異常系" do
        context "選択したユーザがデータを持っている場合" do
          before do
            create(:template_record, user_id: current_user.id, template: create(:template))
          end

          it "indexにリダイレクトすること" do
            expect(subject).to redirect_to section_users_path(section_id: section.id)
          end

          it "flash[:alert]がセットされること" do
            subject
            msg = I18n.t("user_maintenance.sections.users.destroy.failed_has_rdf_data")
            expect(flash[:alert]).to eq(msg)
          end
        end
      end
    end

    describe "GET inherit_data_form" do
      before do
        10.times{create(:editor_user, section_id: 0)}
      end

      subject{get :inherit_data_form, section_id: section.id}

      it "200が返ること" do
        expect(subject).to be_success
      end

      it "inherit_data_formがrenderされること" do
        expect(subject).to render_template(:inherit_data_form)
      end

      context "@usersの検証" do
        it "所属内のUserが全件取得されていること" do
          subject
          expect(assigns[:users]).to match_array(User.where(section_id: section.id))
        end
      end
    end

    describe "POST inherit_data" do
      let(:to_user){create(:editor_user, section_id: section.id)}
      let(:from_user){create(:editor_user, section_id: section.id)}
      subject{post :inherit_data, to_id: to_user.id, from_id: from_user.id, section_id: section.id}

      describe "正常系" do
        it "flash[:notice]がセットされること" do
          result = I18n.t("user_maintenance.sections.users.inherit_data.complete")
          subject
          expect(flash[:notice]).to eq(result)
        end

        it "indexにリダイレクトすること" do
          expect(subject).to redirect_to section_users_path(section_id: section.id)
        end

        it "User#inherit_dataが呼ばれること" do
          User.any_instance.should_receive(:inherit_data)
          subject
        end
      end

      describe "異常系" do
        context "params[:to_id]とparams[:from_id]が等しい場合" do
          subject{post :inherit_data, to_id: to_user.id, from_id: to_user.id, section_id: section.id}

          it "@error_messageにエラーメッセージがセットされること" do
            result = I18n.t("user_maintenance.sections.users.inherit_data.the_same_user_has_been_set")
            subject
            expect(assigns[:error_message]).to eq(result)
          end

          it "inherit_data_formがrenderされること" do
            expect(subject).to render_template("inherit_data_form")
          end

          it "inherit_data_formが呼ばれること" do
            expect(controller).to receive(:inherit_data_form)
            subject
          end
        end

        context "不正なパラメータが送られた場合" do
          shared_examples_for("不正なパラメータが送られた場合の処理") do
            it "inherit_data_formにリダイレクトすること" do
              expect(subject).to redirect_to(inherit_data_form_section_users_path(section_id: section.id))
            end

            it "flash[:alert]がセットされること" do
              subject
              msg = I18n.t("user_maintenance.sections.users.inherit_data.invalid_parameter")
              expect(flash[:alert]).to eq(msg)
            end
          end

          context "paramas[:to_id]で取得したユーザが選択している所属のユーザでは無い場合" do
            before{to_user.update!(section_id: 0)}
            subject{post :inherit_data, to_id: to_user.id, from_id: from_user.id, section_id: section.id}
            it_behaves_like("不正なパラメータが送られた場合の処理")
          end

          context "paramas[:from_id]で取得したユーザが選択している所属のユーザでは無い場合" do
            before{from_user.update!(section_id: 0)}
            subject{post :inherit_data, to_id: to_user.id, from_id: from_user.id, section_id: section.id}
            it_behaves_like("不正なパラメータが送られた場合の処理")
          end
        end

        context "更新処理で例外が発生した場合" do
          before{User.any_instance.stub(:inherit_data).and_raise}

          it "flash[:alert]がセットされること" do
            result = I18n.t("user_maintenance.sections.users.inherit_data.failed")
            subject
            expect(flash[:alert]).to eq(result)
          end

          it "indexにリダイレクトすること" do
            expect(subject).to redirect_to section_users_path(section_id: section.id)
          end
        end
      end
    end

    describe "GET edit_password" do
      subject{get :edit_password, section_id: current_user.section_id}
      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "edit_passwordがrenderされること" do
          expect(subject).to render_template(:edit_password)
        end
      end
    end

    describe "PATCH update_password" do
      describe "正常系" do
        let(:user_params){{password: "password1", password_confirmation: "password1"}}
        let(:msg){I18n.t("user_maintenance.sections.users.update_password.success")}
        subject{patch :update_password, section_id: current_user.section_id, user: user_params}

        it "indexにリダイレクトすること" do
          expect(subject).to redirect_to(section_users_path(section_id: current_user.section.id))
        end

        it "sign_inが呼ばれること" do
          controller.should_receive(:sign_in).with(current_user, bypass: true)
          subject
        end

        it "flash[:notice]が設定されること" do
          subject
          expect(flash[:notice]).to eq(msg)
        end

        it "パスワードが更新されること" do
          encrypted_password = current_user.encrypted_password
          subject
          expect(User.find(current_user).encrypted_password).to_not eq(encrypted_password)
        end
      end

      describe "異常系" do
        let(:user_params){{password: "password1", password_confirmation: "password2"}}
        let(:msg){I18n.t("user_maintenance.sections.users.update_password.success")}
        subject{patch :update_password, section_id: current_user.section_id, user: user_params}

        context "更新に失敗した場合" do
          it "edit_passwordがrenderされること" do
            expect(subject).to render_template(:edit_password)
          end

          it "200が返ること" do
            expect(subject).to be_success
          end
        end
      end
    end
  end

  describe "private" do
    let(:user){create(:editor_user)}
    before do
      controller.stub(:current_user){user}
    end

    describe "update_password_params" do
      let(:valid_params){
        {password: "pc", password_confirmation: "pc"}.stringify_keys
      }
      let(:invalid_params){valid_params.merge(login: "user001")}
      subject{controller.send(:update_password_params)}
      before do
        controller.params[:user] = invalid_params
      end

      it "valid_paramsのみが残ること" do
        expect(subject).to eq(valid_params)
      end
    end

    describe "user_params" do
      let(:valid_params){
        {
          login: "login", name: "name", authority: 1,
          password: "pc", password_confirmation: "pc", remarks: "r",
          section_id: "1"
        }.stringify_keys
      }
      let(:invalid_params){valid_params.merge(test: "test")}
      subject{controller.send(:user_params)}
      before do
        controller.params[:user] = invalid_params
      end

      context "ユーザの登録の場合" do
        before do
          u = build(:editor_user)
          controller.instance_eval do
            @user = u
          end
        end

        it "ログインユーザが管理者の場合、valid_paramsのみが残ること" do
          user.stub(:admin?){true}
          expect(subject).to eq(valid_params)
        end

        it "ログインユーザが管理者以外の場合、section_idを抜いたvalid_paramsのみが残ること" do
          user.stub(:admin?){false}
          valid_params.delete("section_id")
          expect(subject).to eq(valid_params)
        end
      end

      context "ユーザの更新の場合" do
        before do
          u = create(:editor_user)
          controller.instance_eval do
            @user = u
          end
        end

        it "ログインユーザが管理者の場合、loginを抜いたvalid_paramsのみが残ること" do
          user.stub(:admin?){true}
          valid_params.delete("login")
          expect(subject).to eq(valid_params)
        end

        it "ログインユーザが管理者以外の場合、loginとsection_idを抜いたvalid_paramsのみが残ること" do
          user.stub(:admin?){false}
          valid_params.delete("login")
          valid_params.delete("section_id")
          expect(subject).to eq(valid_params)
        end
      end
    end
  end
end
