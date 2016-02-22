require 'spec_helper'

describe UserMaintenance::Sections::UserGroupsController do
  describe "filter" do
    let(:section){create(:section)}
    let(:user_group){create(:user_group, section_id: section.id)}
    let(:user){create(:editor_user, section_id: section.id)}

    let(:filters){[
      :authenticate_user!, :set_section, :set_breadcrumbs, :section_accessible_check,
      :set_user_group, :set_index_breadcrumbs, :set_show_breadcrumbs,
      :set_user_group_list, :accessible_check
    ]}

    controller do
      %w(index new show user_list template_list edit create update destroy set_member update_set_member search_member destroy_member).each do |act|
        define_method(act) do
          render text: "ok"
        end
      end
    end

    before do
      @routes.draw do
        resources :anonymous do
          member do
            get :user_list
            get :template_list
            get :set_member
            post :search_member
            post :update_set_member
            delete :destroy_member
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
        it_behaves_like("未ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :user_list) {before{get :user_list, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :set_member) {before{get :set_member, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :update_set_member) {before{post :update_set_member, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :search_member) {before{post :search_member, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy_member) {before{delete :destroy_member, id: 1}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :user_list) {before{get :user_list, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :set_member) {before{get :set_member, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :update_set_member) {before{post :update_set_member, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :search_member) {before{post :search_member, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy_member) {before{delete :destroy_member, id: 1}}
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
      it_behaves_like("インスタンス変数の確認", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :show) {before{get :show, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :user_list) {before{get :user_list, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :set_member) {before{get :set_member, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :post, :update_set_member) {before{post :update_set_member, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :post, :create) {before{post :create, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :post, :search_member) {before{post :search_member, id: 1, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy_member) {before{delete :destroy_member, id: 1, section_id: section.id}}
    end

    describe "#set_breadcrums" do
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
        controller.stub(:current_user){user}
        filters.reject{|f|f == :set_breadcrumbs}.each do |f|
          controller.stub(f)
        end
        sec = section
        controller.instance_eval do
          @section = sec
        end
      end

      it_behaves_like("パンくずの確認", :get, :index) {before{get :index, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :show) {before{get :show, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :user_list) {before{get :user_list, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :set_member) {before{get :set_member, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :update_set_member) {before{post :update_set_member, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :create) {before{post :create, section_id: section.id}}
      it_behaves_like("パンくずの確認", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :search_member) {before{post :search_member, id: 1, section_id: section.id}}
      it_behaves_like("パンくずの確認", :delete, :destroy_member) {before{delete :destroy_member, id: 1, section_id: section.id}}
    end

    describe "#section_accessible_check" do
      shared_examples_for("アクセス権がない場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、トップページ画面が表示されること" do
          expect(subject).to redirect_to(root_path)
        end
      end

      before do
        controller.stub(:current_user){user}
        filters.reject{|f|f == :section_accessible_check}.each do |f|
          controller.stub(f)
        end
        se = section
        controller.instance_eval do
          @section = se
        end
      end

      shared_examples_for("アクセス権がある場合の処理") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      context "ログインユーザが管理者の場合" do
        before{login_user(create(:super_user))}

        it_behaves_like("アクセス権がある場合の処理", :get, :index) {before{get :index, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :show) {before{get :show, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :user_list) {before{get :user_list, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :set_member) {before{get :set_member, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :update_set_member) {before{post :update_set_member, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :create) {before{post :create, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :search_member) {before{post :search_member, id: 1, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :delete, :destroy_member) {before{delete :destroy_member, id: 1, section_id: section.id}}
      end

      context "ログインユーザが管理者では無い場合" do
        before do
          login_user(user)
        end

        context "ログインユーザが所属の管理者の場合" do
          before do
            user.update!(section_id: section.id, authority: User.authorities[:section_manager])
          end

          it_behaves_like("アクセス権がある場合の処理", :get, :index) {before{get :index, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :show) {before{get :show, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :user_list) {before{get :user_list, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :set_member) {before{get :set_member, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :update_set_member) {before{post :update_set_member, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :create) {before{post :create, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :search_member) {before{post :search_member, id: 1, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :delete, :destroy_member) {before{delete :destroy_member, id: 1, section_id: section.id}}
        end

        context "ログインユーザが所属の管理者では無い場合" do
          context "ログインユーザが所属のメンバーである場合" do
            it_behaves_like("アクセス権がある場合の処理", :get, :index) {before{get :index, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :get, :show) {before{get :show, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :get, :user_list) {before{get :user_list, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :get, :set_member) {before{get :set_member, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :post, :update_set_member) {before{post :update_set_member, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :post, :create) {before{post :create, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :post, :search_member) {before{post :search_member, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がある場合の処理", :delete, :destroy_member) {before{delete :destroy_member, id: 1, section_id: section.id}}
          end

          context "ログインユーザが所属のメンバーでない場合" do
            before do
              user.update!(section_id: 0)
            end

            it_behaves_like("アクセス権がない場合の処理", :get, :index) {before{get :index, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :get, :edit) {before{get :edit, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :get, :show) {before{get :show, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :get, :user_list) {before{get :user_list, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :get, :set_member) {before{get :set_member, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :post, :update_set_member) {before{post :update_set_member, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :post, :create) {before{post :create, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :patch, :update) {before{patch :update, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :delete, :destroy) {before{delete :destroy, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :post, :search_member) {before{post :search_member, id: 1, section_id: section.id}}
            it_behaves_like("アクセス権がない場合の処理", :delete, :destroy_member) {before{delete :destroy_member, id: 1, section_id: section.id}}
          end
        end
      end
    end

    describe "#set_user_group" do
      let(:user_group){create(:user_group)}

      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@user_groupがセットされていること" do
          expect(assigns[:user_group]).to eq(user_group)
        end
      end
      
      before do
        controller.stub(:current_user){user}
        filters.reject{|f|f == :set_user_group}.each do |f|
          controller.stub(f)
        end
        se = section
        controller.instance_eval do
          @section = se
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :show){before{get :show, id: user_group.id}}
      it_behaves_like("インスタンス変数の確認", :get, :user_list){before{get :user_list, id: user_group.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit){before{get :edit, id: user_group.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update){before{patch :update, id: user_group.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy){before{delete :destroy, id: user_group.id}}
      it_behaves_like("インスタンス変数の確認", :get, :set_member){before{get :set_member, id: user_group.id}}
      it_behaves_like("インスタンス変数の確認", :post, :update_set_member){before{post :update_set_member, id: user_group.id}}
      it_behaves_like("インスタンス変数の確認", :post, :search_member) {before{post :search_member, id: user_group.id, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy_member) {before{delete :destroy_member, id: user_group.id, section_id: section.id}}
    end

    describe "#set_user_group_list" do
      let(:super_user){create(:super_user)}
      let(:editor_user){create(:editor_user)}
      let(:user_groups){
        (1..25).map do
          create(:user_group, section_id: section.id)
        end.flatten.sort_by(&:id)
      }
      
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@sectionにひもづくページネーションに対応した@user_groupsがセットされていること" do
          subject
          expect(assigns[:user_groups]).to match_array(user_groups[10,10])
        end
      end

      before do
        user_groups # let call
        controller.stub(:current_user){user}
        filters.reject{|f|f == :set_user_group_list}.each do |f|
          controller.stub(f)
        end
        se = section
        controller.instance_eval do
          @section = se
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :index){subject{get :index, page: 2, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :new){subject{get :new, page: 2, section_id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit){subject{get :edit, id: user_group.id, page: 2, section_id: section.id}}
    end

    describe "#set_index_breadcrumbs" do
      shared_examples_for "パンくずの確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@breadcrumbsにユーザグループ一覧画面へのパンくずががセットされていること" do
          path = section_user_groups_path(section_id: section.id)
          name = I18n.t("user_maintenance.sections.user_groups.index.title", section_name: section.name)
          expect(assigns[:breadcrumbs].any?{|a|a.path == path && a.name == name}).to be_true
        end
      end

      before do
        controller.stub(:current_user){user}
        filters.reject{|f|f == :set_index_breadcrumbs}.each do |f|
          controller.stub(f)
        end
        se = section
        controller.instance_eval do
          @section = se
        end
      end

      it_behaves_like("パンくずの確認", :get, :edit) {before{get :edit, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :show) {before{get :show, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :user_list) {before{get :user_list, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :set_member) {before{get :set_member, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :update_set_member) {before{post :update_set_member, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :create) {before{post :create, section_id: section.id}}
      it_behaves_like("パンくずの確認", :patch, :update) {before{patch :update, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :delete, :destroy) {before{delete :destroy, id: section.id, section_id: section.id}}
    end

    describe "#set_show_breadcrumbs" do
      shared_examples_for "パンくずの確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@breadcrumbsにユーザグループ詳細画面へのパンくずががセットされていること" do
          path = section_user_group_path(user_group, section_id: section.id)
          name = I18n.t("user_maintenance.sections.user_groups.show.title", group_name: user_group.name, section_name: section.name)
          expect(assigns[:breadcrumbs].any?{|a|a.path == path && a.name == name}).to be_true
        end
      end

      before do
        controller.stub(:current_user){user}
        filters.reject{|f|f == :set_show_breadcrumbs}.each do |f|
          controller.stub(f)
        end
        se, ug = section, user_group
        controller.instance_eval do
          @section = se
          @user_group = ug
        end
      end

      it_behaves_like("パンくずの確認", :get, :edit) {before{get :edit, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :user_list) {before{get :user_list, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :get, :set_member) {before{get :set_member, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :post, :update_set_member) {before{post :update_set_member, id: section.id, section_id: section.id}}
      it_behaves_like("パンくずの確認", :patch, :update) {before{patch :update, id: section.id, section_id: section.id}}
    end

    describe "#accessible_check" do
      let(:super_user){create(:super_user)}
      let(:editor_user){create(:editor_user)}

      shared_examples_for "アクセス権がある場合の処理" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      shared_examples_for "アクセス権がない場合の処理" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、所属の詳細画面が表示されること" do
          expect(subject).to redirect_to(section_path(section.id))
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          msg = I18n.t("alerts.can_not_access")
          expect(flash[:alert]).to eq(msg)
        end
      end

      before do
        filters.reject{|f|f == :accessible_check}.each do |f|
          controller.stub(f)
        end
        se = section
        controller.instance_eval do
          @section = se
        end
      end

      context "ログインユーザが管理者の場合" do
        before{controller.stub(:current_user){super_user}}
        it_behaves_like("アクセス権がある場合の処理", :get, :index) {before{get :index, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :edit) {before{get :edit, id: user_group.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :show) {before{get :show, id: user_group.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :user_list) {before{get :user_list, id: user_group.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :get, :set_member) {before{get :set_member, id: user_group.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :update_set_member) {before{post :update_set_member, id: user_group.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :create) {before{post :create, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :patch, :update) {before{patch :update, id: user_group.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {before{delete :destroy, id: user_group.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :post, :search_member) {before{post :search_member, id: user_group.id, section_id: section.id}}
        it_behaves_like("アクセス権がある場合の処理", :delete, :destroy_member) {before{delete :destroy_member, id: user_group.id, section_id: section.id}}
      end

      context "ログインユーザが管理者以外の場合" do
        before{controller.stub(:current_user){editor_user}}
        context "ユーザグループの所属の管理者の場合" do
          before do
            editor_user.update!(section_id: section.id, authority: User.authorities[:section_manager])
          end

          it_behaves_like("アクセス権がある場合の処理", :get, :index) {before{get :index, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :edit) {before{get :edit, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :show) {before{get :show, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :user_list) {before{get :user_list, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :set_member) {before{get :set_member, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :update_set_member) {before{post :update_set_member, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :create) {before{post :create, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :patch, :update) {before{patch :update, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {before{delete :destroy, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :search_member) {before{post :search_member, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がある場合の処理", :delete, :destroy_member) {before{delete :destroy_member, id: user_group.id, section_id: section.id}}
        end

        context "ユーザグループの所属の管理者ではない場合" do
          before do
            editor_user.update!(section_id: section.id, authority: User.authorities[:editor])
          end

          it_behaves_like("アクセス権がない場合の処理", :get, :index) {before{get :index, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :get, :edit) {before{get :edit, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :get, :show) {before{get :show, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :get, :user_list) {before{get :user_list, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :get, :set_member) {before{get :set_member, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :post, :update_set_member) {before{post :update_set_member, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :post, :create) {before{post :create, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :patch, :update) {before{patch :update, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :delete, :destroy) {before{delete :destroy, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :post, :search_member) {before{post :search_member, id: user_group.id, section_id: section.id}}
          it_behaves_like("アクセス権がない場合の処理", :delete, :destroy_member) {before{delete :destroy_member, id: user_group.id, section_id: section.id}}
        end
      end
    end
  end

  describe "action" do
    let(:section){create(:section)}
    let(:current_user){create(:section_manager_user, section_id: section.id)}
    let(:user_group){create(:user_group, section_id: section.id)}
    
    before do
      login_user(current_user)
    end

    describe "GET index" do
      describe "正常系" do
        before do
          user_group # let
        end

        subject{get :index, section_id: section.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "indexがrenderされること" do
          expect(subject).to render_template("index")
        end
      end
    end

    describe "GET show" do
      describe "正常系" do
        subject{get :show, id: user_group.id, section_id: section.id}

        let(:users){(1..10).map{create(:editor_user)}.sort_by(&:id)}
        let(:templates){(1..10).map{create(:template)}.sort_by(&:id)}

        before do
          user_group.users << users
          user_group.templates << templates
          # 関係ないユーザ、テンプレートも作成
          (1..5).map{create(:editor_user)}
          (1..5).map{create(:template)}
        end

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "showがrenderされること" do
          expect(subject).to render_template("show")
        end

        it "@usersがuser_groupに登録されているユーザの一覧がページネートされて返ること" do
          subject
          expect(assigns[:users]).to match_array(user_group.users[0...UserMaintenance::Sections::UserGroupsController::SHOW_LIST_PER])
        end

        it "@templatesがuser_groupに登録されているテンプレートの一覧がページネートされて返ること" do
          subject
          expect(assigns[:templates]).to match_array(templates[0...UserMaintenance::Sections::UserGroupsController::SHOW_LIST_PER])
        end
      end
    end

    describe "GET user_list" do
      describe "正常系" do
        subject{get :user_list, id: user_group.id, section_id: section.id}

        let(:users){(1..10).map{create(:editor_user)}}

        before do
          user_group.users << users
          # 関係ないユーザも作成
          (1..5).map{create(:editor_user)}
        end

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "user_listがrenderされること" do
          expect(subject).to render_template("user_list")
        end

        it "@usersがuser_groupに登録されているユーザの一覧がページネートされて返ること" do
          subject
          expect(assigns[:users]).to match_array(user_group.users)
        end
      end
    end
    
    describe "GET template_list" do
      describe "正常系" do
        subject{get :template_list, id: user_group.id, section_id: section.id}

        let(:templates){(1..11).map{create(:template)}}

        before do
          user_group.templates << templates
          # 関係ないユーザも作成
          (1..5).map{create(:template)}
        end

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "template_listがrenderされること" do
          expect(subject).to render_template("template_list")
        end

        it "@templatesがuser_groupに登録されているユーザの一覧がページネートされて返ること" do
          subject
          expect(assigns[:templates]).to match_array(Kaminari.paginate_array(user_group.templates))
        end
      end
    end

    describe "GET new" do
      describe "正常系" do
        subject{get :new, section_id: section.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "newがrenderされること" do
          expect(subject).to render_template("new")
        end

        it "@user_groupにUserGroupクラスの新規インスタンスがセットされること" do
          subject
          expect(assigns[:user_group]).to be_a_new(UserGroup)
        end
      end
    end

    describe "GET edit" do
      describe "正常系" do
        subject{get :edit, id: user_group.id, section_id: section.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "editがrenderされること" do
          expect(subject).to render_template("edit")
        end
      end
    end

    describe "POST create" do
      describe "正常系" do
        let(:user_group_params){{"name" => "観光協会"}}
        subject {post :create, user_group: user_group_params, section_id: section.id}

        context "バリデーションに成功した場合" do
          it "UserGroupレコードが追加されること" do
            expect{subject}.to change(UserGroup, :count).by(1)
          end

          it "作成したグループのsection_idに@section.idがセットされること" do
            subject
            expect(assigns[:user_group].section_id).to eq(section.id)
          end

          it "showにリダイレクトすること" do
            expect(subject).to redirect_to(section_user_group_path(assigns[:user_group], section_id: section.id))
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.create_after")
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      describe "異常系" do
        let(:user_group_params){{"name" => ""}}
        subject {post :create, user_group: user_group_params, section_id: section.id}

        context "バリデーションに失敗した場合" do
          it "レコードが追加されないこと" do
            expect{subject}.to change(UserGroup, :count).by(0)
          end

          it "newがrenderされること" do
            expect(subject).to render_template(:new)
          end

          it "set_user_group_listが呼ばれること" do
            controller.should_receive(:set_user_group_list)
            subject
          end
        end
      end
    end

    describe "PATCH update" do
      describe "正常系" do
        let(:user_group_params){{"name" => "観光協会"}}
        subject {patch :update, id: user_group.id, user_group: user_group_params, section_id: section.id}

        context "バリデーションに成功した場合" do
          before do
            user_group.stub(:valid?){true}
          end

          it "showにリダイレクトすること" do
            expect(subject).to redirect_to(section_user_group_path(user_group.id, section_id: section.id))
          end

          it "更新されていること" do
            subject
            expect(assigns[:user_group]).to eq(UserGroup.new(user_group_params.merge("id" => user_group.id)))
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.update_after")
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      describe "異常系" do
        let(:user_group_params){{"name" => ""}}
        subject {patch :update, id: user_group.id, user_group: user_group_params, section_id: section.id}

        context "バリデーションに失敗した場合" do
          it "editがrenderされること" do
            expect(subject).to render_template(:edit)
          end

          it "set_user_group_listが呼ばれること" do
            controller.should_receive(:set_user_group_list)
            subject
          end
        end
      end
    end

    describe "GET destroy" do
      subject{delete :destroy, id: user_group.id, section_id: section.id}

      describe "正常系" do
        context "削除できるグループの場合" do
          before do
            user_group
            UserGroup.any_instance.stub(:destroyable?){true}
          end

          it "レコードが１件削除されること" do
            expect{subject}.to change(UserGroup, :count).by(-1)
          end

          it "indexへリダイレクトされること" do
            expect(subject).to redirect_to(section_user_groups_path(section_id: section.id))
          end

          it "flash[:notice]がセットされること" do
            msg = I18n.t("user_maintenance.sections.user_groups.destroy.success")
            subject
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      describe "異常系" do
        context "削除できないグループの場合" do
          before do
            UserGroup.any_instance.stub(:destroyable?){false}
          end

          it "レコードが削除されないこと" do
            expect{subject}.to_not change(UserGroup, :count).by(-1)
          end

          it "showへリダイレクトされること" do
            expect(subject).to redirect_to(section_user_group_path(user_group, section_id: section.id))
          end

          it "flash[:alert]がセットされること" do
            msg = I18n.t("user_maintenance.sections.user_groups.destroy.failed")
            subject
            expect(flash[:alert]).to eq(msg)
          end
        end
      end
    end

    describe "GET set_member" do
      subject{get :set_member, id: user_group.id, section_id: section.id}

      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "set_memberがrenderされること" do
          expect(subject).to render_template("set_member")
        end

        it "@user_groups_member_searchにUserGroupsMemberSearchの新規インスタンスがセットされること" do
          ugms = UserGroupsMemberSearch.new(user_group_id: user_group.id)
          UserGroupsMemberSearch.stub(:new){ugms}
          subject
          # activerecordではないのでbe_a_newでは判定不可
          expect(assigns[:user_groups_member_search]).to eq(ugms)
        end
      end
    end

    describe "POST search_member" do
      let(:user){create(:editor_user)}
      let(:user_groups_member_search_params){{login: user.login}}
      subject{xhr :post, :search_member, id: user_group.id, section_id: section.id, user_groups_member_search: user_groups_member_search_params}

      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "search_memberがrenderされること" do
          expect(subject).to render_template("search_member")
        end

        it "@user_groups_member_searchにパラメータをもとにUserGroupsMemberSearchインスタンスがセットされること" do
          ugms = UserGroupsMemberSearch.new(user_groups_member_search_params.merge(user_group_id: user_group.id))
          UserGroupsMemberSearch.stub(:new){ugms}
          subject
          expect(assigns[:user_groups_member_search]).to eq(ugms)
        end
      end
    end

    describe "POST update_set_member" do
      let(:user){create(:editor_user, section_id: 0)}
      let(:user_groups_member_search_params){{login: user.login, user_group_id: user_group.id}}
      subject{post :update_set_member, id: user_group.id, section_id: section.id, user_groups_member_search: user_groups_member_search_params}

      describe "正常系" do
        it "set_memberにリダイレクトすること" do
          expect(subject).to redirect_to(set_member_section_user_group_path(user_group, section_id: section.id))
        end

        it "flash[:notice]がセットされること" do
          subject
          msg = I18n.t("user_maintenance.sections.user_groups.update_set_member.success")
          expect(flash[:notice]).to eq(msg)
        end

        it "user_groupにメンバーが追加されること" do
          expect{subject}.to change{user_group.users.count}.by(1)
        end

        it "メンバーに追加されたユーザのloginがparams[:user_groups_member_search]のloginと等しいこと" do
          user_group.user_groups_members.destroy_all
          subject
          expect(user_group.users.first.login).to eq(user.login)
        end
      end

      describe "異常系" do
        shared_examples_for("エラー発生時の処理") do
          it "set_memberにリダイレクトすること" do
            expect(subject).to redirect_to(set_member_section_user_group_path(user_group, section_id: section.id))
          end

          it "flash[:alert]がセットされること" do
            subject
            msg = I18n.t("user_maintenance.sections.user_groups.update_set_member.failed")
            expect(flash[:alert]).to eq(msg)
          end
        end
        
        context "すでに登録されているユーザのログインIDが送られた場合" do
          before{user_group.users << user}
          it_behaves_like("エラー発生時の処理")
        end

        context "loginがnilの場合" do
          before{user.login = nil}
          it_behaves_like("エラー発生時の処理")
        end

        context "loginで渡されたユーザの所属がユーザグループと等しい場合" do
          before do
            user.update!(section_id: section.id)
            user_group.update!(section_id: section.id)
          end
          it_behaves_like("エラー発生時の処理")
        end
      end
    end

    describe "DELETE destroy_member" do
      let(:user){create(:editor_user)}
      before do
        user_group.users << user
      end

      subject{delete :destroy_member, id: user_group.id, section_id: section.id, user_id: user.id}

      describe "正常系" do
        it "user_listにリダイレクトすること" do
          expect(subject).to redirect_to(user_list_section_user_group_path(user_group, section_id: section.id))
        end

        it "flash[:notice]がセットされること" do
          subject
          msg = I18n.t("user_maintenance.sections.user_groups.destroy_member.success")
          expect(flash[:notice]).to eq(msg)
        end

        it "user_groupのメンバーが１人削除されていること" do
          expect{subject}.to change{user_group.user_groups_members.count}.by(-1)
        end

        it "params[:user_id]のユーザがグループから外されていること" do
          expect{subject}.to change{user_group.user_groups_members.where(user_id: user.id).exists?}.from(true).to(false)
        end
      end
    end
  end

  describe "private" do
    let(:current_user){create(:editor_user)}
    let(:user_group){create(:user_group)}
    before do
      controller.stub(:current_user){current_user}
    end

    describe "#user_group_params" do
      let(:valid_params){{"name" => "user_group"}}
      let(:invalid_params){valid_params.merge(test: "test")}
      subject{controller.send(:user_group_params)}
      before do
        controller.params[:user_group] = invalid_params
      end

      it "valid_paramsのみが残ること" do
        expect(subject).to eq(valid_params.stringify_keys)
      end
    end

    describe "#user_groups_member_search_params" do
      let(:valid_params){{"login" => "user0001", "user_group_id" => "1"}}
      let(:invalid_params){valid_params.merge(test: "test")}
      subject{controller.send(:user_groups_member_search_params)}
      before do
        controller.params[:user_groups_member_search] = invalid_params
      end

      it "valid_paramsのみが残ること" do
        expect(subject).to eq(valid_params.stringify_keys)
      end
    end
  end
end
