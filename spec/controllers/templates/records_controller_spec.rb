require 'spec_helper'

describe Templates::RecordsController do
  let(:section){create(:section)}
  let(:current_user){create(:section_manager_user, section_id: section.id)}
  let(:service){create(:service, section_id: section.id)}
  let(:template){create(:template, service_id: service.id)}
  let(:template_record){create(:template_record, template_id: template.id)}

  describe "filter" do
    let(:filters){[
      :authenticate_user!, :set_template, :template_accessible_check,
      :set_template_record, :accessible_check, :editable_check, :destroyable_check
    ]}

    controller do
      [
        %w(index show edit update new create destroy),
        %w(import_csv_form confirm_import_csv import_csv complete_import_csv download_csv download_rdf),
        %w(search_keyword element_description element_relation_search_form),
        %w(element_relation_search remove_csv_file display_relation_contents)
      ].flatten.each do |act|
        define_method(act) do
          render text: "ok"
        end
      end
    end

    before do
      @routes.draw do
        resources :anonymous do
          collection do
            get :import_csv_form      # CSV一括登録画面
            post :confirm_import_csv  # CSV一括登録確認
            post :import_csv          # CSV一括登録処理
            get :complete_import_csv  # CSV一括登録完了画面
            get :download_csv         # CSV出力
            get :download_rdf         # RDF出力

            post :search_keyword       # キーワード検索

            get :element_description # 項目の説明popover

            post :element_relation_search_form
            post :element_relation_search
            delete :remove_csv_file
          end

          member do
            get :display_relation_contents # 選択している関連データの表示
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
        it_behaves_like("未ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :import_csv_form) {before{get :import_csv_form}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :confirm_import_csv) {before{post :confirm_import_csv}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :import_csv) {before{post :import_csv}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :complete_import_csv) {before{get :complete_import_csv}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :download_csv) {before{get :download_csv}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :download_rdf) {before{get :download_rdf}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :search_keyword) {before{post :search_keyword}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :element_description) {before{get :element_description}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :element_relation_search_form) {before{post :element_relation_search_form}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :element_relation_search) {before{post :element_relation_search}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :remove_csv_file) {before{delete :remove_csv_file}}
      end

      context "未ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :import_csv_form) {before{get :import_csv_form}}
        it_behaves_like("ログイン時のアクセス制限", :post, :confirm_import_csv) {before{post :confirm_import_csv}}
        it_behaves_like("ログイン時のアクセス制限", :post, :import_csv) {before{post :import_csv}}
        it_behaves_like("ログイン時のアクセス制限", :get, :complete_import_csv) {before{get :complete_import_csv}}
        it_behaves_like("ログイン時のアクセス制限", :get, :download_csv) {before{get :download_csv}}
        it_behaves_like("ログイン時のアクセス制限", :get, :download_rdf) {before{get :download_rdf}}
        it_behaves_like("ログイン時のアクセス制限", :post, :search_keyword) {before{post :search_keyword}}
        it_behaves_like("ログイン時のアクセス制限", :get, :element_description) {before{get :element_description}}
        it_behaves_like("ログイン時のアクセス制限", :post, :element_relation_search_form) {before{post :element_relation_search_form}}
        it_behaves_like("ログイン時のアクセス制限", :post, :element_relation_search) {before{post :element_relation_search}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :remove_csv_file) {before{delete :remove_csv_file}}
      end
    end

    describe "#set_template" do
       before do
        filters.reject{|f|f == :set_template}.each do |f|
          controller.stub(f)
        end
      end

      shared_examples_for("インスタンス変数の確認") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@templateがセットされること" do
          subject
          expect(assigns[:template]).to eq(template)
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :index) {subject{get :index, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :show) {subject{get :show, id: 1, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit) {subject{get :edit, id: 1, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :new) {subject{get :new, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :post, :create) {subject{post :create, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update) {subject{patch :update, id: 1, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy) {subject{delete :destroy, id: 1, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :import_csv_form) {subject{get :import_csv_form, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :post, :confirm_import_csv) {subject{post :confirm_import_csv, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :post, :import_csv) {subject{post :import_csv, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :complete_import_csv) {subject{get :complete_import_csv, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :download_csv) {subject{get :download_csv, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :download_rdf) {subject{get :download_rdf, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :post, :search_keyword) {subject{post :search_keyword, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :element_description) {subject{get :element_description, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :post, :element_relation_search_form) {subject{post :element_relation_search_form, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :post, :element_relation_search) {subject{post :element_relation_search, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :remove_csv_file) {subject{delete :remove_csv_file, template_id: template.id}}
    end

    describe "#template_accessible_check" do
      before do
        login_user(current_user)
        filters.reject{|f|f == :template_accessible_check}.each do |f|
          controller.stub(f)
        end

        temp = template
        controller.instance_eval do
          @template = temp
        end
      end

      shared_examples_for "アクセス権限がない場合の処理" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、サービス一覧が表示されること" do
          expect(subject).to redirect_to(services_path)
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          expect(flash[:alert]).to eq(I18n.t("alerts.can_not_access"))
        end
      end

      shared_examples_for "アクセス権限がある場合の処理" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          subject
          expect(response.body).to eq("ok")
        end
      end


      context "ログインユーザがテンプレートのサービスに割り当てられた所属のユーザの場合" do
        it_behaves_like("アクセス権限がある場合の処理", :get, :index) {subject{get :index, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :get, :show) {subject{get :show, id: template_record.id, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :get, :edit) {subject{get :edit, id: template_record.id, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :get, :new) {subject{get :new, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :post, :create) {subject{post :create, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :patch, :update) {subject{patch :update, id: template_record.id, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :delete, :destroy) {subject{delete :destroy, id: template_record.id, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :get, :import_csv_form) {subject{get :import_csv_form, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :post, :confirm_import_csv) {subject{post :confirm_import_csv, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :post, :import_csv) {subject{post :import_csv, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :get, :complete_import_csv) {subject{get :complete_import_csv, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :get, :download_csv) {subject{get :download_csv, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :get, :download_rdf) {subject{get :download_rdf, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :post, :search_keyword) {subject{post :search_keyword, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :get, :element_description) {subject{get :element_description, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :post, :element_relation_search_form) {subject{post :element_relation_search_form, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :post, :element_relation_search) {subject{post :element_relation_search, template_id: template.id}}
        it_behaves_like("アクセス権限がある場合の処理", :delete, :remove_csv_file) {subject{delete :remove_csv_file, template_id: template.id}}
      end

      context "ログインユーザがテンプレートのサービスに割れ当てられた所属のユーザではない場合" do
        before{current_user.update!(section_id: create(:section).id)}

        context "テンプレートにグループが割り当てられていない場合" do
          before{template.update!(user_group_id: nil)}

          it_behaves_like("アクセス権限がない場合の処理", :get, :index) {subject{get :index, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :get, :show) {subject{get :show, id: template_record.id, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :get, :edit) {subject{get :edit, id: template_record.id, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :get, :new) {subject{get :new, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :post, :create) {subject{post :create, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :patch, :update) {subject{patch :update, id: template_record.id, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :delete, :destroy) {subject{delete :destroy, id: template_record.id, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :get, :import_csv_form) {subject{get :import_csv_form, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :post, :confirm_import_csv) {subject{post :confirm_import_csv, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :post, :import_csv) {subject{post :import_csv, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :get, :complete_import_csv) {subject{get :complete_import_csv, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :get, :download_csv) {subject{get :download_csv, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :get, :download_rdf) {subject{get :download_rdf, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :post, :search_keyword) {subject{post :search_keyword, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :get, :element_description) {subject{get :element_description, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :post, :element_relation_search_form) {subject{post :element_relation_search_form, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :post, :element_relation_search) {subject{post :element_relation_search, template_id: template.id}}
          it_behaves_like("アクセス権限がない場合の処理", :delete, :remove_csv_file) {subject{delete :remove_csv_file, template_id: template.id}}
        end

        context "テンプレートにグループが割り当てられている場合" do
          let(:user_group){create(:user_group, section_id: section.id)}
          before{template.update!(user_group_id: user_group.id)}

          context "ログインユーザがグループのメンバーの場合" do
            before{user_group.users << current_user}
            it_behaves_like("アクセス権限がある場合の処理", :get, :index) {subject{get :index, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :get, :show) {subject{get :show, id: template_record.id, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :get, :edit) {subject{get :edit, id: template_record.id, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :get, :new) {subject{get :new, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :post, :create) {subject{post :create, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :patch, :update) {subject{patch :update, id: template_record.id, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :delete, :destroy) {subject{delete :destroy, id: template_record.id, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :get, :import_csv_form) {subject{get :import_csv_form, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :post, :confirm_import_csv) {subject{post :confirm_import_csv, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :post, :import_csv) {subject{post :import_csv, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :get, :complete_import_csv) {subject{get :complete_import_csv, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :get, :download_csv) {subject{get :download_csv, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :get, :download_rdf) {subject{get :download_rdf, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :post, :search_keyword) {subject{post :search_keyword, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :get, :element_description) {subject{get :element_description, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :post, :element_relation_search_form) {subject{post :element_relation_search_form, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :post, :element_relation_search) {subject{post :element_relation_search, template_id: template.id}}
            it_behaves_like("アクセス権限がある場合の処理", :delete, :remove_csv_file) {subject{delete :remove_csv_file, template_id: template.id}}
          end

          context "ログインユーザがグループのメンバーではない場合" do
            it_behaves_like("アクセス権限がない場合の処理", :get, :index) {subject{get :index, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :get, :show) {subject{get :show, id: template_record.id, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :get, :edit) {subject{get :edit, id: template_record.id, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :get, :new) {subject{get :new, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :post, :create) {subject{post :create, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :patch, :update) {subject{patch :update, id: template_record.id, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :delete, :destroy) {subject{delete :destroy, id: template_record.id, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :get, :import_csv_form) {subject{get :import_csv_form, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :post, :confirm_import_csv) {subject{post :confirm_import_csv, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :post, :import_csv) {subject{post :import_csv, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :get, :complete_import_csv) {subject{get :complete_import_csv, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :get, :download_csv) {subject{get :download_csv, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :get, :download_rdf) {subject{get :download_rdf, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :post, :search_keyword) {subject{post :search_keyword, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :get, :element_description) {subject{get :element_description, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :post, :element_relation_search_form) {subject{post :element_relation_search_form, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :post, :element_relation_search) {subject{post :element_relation_search, template_id: template.id}}
            it_behaves_like("アクセス権限がない場合の処理", :delete, :remove_csv_file) {subject{delete :remove_csv_file, template_id: template.id}}
          end
        end
      end
    end

    describe "#set_template_record" do
      shared_examples_for("インスタンス変数の確認") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@template_recordがセットされること" do
          subject
          expect(assigns[:template_record]).to eq(template_record)
        end
      end

      before do
        filters.reject{|f|f == :set_template_record}.each do |f|
          controller.stub(f)
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :show){subject{get :show, id: template_record.id, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit){subject{get :edit, id: template_record.id, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update){subject{patch :update, id: template_record.id, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy){subject{delete :destroy, id: template_record.id, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :display_relation_contents){subject{get :display_relation_contents, id: template_record.id, template_id: template.id}}
    end

    describe "#editable_check" do
      shared_examples_for "更新権限がない場合のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、index画面が表示されること" do
          expect(subject).to redirect_to(template_records_path(template_id: template.id))
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          expect(flash[:alert]).to eq(I18n.t("alerts.can_not_access"))
        end
      end

      shared_examples_for "更新権限がある場合のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        login_user(current_user)
        filters.reject{|f|f == :editable_check}.each do |f|
          controller.stub(f)
        end
        temp = template
        tr = template_record
        controller.instance_eval do
          @template = temp
          @template_record = tr
        end
      end

      context "ログインユーザが作成したデータの場合" do
        before{template_record.update!(user_id: current_user.id)}
        it_behaves_like("更新権限がある場合のアクセス制限", :get, :edit){subject{get :edit, id: template_record.id, template_id: template.id}}
        it_behaves_like("更新権限がある場合のアクセス制限", :patch, :update){subject{patch :update, id: template_record.id, template_id: template.id}}
      end

      context "ログインユーザが作成したデータでは無い場合" do
        before{template_record.update!(user_id: create(:editor_user).id)}

        context "テンプレートのサービスが所属のサービスの場合" do
          before{current_user.update!(section_id: section.id)}

          context "ログインユーザが管理者ユーザの場合" do
            before{current_user.update!(authority: User.authorities[:admin])}
            it_behaves_like("更新権限がある場合のアクセス制限", :get, :edit){subject{get :edit, id: template_record.id, template_id: template.id}}
            it_behaves_like("更新権限がある場合のアクセス制限", :patch, :update){subject{patch :update, id: template_record.id, template_id: template.id}}
          end

          context "ログインユーザが所属管理者ユーザの場合" do
            before{current_user.update!(authority: User.authorities[:section_manager])}
            it_behaves_like("更新権限がある場合のアクセス制限", :get, :edit){subject{get :edit, id: template_record.id, template_id: template.id}}
            it_behaves_like("更新権限がある場合のアクセス制限", :patch, :update){subject{patch :update, id: template_record.id, template_id: template.id}}
          end

          context "ログインユーザがデータ登録者ユーザの場合" do
            before{current_user.update!(authority: User.authorities[:editor])}
            it_behaves_like("更新権限がない場合のアクセス制限", :get, :edit){subject{get :edit, id: template_record.id, template_id: template.id}}
            it_behaves_like("更新権限がない場合のアクセス制限", :patch, :update){subject{patch :update, id: template_record.id, template_id: template.id}}
          end
        end

        context "テンプレートのサービスが所属のサービスではない場合" do
          before{current_user.update!(section_id: create(:section).id)}

          it_behaves_like("更新権限がない場合のアクセス制限", :get, :edit){subject{get :edit, id: template_record.id, template_id: template.id}}
          it_behaves_like("更新権限がない場合のアクセス制限", :patch, :update){subject{patch :update, id: template_record.id, template_id: template.id}}
        end
      end
    end

    describe "#destroyable_check" do
      shared_examples_for "削除権限がない場合のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、index画面が表示されること" do
          expect(subject).to redirect_to(template_records_path(template_id: template.id))
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          expect(flash[:alert]).to eq(I18n.t("alerts.can_not_access"))
        end
      end

      shared_examples_for "削除権限がある場合のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        login_user(current_user)
        filters.reject{|f|f == :destroyable_check}.each do |f|
          controller.stub(f)
        end

        tr = template_record
        temp = template
        controller.instance_eval do
          @template = temp
          @template_record = tr
        end
      end

      context "ログインユーザが作成したデータの場合" do
        before{template_record.update!(user_id: current_user.id)}
        it_behaves_like("削除権限がある場合のアクセス制限", :get, :edit){subject{get :edit, id: template_record.id, template_id: template.id}}
        it_behaves_like("削除権限がある場合のアクセス制限", :patch, :update){subject{patch :update, id: template_record.id, template_id: template.id}}
      end

      context "ログインユーザが作成したデータでは無い場合" do
        before{template_record.update!(user_id: create(:editor_user).id)}

        context "テンプレートのサービスが所属のサービスの場合" do
          before{current_user.update!(section_id: section.id)}

          context "ログインユーザが管理者ユーザの場合" do
            before{current_user.update!(authority: User.authorities[:admin])}
            it_behaves_like("削除権限がある場合のアクセス制限", :delete, :destroy){subject{delete :destroy, id: template_record.id, template_id: template.id}}
          end

          context "ログインユーザが所属管理者ユーザの場合" do
            before{current_user.update!(authority: User.authorities[:section_manager])}
            it_behaves_like("削除権限がある場合のアクセス制限", :delete, :destroy){subject{delete :destroy, id: template_record.id, template_id: template.id}}
          end

          context "ログインユーザがデータ登録者ユーザの場合" do
            before{current_user.update!(authority: User.authorities[:editor])}
            it_behaves_like("削除権限がない場合のアクセス制限", :delete, :destroy){subject{delete :destroy, id: template_record.id, template_id: template.id}}
          end
        end

        context "テンプレートのサービスが所属のサービスではない場合" do
          before{current_user.update!(section_id: create(:section).id)}

          it_behaves_like("削除権限がない場合のアクセス制限", :delete, :destroy){subject{delete :destroy, id: template_record.id, template_id: template.id}}
        end
      end
    end
  end

  describe "action" do
    before do
      login_user(current_user)
    end

    describe "GET index" do
      subject{get :index, template_id: template.id}
      describe "正常系" do
        before do
          els = []
          els << build(:element_by_it_line, template_id: template.id, parent_id: create(:element, template_id: template.id), display: true)
          els << build(:element_by_it_multi_line, display: false, template_id: template.id)
          els << build(:element_by_it_dates, display: true, template_id: template.id)
          Element.import(els)
        end

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "indexがrenderされること" do
          expect(subject).to render_template(:index)
        end

        context "@elementsの検証" do
          before do
            subject
          end

          it "全てのElementがdisplay==trueであること" do
            assigns[:elements].each do |e|
              expect(e.display).to be_true
            end
          end

          it "全てのElementが一番子のエレメントであること" do
            assigns[:elements].each do |e|
              expect(e.children).to be_empty
            end
          end
        end

        context "@template_recordsの検証" do
          it "Template#all_recordsの結果が入ること" do
            trs = TemplateRecord.all
            Template.any_instance.stub(:all_records){trs}
            subject
            expect(assigns[:template_records].to_a).to eq(trs.order("id desc").page(1).to_a)
          end

          it "IDの降順に並び替えられていること" do
            trs = TemplateRecord.order("id desc").page(1)
            Template.any_instance.stub(:all_records){trs}
            subject
            expect(assigns[:template_records]).to eq(trs.sort_by{|a|-a.id})
          end

          it "ページネートされること" do
            TemplateRecord.import((1..11).to_a.map{build(:template_record, template_id: template.id)})
            trs = TemplateRecord.all
            Template.any_instance.stub(:all_records){trs}
            get :index, template_id: template.id, page: 2
            expect(assigns[:template_records].to_a).to eq(trs.order("id desc").page(2).to_a)
          end
        end
      end
    end

    describe "GET show" do
      subject{xhr :get, :show, id: template_record.id, template_id: template.id}

      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "showがrenderされること" do
          expect(subject).to render_template(:show)
        end

        context "@elementsの検証" do
          before do
            e1 = create(:element, available: true, template_id: template.id)
            create(:element, available: true, parent_id: e1.id, template_id: template.id)
            e2 = create(:element, available: false, template_id: template.id)
            create(:element, available: true, parent_id: e2.id, template_id: template.id)

            parent = create(:template, service_id: template.service_id)
            e3 = create(:element, available: true, template_id: parent.id)
            create(:element, available: true, parent_id: e3.id, template_id: parent.id)
            e4 = create(:element, available: false, template_id: parent.id)
            create(:element, available: true, parent_id: e4.id, template_id: parent.id)

            template.update!(parent_id: parent.id)
            subject
          end

          it "Elementが2件取得されること" do
            # 2件とれるはず
            expect(assigns[:elements].size).to eq(2)
          end

          it "取得されるElementの親項目idがnilであること" do
            assigns[:elements].each do |el|
              expect(el.parent_id).to be_nil
            end
          end

          it "取得されるElementの使用フラグがtrueであること" do
            assigns[:elements].each do |el|
              expect(el.available).to be_true
            end
          end

          it "親テンプレートのElementも取得されていること" do
            assigns[:elements].each do |el|
              expect(el.template_id.in?([template.id, template.parent_id])).to be_true
            end
          end
        end
      end
    end

    describe "GET new" do
      subject{get :new, template_id: template.id}
      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "newがrenderされること" do
          expect(subject).to render_template(:new)
        end

        it "set_form_assigsnが呼ばれること" do
          controller.should_receive(:set_form_assigns)
          subject
        end
      end
    end

    describe "GET sample_field" do
      subject{get :sample_field, template_id: template, format: :js}
      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "newがrenderされること" do
          expect(subject).to render_template(:sample_field)
        end

        it "set_form_assigsnが呼ばれること" do
          controller.should_receive(:set_form_assigns)
          subject
        end
      end
    end

    describe "POST create" do
      describe "正常系" do
        let(:tr_params){{}}
        subject{post :create, template_id: template.id, template_record: tr_params}

        context "バリデーションに成功した場合" do
          before{TemplateRecord.any_instance.stub(:valid?){true}}

          it "indexへリダイレクトすること" do
            expect(subject).to redirect_to(template_records_path(template_id: template.id))
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.create_after")
            expect(flash[:notice]).to eq(msg)
          end

          it "TemplateRecordが１件増えること" do
            expect{subject}.to change(Template, :count).by(1)
          end

          context "登録される情報の検証" do
            context "１行入力データがパラメータで送られた場合" do
              let(:val){"１行入力バリュー"}
              let(:template_record_params){
                el = create(:element_by_it_line)
                {
                  el.id => {
                    1 => {
                      0 => {content_id: "", template_id: template.id, value: val}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }.stringify_keys
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが１件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(1)
              end

              it "ElementValue::StringContentが１件追加されること" do
                expect{subject}.to change(ElementValue::StringContent, :count).by(1)
              end

              it "追加されたElementValue::Lineのvalueが正しくセットされていること" do
                subject
                expect(ElementValue::Line.last.value).to eq(val)
              end
            end

            context "複数行入力データがパラメータで送られた場合" do
              let(:val){"複数行入力バリュー\n複数行入力バリュー"}
              let(:template_record_params){
                el = create(:element_by_it_multi_line)
                {
                  el.id => {
                    1 => {
                      0 => {content_id: "", value: val, template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }.stringify_keys
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが１件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(1)
              end

              it "ElementValue::TextContentが１件追加されること" do
                expect{subject}.to change(ElementValue::TextContent, :count).by(1)
              end

              it "追加されたElementValue::MultiLineのvalueが正しくセットされていること" do
                subject
                expect(ElementValue::MultiLine.last.value).to eq(val)
              end
            end

            context "日付データがパラメータで送られた場合" do
              let(:val){"2014-01-01"}
              let(:template_record_params){
                el = create(:element_by_it_dates)
                {
                  el.id => {
                    1 => {
                      0 => {content_id: "", value: val, template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが１件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(1)
              end

              it "ElementValue::DateContentが１件追加されること" do
                expect{subject}.to change(ElementValue::DateContent, :count).by(1)
              end

              it "追加されたElementValue::Datesのvalueが正しくセットされていること" do
                subject
                expect(ElementValue::Dates.last.value.to_s).to eq(val)
              end
            end

            context "複数選択（テンプレート）がパラメータで送られた場合" do
              let(:source){create(:template)}
              let(:val1){create(:template_record, template_id: source.id).id}
              let(:val2){create(:template_record, template_id: source.id).id}

              let(:template_record_params){
                el = create(:element_by_it_checkbox_template, source_type: "Template", source_id: source.id)
                {
                  el.id => {
                    1 => {
                      val1 => {content_id: "", value: val1, template_id: template.id}.stringify_keys
                    }.stringify_keys,
                    2 => {
                      val2 => {content_id: "", value: val2, template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが2件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(2)
              end

              it "ElementValue::CheckboxTemplateが2件追加されること" do
                expect{subject}.to change(ElementValue::CheckboxTemplate, :count).by(2)
              end

              it "追加されたElementValue::CheckboxTemplateのvalueが正しくセットされていること" do
                subject
                expect(ElementValue::CheckboxTemplate.first.value).to eq(val1)
                expect(ElementValue::CheckboxTemplate.last.value).to eq(val2)
              end
            end

            context "単一選択（テンプレート）がパラメータで送られた場合" do
              let(:source){create(:template)}
              let(:val1){create(:template_record, template_id: source.id).id}
              let(:val2){create(:template_record, template_id: source.id).id}

              let(:template_record_params){
                el = create(:element_by_it_pulldown_template, source_type: "Template", source_id: source.id)
                {
                  el.id => {
                    1 => {
                      val1 => {content_id: "", value: val1, template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが1件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(1)
              end

              it "ElementValue::IdentifierContentが1件追加されること" do
                expect{subject}.to change(ElementValue::IdentifierContent, :count).by(1)
              end

              it "追加されたElementValue::PulldownTemplateのvalueとtypeが正しくセットされていること" do
                subject
                expect(ElementValue::PulldownTemplate.first.value).to eq(val1)
              end
            end

            context "複数選択（語彙）がパラメータで送られた場合" do
              let(:voe){create(:vocabulary_element)}
              let(:val1){create(:vocabulary_element_value, element_id: voe.id).id}
              let(:val2){create(:vocabulary_element_value, element_id: voe.id).id}

              let(:template_record_params){
                el = create(:element_by_it_checkbox_vocabulary, source_type: "Vocabulary::Element", source_id: voe.id)
                {
                  el.id => {
                    1 => {
                      val1 => {content_id: "", value: val1, template_id: template.id}.stringify_keys
                    }.stringify_keys,
                    2 => {
                      val2 => {content_id: "", value: val2, template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが2件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(2)
              end

              it "ElementValue::CheckboxVocabularyが2件追加されること" do
                expect{subject}.to change(ElementValue::CheckboxVocabulary, :count).by(2)
              end

              it "追加されたElementValue::CheckboxVocabularyのvalueが正しくセットされていること" do
                subject
                expect(ElementValue::CheckboxVocabulary.first.value).to eq(val1)
                expect(ElementValue::CheckboxVocabulary.last.value).to eq(val2)
              end
            end

            context "単一選択（語彙）がパラメータで送られた場合" do
              let(:voe){create(:vocabulary_element)}
              let(:val1){create(:vocabulary_element_value, element_id: voe.id).id}

              let(:template_record_params){
                el = create(:element_by_it_pulldown_vocabulary, source_type: "Vocabulary::Element", source_id: voe.id)
                {
                  el.id => {
                    1 => {
                      val1 => {content_id: "", value: val1, template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが1件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(1)
              end

              it "ElementValue::PulldownVocabularyが1件追加されること" do
                expect{subject}.to change(ElementValue::PulldownVocabulary, :count).by(1)
              end

              it "追加されたElementValue::PulldownTemplateのvalueが正しくセットされていること" do
                subject
                expect(ElementValue::PulldownVocabulary.first.value).to eq(val1)
              end
            end

            context "国土地理院位置情報がパラメータで送られた場合" do
              let(:lon){"133.066472"}
              let(:lat){"35.442593"}

              let(:template_record_params){
                el = create(:element_by_it_kokudo_location)
                {
                  el.id => {
                    1 => {
                      1 => {content_id: "", value: lat, template_id: template.id}.stringify_keys
                    }.stringify_keys,
                    2 => {
                      2 => {content_id: "", value: lon, template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが2件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(2)
              end

              it "ElementValue::KokudoLocationが2件追加されること" do
                expect{subject}.to change(ElementValue::KokudoLocation, :count).by(2)
              end

              it "追加されたElementValue::KokudoLocationのvalueが正しくセットされていること" do
                subject
                expect(ElementValue::KokudoLocation.first.value).to eq(lat)
                expect(ElementValue::KokudoLocation.last.value).to eq(lon)
              end
            end

            context "OpenStreetMap位置情報がパラメータで送られた場合" do
              let(:lon){"133.066472"}
              let(:lat){"35.442593"}

              let(:template_record_params){
                el = create(:element_by_it_osm_location)
                {
                  el.id => {
                    1 => {
                      1 => {content_id: "", value: lat, template_id: template.id}.stringify_keys
                    }.stringify_keys,
                    2 => {
                      2 => {content_id: "", value: lon, template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが2件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(2)
              end

              it "ElementValue::OsmLocationが2件追加されること" do
                expect{subject}.to change(ElementValue::OsmLocation, :count).by(2)
              end

              it "追加されたElementValue::OsmLocationのvalueが正しくセットされていること" do
                subject
                expect(ElementValue::OsmLocation.first.value).to eq(lat)
                expect(ElementValue::OsmLocation.last.value).to eq(lon)
              end
            end

            context "GoogleMap位置情報がパラメータで送られた場合" do
              let(:lon){"133.066472"}
              let(:lat){"35.442593"}

              let(:template_record_params){
                el = create(:element_by_it_google_location)
                {
                  el.id => {
                    1 => {
                      1 => {content_id: "", value: lat, template_id: template.id}.stringify_keys
                    }.stringify_keys,
                    2 => {
                      2 => {content_id: "", value: lon, template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }
              }
              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが2件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(2)
              end

              it "ElementValue::GoogleLocationが2件追加されること" do
                expect{subject}.to change(ElementValue::GoogleLocation, :count).by(2)
              end

              it "追加されたElementValue::GoogleLocationのvalueが正しくセットされていること" do
                subject
                expect(ElementValue::GoogleLocation.first.value).to eq(lat)
                expect(ElementValue::GoogleLocation.last.value).to eq(lon)
              end
            end

            context "複数の種類のデータがパラメータで送られた場合" do
              let(:lon){"133.066472"}
              let(:lat){"35.442593"}
              let(:line1){"松江城"}
              let(:line2){"松江城天守閣"}
              let(:multiline1){"松江のお城です。国の重要文化財に指定されています。\n明治時代初頭に廃城令によって存城処分となった"}
              let(:multiline2){"お堀では堀川遊覧船に乗ることができます。"}
              let(:source){create(:template)}
              let(:c_temp){create(:template_record, template_id: source.id).id}
              let(:p_temp){create(:template_record, template_id: source.id).id}
              let(:voe){create(:vocabulary_element)}
              let(:c_voc){create(:vocabulary_element_value, element_id: voe.id).id}
              let(:p_voc){create(:vocabulary_element_value, element_id: voe.id).id}
              let(:dates1){"2014-01-01"}
              let(:dates2){"2014-02-03"}
              let(:one_value){

              }

              let(:template_record_params){
                line_el = create(:element_by_it_line)
                multiline_el = create(:element_by_it_multi_line)
                date_el = create(:element_by_it_dates)
                osm_el = create(:element_by_it_osm_location)
                kokudo_el = create(:element_by_it_kokudo_location)
                gl_el = create(:element_by_it_google_location)
                c_temp_el = create(:element_by_it_checkbox_template, source_type: "Template", source_id: source.id)
                p_temp_el = create(:element_by_it_pulldown_template, source_type: "Template", source_id: source.id)
                c_voc_el = create(:element_by_it_checkbox_vocabulary, source_type: "VocabularyElement", source_id: voe.id)
                p_voc_el = create(:element_by_it_pulldown_vocabulary, source_type: "VocabularyElement", source_id: voe.id)
                para_base = {content_id: "", template_id: template.id}.stringify_keys
                {
                  gl_el.id => { # google map
                    1 => {1 => para_base.merge("value" => lat)}.stringify_keys,
                    2 => {2 => para_base.merge("value" => lon)}.stringify_keys,
                  }.stringify_keys,
                  osm_el.id => { # OpenStreetMap
                    1 => {1 => para_base.merge("value" => lat)}.stringify_keys,
                    2 => {2 => para_base.merge("value" => lon)}.stringify_keys,
                  }.stringify_keys,
                  kokudo_el.id => { # KokudoMap
                    1 => {1 => para_base.merge("value" => lat)}.stringify_keys,
                    2 => {2 => para_base.merge("value" => lon)}.stringify_keys,
                  }.stringify_keys,
                  line_el.id => { # line
                    1 => {0 => para_base.merge(value: line1)}.stringify_keys,
                    2 => {0 => para_base.merge(value: line2)}.stringify_keys
                  }.stringify_keys,
                  multiline_el.id => { # multiline
                    1 => {0 => para_base.merge(value: multiline1)}.stringify_keys,
                    2 => {0 => para_base.merge(value: multiline2)}.stringify_keys
                  }.stringify_keys,
                  date_el.id => { # dates
                    1 => {0 => para_base.merge(value: dates1)}.stringify_keys,
                    2 => {0 => para_base.merge(value: dates2)}.stringify_keys
                  }.stringify_keys,
                  c_temp_el.id => { # checkbox template
                    1 => {1 => {content_id: "", value: c_temp, template_id: template.id}.stringify_keys}.stringify_keys
                  }.stringify_keys,
                  p_temp_el.id => { # pulldown template
                    1 => {1 => {content_id: "", value: p_temp, template_id: template.id}.stringify_keys}.stringify_keys
                  }.stringify_keys,
                  c_voc_el.id => { # checkbox vocabulary
                    1 => {1 => {content_id: "", value: c_voc, template_id: template.id}.stringify_keys}.stringify_keys
                  }.stringify_keys,
                  p_voc_el.id => { # pulldown vocabulary
                    1 => {1 => {content_id: "", value: p_voc, template_id: template.id}.stringify_keys}.stringify_keys
                  }.stringify_keys
                }
              }

              subject{post :create, template_id: template.id, template_record: template_record_params}

              it "ElementValueが16件追加されること" do
                expect{subject}.to change(ElementValue, :count).by(16)
              end

              [ElementValue::GoogleLocation, ElementValue::OsmLocation, ElementValue::KokudoLocation].each do |klass|
                it "#{klass.name}が2件追加されること" do
                  expect{subject}.to change(klass, :count).by(2)
                end

                it "追加された#{klass.name}のvalueが正しくセットされていること" do
                  subject
                  expect(klass.first.value).to eq(lat)
                  expect(klass.last.value).to eq(lon)
                end
              end

              let(:one_data){
                {
                  ElementValue::Line => [line1, line2],
                  ElementValue::MultiLine => [multiline1, multiline2],
                  ElementValue::Dates => [dates1, dates2],
                  ElementValue::PulldownTemplate => [p_temp],
                  ElementValue::CheckboxTemplate => [c_temp],
                  ElementValue::PulldownVocabulary => [p_voc],
                  ElementValue::CheckboxVocabulary => [c_voc]
                }
              }

              {
                ElementValue::Line => 2,
                ElementValue::MultiLine => 2,
                ElementValue::Dates => 2,
                ElementValue::PulldownTemplate => 1,
                ElementValue::CheckboxTemplate => 1,
                ElementValue::PulldownVocabulary => 1,
                ElementValue::CheckboxVocabulary => 1
              }.each do |klass, size|

                it "#{klass.name}が#{size}件追加されること" do
                  expect{subject}.to change(klass, :count).by(size)
                end

                it "追加された#{klass.name}のvalueが正しくセットされていること" do
                  subject
                  size.times do |i|
                    expect(klass.all[i].value).to eq(one_data[klass][i])
                  end
                end
              end
            end
          end
        end
      end

      describe "異常系" do
        shared_examples_for "エラー発生時の処理" do
          it "newが呼ばれること" do
            controller.should_receive(:new)
            subject
          end

          it "newがrenderされること" do
            expect(subject).to render_template(:new)
          end

          it "レコードが追加されないこと" do
            expect{subject}.to_not change(TemplateRecord, :count).by(1)
          end
        end

        context "バリデーションに失敗した場合" do
          let(:tr_params){{}}
          subject{post :create, template_id: template.id, template_record: tr_params}
          before{TemplateRecord.any_instance.stub(:valid?){false}}
          it_behaves_like("エラー発生時の処理")
        end

        context "桁数制限の項目の確認" do
          let(:para_base){{content_id: "", template_id: template.id}.stringify_keys}

          context "１行入力欄" do
            context "最大桁数制限に反する値が入力された場合" do
              let(:el){create(:element_by_it_line, template_id: template.id, max_digit_number: 5)}

              context "入力した文字列の桁数が超えている場合" do
                let(:tr_params){
                  {
                    el.id => {1 => {0 => para_base.merge("value" => "小泉八雲記念館")}.stringify_keys}.stringify_keys
                  }.stringify_keys
                }

                subject{post :create, template_id: template.id, template_record: tr_params}

                it_behaves_like("エラー発生時の処理")
              end
            end

            context "最小桁数制限に反する値が入力された場合" do
              let(:el){create(:element_by_it_line, template_id: template.id, min_digit_number: 5)}

              context "入力した文字列の桁数が小さい場合" do
                let(:tr_params){
                  {
                    el.id => {1 => {0 => para_base.merge("value" => "松江城")}.stringify_keys}.stringify_keys
                  }.stringify_keys
                }

                subject{post :create, template_id: template.id, template_record: tr_params}

                it_behaves_like("エラー発生時の処理")
              end
            end

            context "最大桁数制限と最小桁数制限が等しい場合に反する値が入力された場合" do
              let(:el){create(:element_by_it_line, template_id: template.id, min_digit_number: 5, max_digit_number: 5)}

              context "入力した文字列の桁数が小さい場合" do
                let(:tr_params){
                  {
                    el.id => {1 => {0 => para_base.merge("value" => "松江城")}.stringify_keys}.stringify_keys
                  }.stringify_keys
                }

                subject{post :create, template_id: template.id, template_record: tr_params}

                it_behaves_like("エラー発生時の処理")
              end
            end
          end

          context "複数行入力" do
            context "最大桁数制限に反する値が入力された場合" do
              let(:value){"松江城の城下町です。\nとてもきれいな町並みです。"}
              let(:el){create(:element_by_it_multi_line, template_id: template.id, max_digit_number: value.length)}

              context "入力した文字列の桁数が超えている場合" do
                let(:val){"小泉八雲記念館です。\n島根県松江市の塩見繩手にあります。"}
                let(:tr_params){
                  {
                    el.id => {1 => {0 => para_base.merge("value" => val)}.stringify_keys}.stringify_keys
                  }.stringify_keys
                }

                subject{post :create, template_id: template.id, template_record: tr_params}

                it_behaves_like("エラー発生時の処理")
              end
            end

            context "最小桁数制限に反する値が入力された場合" do
              let(:value){"小泉八雲記念館です。\n島根県松江市の塩見繩手にあります。"}
              let(:el){create(:element_by_it_multi_line, template_id: template.id, min_digit_number: value.length)}

              context "入力した文字列の桁数が制限より小さい場合" do
                let(:val){"松江城の城下町です。\nとてもきれいな町並みです。"}
                let(:tr_params){
                  {
                    el.id => {1 => {0 => para_base.merge("value" => val)}.stringify_keys}.stringify_keys
                  }.stringify_keys
                }

                subject{post :create, template_id: template.id, template_record: tr_params}

                it_behaves_like("エラー発生時の処理")
              end
            end

            context "最大桁数制限と最小桁数制限が等しい場合に反する値が入力された場合" do
              let(:value){"小泉八雲記念館です。\n島根県松江市の塩見繩手にあります。"}
              let(:el){create(:element_by_it_multi_line, template_id: template.id, min_digit_number: value.length, max_digit_number: value.length)}

              context "入力した文字列の桁数が制限より小さい場合" do
                let(:val){"松江城の城下町です。\nとてもきれいな町並みです。"}
                let(:tr_params){
                  {
                    el.id => {1 => {0 => para_base.merge("value" => val)}.stringify_keys}.stringify_keys
                  }.stringify_keys
                }

                subject{post :create, template_id: template.id, template_record: tr_params}

                it_behaves_like("エラー発生時の処理")
              end
            end
          end
        end

        context "重複不可の項目の確認" do
          let(:parent){create(:template, service_id: service.id)}
          let(:para_base){{content_id: "", template_id: template.id}.stringify_keys}

          context "１行入力欄に重複する値が入力された場合" do
            let(:el){create(:element_by_it_line, template_id: template.id, unique: true)}
            let(:value){"松江城"}
            let(:tr_params){
              {
                el.id => {1 => {0 => para_base.merge(value: value)}.stringify_keys}.stringify_keys
              }.stringify_keys
            }

            subject{post :create, template_id: template.id, template_record: tr_params}
            context "同テンプレートに重複する場合がある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id,
                    content: build(:element_value_line, value: value))])
                tr.save
              end

              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複する場合がある場合" do
              before do
                template.update!(parent_id: parent.id, service_id: service.id)
                el.update!(template_id: parent.id)

                tr = build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id,
                    content: build(:element_value_line, value: value))])
                tr.save
              end

              it_behaves_like("エラー発生時の処理")
            end
          end

          context "複数行入力欄に重複する値が入力された場合" do
            let(:el){create(:element_by_it_multi_line, template_id: template.id, unique: true)}
            let(:value){"松江城です。\n松江のお城ですよ"}
            let(:tr_params){
              {
                el.id => {1 => {0 => para_base.merge("value" => value)}.stringify_keys}.stringify_keys
              }.stringify_keys
            }
            subject{post :create, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id,
                    content: build(:element_value_multi_line, value: value))])
                tr.save
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                tr = build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id,
                    content: build(:element_value_multi_line, value: value))])
                tr.save
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "日付入力欄に重複する値が入力された場合" do
            let(:el){create(:element_by_it_dates, template_id: template.id, unique: true)}
            let(:value){"2014-01-01"}
            let(:tr_params){
              {
                el.id => {1 => {0 => para_base.merge(value: value)}.stringify_keys}.stringify_keys
              }.stringify_keys
            }

            let(:content){build(:element_value_dates, value: value)}

            subject{post :create, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id,
                    content: content)])
                tr.save
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                tr = build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id,
                    content: content)])
                tr.save
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "国土地理院位置情報入力欄に重複する値が入力された場合" do
            let(:lat_c){create(:element_value_kokudo_location_lat)}
            let(:lon_c){create(:element_value_kokudo_location_lon)}
            let(:el){create(:element_by_it_kokudo_location, template_id: template.id, unique: true)}
            let(:tr_params){
              {
                el.id => {
                  1 => {ElementValue::KINDS[:kokudo_location][:latitude] => para_base.merge(value: lat_c.value)}.stringify_keys,
                  2 => {ElementValue::KINDS[:kokudo_location][:longitude] => para_base.merge(value: lon_c.value)}.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }

            subject{post :create, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:kokudo_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:kokudo_location][:latitude], content: lat_c)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                tr = build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:kokudo_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:kokudo_location][:latitude], content: lat_c)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "GoogleMap位置情報入力欄に重複する値が入力された場合" do
            let(:lat_c){create(:element_value_google_location_lat)}
            let(:lon_c){create(:element_value_google_location_lon)}
            let(:el){create(:element_by_it_google_location, template_id: template.id, unique: true)}
            let(:tr_params){
              {
                el.id => {
                  1 => {ElementValue::KINDS[:google_location][:latitude] => para_base.merge(value: lat_c.value)}.stringify_keys,
                  2 => {ElementValue::KINDS[:google_location][:longitude] => para_base.merge(value: lon_c.value)}.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }

            subject{post :create, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:google_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:google_location][:latitude], content: lat_c)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                tr = build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:google_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:google_location][:latitude], content: lat_c)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "OpenStreetMap位置情報入力欄に重複する値が入力された場合" do
            let(:lat_c){create(:element_value_osm_location_lat)}
            let(:lon_c){create(:element_value_osm_location_lon)}
            let(:el){create(:element_by_it_osm_location, template_id: template.id, unique: true)}
            let(:tr_params){
              {
                el.id => {
                1 => {ElementValue::KINDS[:osm_location][:latitude] => para_base.merge(value: lat_c.value)}.stringify_keys,
                2 => {ElementValue::KINDS[:osm_location][:longitude] => para_base.merge(value: lon_c.value)}.stringify_keys
                }.stringify_keys
              }
            }

            subject{post :create, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:osm_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:osm_location][:latitude], content: lat_c)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                tr = build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:osm_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:osm_location][:latitude], content: lat_c)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "チェックボックス（テンプレート）情報入力欄に重複する値が入力された場合" do
            let(:source){create(:template)}
            let(:source_el){create(:element_by_it_line, template_id: source.id)}
            let(:tr1){create(:template_record, template_id: source.id)}
            let(:tr2){create(:template_record, template_id: source.id)}
            let(:el){create(:element_by_it_checkbox_template, template_id: template.id, unique: true, source: source, source_element: source_el)}
            let(:tr_params){
              {
                el.id => {
                  1 => {tr1.id => para_base.merge("value" => tr1.id)}.stringify_keys,
                  2 => {tr2.id => para_base.merge("value" => tr2.id)}.stringify_keys
                }.stringify_keys
              }
            }
            let(:con1){build(:element_value_checkbox_template, value: tr1.id)}
            let(:con2){build(:element_value_checkbox_template, value: tr2.id)}

            subject{post :create, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: tr1.id, content: con1),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: tr2.id, content: con2)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                tr = build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: tr1.id, content: con1),
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: tr2.id, content: con2)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "単一選択（テンプレート）情報入力欄に重複する値が入力された場合" do
            let(:source){create(:template)}
            let(:source_el){create(:element_by_it_line, template_id: source.id)}
            let(:tr1){create(:template_record, template_id: source.id)}
            let(:el){create(:element_by_it_checkbox_template, template_id: template.id, unique: true, source: source, source_element: source_el)}
            let(:tr_params){
              {
                el.id => {
                  1 => {tr1.id => para_base.merge("value" => tr1.id)}.stringify_keys
                }.stringify_keys
              }
            }
            let(:content){build(:element_value_pulldown_template, value: tr1.id)}
            subject{post :create, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id, kind: tr1.id, content: content)])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                tr = build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id, kind: tr1.id, content: content)])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "チェックボックス（語彙）情報入力欄に重複する値が入力された場合" do
            let(:source){create(:vocabulary_element)}
            let(:vev1){create(:vocabulary_element_value, element_id: source.id)}
            let(:vev2){create(:vocabulary_element_value, element_id: source.id)}
            let(:el){create(:element_by_it_checkbox_vocabulary, template_id: template.id, unique: true, source: source)}
            let(:tr_params){
              {
                el.id => {
                  1 => {vev1.id => para_base.merge("value" => vev1.id)}.stringify_keys,
                  2 => {vev2.id => para_base.merge("value" => vev2.id)}.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }
            let(:con1){build(:element_value_checkbox_vocabulary, value: vev1.id)}
            let(:con2){build(:element_value_checkbox_vocabulary, value: vev2.id)}
            subject{post :create, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: vev1.id, content: con1),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: vev2.id, content: con2)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                tr = build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: vev1.id, content: con1),
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: vev2.id, content: con2)
                  ])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "単一選択（テンプレート）情報入力欄に重複する値が入力された場合" do
            let(:source){create(:vocabulary_element)}
            let(:vev1){create(:vocabulary_element_value, element_id: source.id)}
            let(:el){create(:element_by_it_checkbox_vocabulary, template_id: template.id, unique: true, source: source)}
            let(:tr_params){
              {
                el.id => {
                  1 => {vev1.id => para_base.merge("value" => vev1.id)}.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }
            let(:content){build(:element_value_pulldown_vocabulary, value: vev1.id)}

            subject{post :create, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                tr = build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id, kind: vev1.id, content: content)])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                tr = build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id, kind: vev1.id, content: content)])
                tr.save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end
        end

        context "必須入力項目が未入力の場合" do
          [{key: "line", val: "１行入力欄", content_type: "ElementValue::StringContent"},
            {key: "multi_line", val: "複数行入力欄", content_type: "ElementValue::TextContent"},
            {key: "dates", val: "日付入力欄", content_type: "ElementValue::DateContent"}].each do |hash|
            context "#{hash[:val]}が必須入力の場合で未入力の場合" do
              let(:tr_params){
                el = create(:"element_by_it_#{hash[:key]}", template_id: template.id, required: true)
                {
                  el.id => {1 => {0 => {value: "", content_id: "", template_id: template.id}.stringify_keys}.stringify_keys}.stringify_keys
                }.stringify_keys
              }

              subject{post :create, template_id: template.id, template_record: tr_params}

              it_behaves_like("エラー発生時の処理")
            end
          end

          {kokudo_location: "国土地理院位置情報", osm_location: "OpenStreetMap位置情報", google_location: "Google位置情報"}.each do |key, val|
            context "#{val}入力欄が必須入力の場合で未入力の場合" do
              let(:tr_params){
                el = create(:"element_by_it_#{key}", template_id: template.id, required: true)
                {
                  el.id => {
                    1 => {ElementValue::KINDS[key][:latitude] => {value: "", content_id: "", template_id: template.id}}.stringify_keys,
                    2 => {ElementValue::KINDS[key][:longitude] => {value: "", content_id: "", template_id: template.id}}.stringify_keys
                  }
                }.stringify_keys
              }

              subject{post :create, template_id: template.id, template_record: tr_params}
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "チェックボックス（テンプレート）入力欄が必須項目で１つも選択していない場合" do
            let(:source){create(:template)}
            let(:val1){create(:template_record, template_id: source.id).id}
            let(:val2){create(:template_record, template_id: source.id).id}

            let(:tr_params){
              el = create(:"element_by_it_checkbox_template", template_id: template.id, required: true, source: source)
              {
                el.id => {
                  1 => {val1 => {content_id: "", template_id: template.id, value: ""}.stringify_keys}.stringify_keys,
                  2 => {val2 => {content_id: "", template_id: template.id, value: ""}.stringify_keys}.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }

            subject{post :create, template_id: template.id, template_record: tr_params}
            it_behaves_like("エラー発生時の処理")
          end

          context "プルダウン（テンプレート）入力欄が必須項目で１つも選択していない場合" do
            let(:source){create(:template)}

            let(:tr_params){
              el = create(:"element_by_it_pulldown_template", template_id: template.id, required: true, source: source)
              {
                el.id => {
                  1 => {0 => {content_id: "", template_id: template.id, value: ""}.stringify_keys}.stringify_keys
                }
              }
            }

            subject{post :create, template_id: template.id, template_record: tr_params}
            it_behaves_like("エラー発生時の処理")
          end

          context "チェックボックス（語彙）入力欄が必須項目で１つも選択していない場合" do
            let(:ve){create(:vocabulary_element)}
            let(:val1){create(:vocabulary_element_value, element_id: ve.id).id}
            let(:val2){create(:vocabulary_element_value, element_id: ve.id).id}

            let(:tr_params){
              el = create(:"element_by_it_checkbox_vocabulary", template_id: template.id, required: true, source: ve)
              {
                el.id => {
                  1 => {val1 => {content_id: "", template_id: template.id, value: ""}.stringify_keys}.stringify_keys,
                  2 => {val2 => {content_id: "", template_id: template.id, value: ""}.stringify_keys}.stringify_keys
                }
              }.stringify_keys
            }

            subject{post :create, template_id: template.id, template_record: tr_params}
            it_behaves_like("エラー発生時の処理")
          end

          context "プルダウン（テンプレート）入力欄が必須項目で１つも選択していない場合" do
            let(:ve){create(:vocabulary_element)}

            let(:tr_params){
              el = create(:"element_by_it_pulldown_template", template_id: template.id, required: true, source: ve)
              {
                el.id => {
                  1 => {
                    0 => {content_id: "", template_id: template.id, value: ""}.stringify_keys
                  }.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }

            subject{post :create, template_id: template.id, template_record: tr_params}
            it_behaves_like("エラー発生時の処理")
          end
        end
      end
    end

    describe "GET edit" do
      subject{get :edit, id: template_record.id, template_id: template.id}
      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "editがrenderされること" do
          expect(subject).to render_template(:edit)
        end

        it "set_form_assigsnが呼ばれること" do
          controller.should_receive(:set_form_assigns)
          subject
        end
      end
    end

    describe "PATCH update" do
      let(:tr){create(:tr_with_all_values, template_id: template.id)}
      before do
        tr # let call
      end
      let(:tr_params){
        hash = {}
        tr.values.each.with_index(1) do |v, i|
          value = v.content.attributes["value"]
          case v.content.class.superclass.name
          when ElementValue::StringContent.name, ElementValue::TextContent.name
            value = value + "0"
          when ElementValue::IdentifierContent.name, ElementValue::DateContent.name
            value = value + 1
          end

          attr = {
            i => {
              v.kind.to_i => {
                id: v.id, content_id: v.content_id, value: value, template_id: template.id
              }.stringify_keys
            }.stringify_keys
          }.stringify_keys

          if hash.has_key?(v.element_id.to_s)
            hash[v.element_id.to_s].merge!(attr)
          else
            hash[v.element_id.to_s] = attr
          end
        end
        hash
      }

      subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}
      describe "正常系" do
        context "バリデーションに成功した場合" do
          before{TemplateRecord.any_instance.stub(:valid?){true}}

          it "indexへリダイレクトすること" do
            expect(subject).to redirect_to(template_records_path(template_id: template.id))
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.update_after")
            expect(flash[:notice]).to eq(msg)
          end

          context "各データの更新の確認" do
            [ElementValue::Line,
              ElementValue::MultiLine,
              ElementValue::KokudoLocation,
              ElementValue::OsmLocation,
              ElementValue::GoogleLocation].each do |klass|
              it "#{klass.name}の値が更新されていること" do
                values = klass.pluck(:value)
                results = values.map{|a|a + "0"}
                expect{subject}.to change{klass.pluck(:value)}.from(values).to(results)
              end
            end

            [ElementValue::CheckboxTemplate,
              ElementValue::PulldownTemplate,
              ElementValue::CheckboxVocabulary,
              ElementValue::PulldownVocabulary,
              ElementValue::Dates].each do |klass|
              it "#{klass.name}の値が更新されていること" do
                values = klass.pluck(:value)
                results = values.map{|a|a + 1}
                expect{subject}.to change{klass.pluck(:value)}.from(values).to(results)
              end
            end
          end
        end
      end

      describe "異常系" do
        shared_examples_for "エラー発生時の処理" do
          it "editが呼ばれること" do
            controller.should_receive(:edit)
            subject
          end

          it "editがrenderされること" do
            expect(subject).to render_template(:edit)
          end
        end

        context "バリデーションに失敗した場合" do
          before{TemplateRecord.any_instance.stub(:valid?){false}}

          it_behaves_like("エラー発生時の処理")
        end

        context "桁数制限の項目の確認" do
          let(:para_base){{content_id: "", template_id: template.id}.stringify_keys}

          context "１行入力欄に桁数制限に反する値が入力された場合" do
            let(:el){create(:element_by_it_line, template_id: template.id, max_digit_number: 5)}
            let(:content){build(:element_value_line, value: "県立美術館")}
            let(:ev){build(:element_value, element_id: el.id, content: content)}
            let(:tr){create(:template_record, template_id: template.id, values: [ev], user_id: current_user.id)}

            context "入力した文字列の桁数が超えている場合" do
              let(:tr_params){
                {
                  el.id => {
                    1 => {0 => para_base.merge(value: "小泉八雲記念館")}.stringify_keys
                  }.stringify_keys
                }.stringify_keys
              }

              subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

              it_behaves_like("エラー発生時の処理")
            end
          end

          context "複数行入力欄に桁数制限に反する値が入力された場合" do
            let(:value){"松江城の城下町です。\nとてもきれいな町並みです。"}
            let(:el){create(:element_by_it_multi_line, template_id: template.id, max_digit_number: value.length)}
            let(:content){build(:element_value_multi_line, value: value)}
            let(:ev){build(:element_value, content: content, element_id: el.id, template_id: template.id)}
            let(:tr){create(:template_record, template_id: template.id, values: [ev], user_id: current_user.id)}

            context "入力した文字列の桁数が超えている場合" do
              let(:val){"小泉八雲記念館です。\n島根県松江市の塩見繩手にあります。"}
              let(:tr_params){
                {
                  el.id => {1 => {0 => para_base.merge(value: val)}.stringify_keys}.stringify_keys
                }.stringify_keys
              }

              subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

              it_behaves_like("エラー発生時の処理")
            end
          end
        end

        context "重複不可の項目の確認" do
          let(:parent){create(:template, service_id: service.id)}
          let(:para_base){{template_id: template.id}.stringify_keys}

          context "１行入力欄に重複する値が入力された場合" do
            let(:el){create(:element_by_it_line, template_id: template.id, unique: true)}
            let(:content){build(:element_value_line, value: "県立美術館")}
            let(:ev){build(:element_value, element_id: el.id, content: content)}
            let(:tr){create(:template_record, template_id: template.id, values: [ev], user_id: current_user.id)}

            let(:tr_params){
              {
                el.id => {1 => {0 => para_base.merge(content_id: content.id, value: "松江城")}.stringify_keys}.stringify_keys
              }.stringify_keys
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複する場合がある場合" do
              before do
                build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id,
                    content: build(:element_value_line, value: "松江城"))]).save
              end

              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複する場合がある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)

                build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id,
                    content: build(:element_value_line, value: "松江城"))]).save
              end

              it_behaves_like("エラー発生時の処理")
            end
          end

          context "複数行入力欄に重複する値が入力された場合" do
            let(:el){create(:element_by_it_multi_line, template_id: template.id, unique: true)}
            let(:value){"松江城です。\n松江のお城ですよ"}
            let(:content){build(:element_value_multi_line, value: "松江城です。")}
            let(:ev){build(:element_value, content: content, element_id: el.id, template_id: template.id)}
            let(:tr){create(:template_record, template_id: template.id, values: [ev], user_id: current_user.id)}
            let(:tr_params){
              {
                el.id => {1 => {0 => para_base.merge(content_id: content.id, value: value)}.stringify_keys}.stringify_keys
              }.stringify_keys
            }
            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id,
                    content: build(:element_value_multi_line, value: value))]).save
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id,
                    content: build(:element_value_multi_line, value: value))]).save
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "日付入力欄に重複する値が入力された場合" do
            let(:el){create(:element_by_it_dates, template_id: template.id, unique: true)}
            let(:content){build(:element_value_dates, value: "2014-02-02")}
            let(:ev){build(:element_value, content: content, element_id: el.id, template_id: template.id)}
            let(:tr){create(:template_record, template_id: template.id, values: [ev], user_id: current_user.id)}
            let(:tr_params){
              {
                el.id => {1 => {0 => para_base.merge(content_id: content.id, value: "2014-01-01")}.stringify_keys}.stringify_keys
              }.stringify_keys
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id,
                    content: build(:element_value_dates, value: "2014-01-01"))]).save
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id,
                    content: build(:element_value_dates, value: "2014-01-01"))]).save

              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "国土地理院位置情報入力欄に重複する値が入力された場合" do
            let(:lat_c){create(:element_value_kokudo_location_lat)}
            let(:lon_c){create(:element_value_kokudo_location_lon)}
            let(:el){create(:element_by_it_kokudo_location, template_id: template.id, unique: true)}

            let(:contents){["123.456", "654.321"].map{|v|build(:element_value_kokudo_location, value: v)}}
            let(:evs){contents.map{|c|build(:element_value, content: c, element_id: el.id, template_id: template.id)}}
            let(:tr){create(:template_record, values: evs, template_id: template.id, user_id: current_user.id)}
            let(:tr_params){
              {
                el.id => {
                  1 => {
                    ElementValue::KINDS[:kokudo_location][:latitude] => para_base.merge(id: evs[0].id, content_id: contents[0].id, value: lat_c.value)
                  }.stringify_keys,
                  2 => {
                    ElementValue::KINDS[:kokudo_location][:longitude] => para_base.merge(id: evs[1].id, content_id: contents[0].id, value: lon_c.value)
                  }.stringify_keys
                }
              }.stringify_keys
            }
            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:kokudo_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:kokudo_location][:latitude], content: lat_c)
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:kokudo_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:kokudo_location][:latitude], content: lat_c)
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "GoogleMap位置情報入力欄に重複する値が入力された場合" do
            let(:lat_c){create(:element_value_google_location_lat)}
            let(:lon_c){create(:element_value_google_location_lon)}
            let(:el){create(:element_by_it_google_location, template_id: template.id, unique: true)}

            let(:contents){["123.456", "654.321"].map{|v|build(:element_value_google_location, value: v)}}
            let(:evs){contents.map{|c|build(:element_value, content: c, element_id: el.id, template_id: template.id)}}
            let(:tr){create(:template_record, values: evs, template_id: template.id, user_id: current_user.id)}
            let(:tr_params){
              {
                el.id => {
                  1 => {
                    ElementValue::KINDS[:google_location][:latitude] => para_base.merge(id: evs[0].id, content_id: contents[0].id, value: lat_c.value)
                  }.stringify_keys,
                  2 => {
                    ElementValue::KINDS[:google_location][:longitude] => para_base.merge(id: evs[1].id, content_id: contents[0].id, value: lon_c.value)
                  }.stringify_keys
                }
              }.stringify_keys
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:google_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:google_location][:latitude], content: lat_c)
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:google_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:google_location][:latitude], content: lat_c)
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "OpenStreetMap位置情報入力欄に重複する値が入力された場合" do
            let(:lat_c){create(:element_value_osm_location_lat)}
            let(:lon_c){create(:element_value_osm_location_lon)}
            let(:el){create(:element_by_it_osm_location, template_id: template.id, unique: true)}

            let(:contents){["123.456", "654.321"].map{|v|build(:element_value_osm_location, value: v)}}
            let(:evs){contents.map{|c|build(:element_value, content: c, element_id: el.id, template_id: template.id)}}
            let(:tr){create(:template_record, values: evs, template_id: template.id, user_id: current_user.id)}
            let(:tr_params){
              {
                el.id => {
                  1 => {
                    ElementValue::KINDS[:osm_location][:latitude] => para_base.merge(id: evs[0].id, content_id: contents[0].id, value: lat_c.value)
                  }.stringify_keys,
                  2 => {
                    ElementValue::KINDS[:osm_location][:longitude] => para_base.merge(id: evs[1].id, content_id: contents[0].id, value: lon_c.value)
                  }.stringify_keys
                }
              }.stringify_keys
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:osm_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: ElementValue::KINDS[:osm_location][:latitude], content: lat_c)
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:osm_location][:longitude], content: lon_c),
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: ElementValue::KINDS[:osm_location][:latitude], content: lat_c)
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "チェックボックス（テンプレート）情報入力欄に重複する値が入力された場合" do
            let(:source){create(:template)}
            let(:source_el){create(:element_by_it_line, template_id: source.id)}
            let(:tr1){create(:template_record, template_id: source.id)}
            let(:tr2){create(:template_record, template_id: source.id)}
            let(:tr3){create(:template_record, template_id: source.id)}
            let(:el){create(:element_by_it_checkbox_template, unique: true, source: source, source_element: source_el)}
            let(:contents){[tr2,tr3].map{|a|build(:element_value_checkbox_template, value: a.id)}}
            let(:evs){contents.map{|a|build(:element_value, content: a, element_id: el.id, template_id: template.id)}}
            let(:tr){create(:template_record, values: evs, template_id: template.id, user_id: current_user.id)}

            let(:tr_params){
              {
                el.id => {
                  1 => {
                    tr1.id => para_base.merge({content_id: "", value: tr1.id}.stringify_keys)
                  }.stringify_keys,
                  2 => {
                    tr2.id => para_base.merge({id: evs[0].id, content_id: contents[0].id, value: tr2.id}.stringify_keys)
                  }.stringify_keys,
                  3 => {
                    tr3.id => para_base.merge({id: evs[1].id, content_id: contents[1].id, value: ""}.stringify_keys)
                  }.stringify_keys
                }
              }.stringify_keys
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                el.update!(template_id: template.id)
                build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: tr1.id,
                      content: build(:element_value_checkbox_template, value: tr1.id)),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: tr2.id,
                      content: build(:element_value_checkbox_template, value: tr2.id))
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update!(parent_id: parent.id, service_id: service.id)
                el.update!(template_id: parent.id)
                build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: tr1.id,
                      content: build(:element_value_checkbox_template, value: tr1.id)),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: tr2.id,
                      content: build(:element_value_checkbox_template, value: tr2.id))
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "単一選択（テンプレート）情報入力欄に重複する値が入力された場合" do
            let(:source){create(:template)}
            let(:source_el){create(:element_by_it_line, template_id: source.id)}
            let(:tr1){create(:template_record, template_id: source.id)}
            let(:tr2){create(:template_record, template_id: source.id)}
            let(:el){create(:element_by_it_checkbox_template, unique: true, source: source, source_element: source_el)}
            let(:content){build(:element_value_checkbox_template, value: tr2.id)}
            let(:ev){build(:element_value, content: content, element_id: el.id, template_id: template.id)}
            let(:tr){create(:template_record, values: [ev], template_id: template.id, user_id: current_user.id)}
            let(:tr_params){
              {
                el.id => {
                  1 => {
                    0 => para_base.merge(id: ev.id, content_id: content.id, value: tr1.id).stringify_keys
                  }.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }
            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                el.update!(template_id: template.id)
                build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id, kind: tr1.id,
                      content: build(:element_value_pulldown_template, value: tr1.id))]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update!(parent_id: parent.id, service_id: service.id)
                el.update!(template_id: parent.id)
                build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id, kind: tr1.id,
                    content: build(:element_value_pulldown_template, value: tr1.id))]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "チェックボックス（語彙）情報入力欄に重複する値が入力された場合" do
            let(:source){create(:vocabulary_element)}
            let(:vev1){create(:vocabulary_element_value, element_id: source.id)}
            let(:vev2){create(:vocabulary_element_value, element_id: source.id)}
            let(:vev3){create(:vocabulary_element_value, element_id: source.id)}
            let(:el){create(:element_by_it_checkbox_vocabulary, template_id: template.id, unique: true, source: source)}
            let(:contents){[vev2,vev3].map{|a|build(:element_value_checkbox_vocabulary, value: a.id)}}
            let(:evs){contents.map{|a|build(:element_value, content: a, element_id: el.id, template_id: template.id)}}
            let(:tr){create(:template_record, values: evs, template_id: template.id, user_id: current_user.id)}
            let(:tr_params){
              {
                el.id => {
                  1 => {
                    vev1 => para_base.merge(value: vev1.id).stringify_keys
                  }.stringify_keys,
                  2 => {
                    vev2 => para_base.merge(id: evs[0].id, content_id: contents[0].id, value: vev2.id).stringify_keys
                  }.stringify_keys,
                  2 => {
                    vev3 => para_base.merge(id: evs[1].id, content_id: contents[1].id, value: "").stringify_keys
                  }.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }
            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                build(:template_record, template_id: template.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: template.id, kind: vev1.id,
                      content: build(:element_value_checkbox_vocabulary, value: vev1.id)),
                    build(:element_value, element_id: el.id, template_id: template.id, kind: vev2.id,
                      content: build(:element_value_checkbox_vocabulary, value: vev2.id))
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                build(:template_record, template_id: parent.id,
                  values: [
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: vev1.id,
                      content: build(:element_value_checkbox_vocabulary, value: vev1.id)),
                    build(:element_value, element_id: el.id, template_id: parent.id, kind: vev2.id,
                      content: build(:element_value_checkbox_vocabulary, value: vev2.id))
                  ]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "単一選択（テンプレート）情報入力欄に重複する値が入力された場合" do
            let(:source){create(:vocabulary_element)}
            let(:vev1){create(:vocabulary_element_value, element_id: source.id)}
            let(:vev2){create(:vocabulary_element_value, element_id: source.id)}
            let(:el){create(:element_by_it_checkbox_vocabulary, template_id: template.id, unique: true, source: source)}
            let(:content){build(:element_value_checkbox_template, value: vev2.id)}
            let(:ev){build(:element_value, content: content, element_id: el.id, template_id: template.id)}
            let(:tr){create(:template_record, values: [ev], template_id: template.id, user_id: current_user.id)}
            let(:tr_params){
              {
                el.id => {
                  1 => {
                    0 => para_base.merge({id: ev.id, content_id: content.id, value: vev1.id}.stringify_keys)
                  }.stringify_keys
                }.stringify_keys
              }
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

            context "同テンプレートに重複するデータがある場合" do
              before do
                build(:template_record, template_id: template.id,
                  values: [build(:element_value, element_id: el.id, template_id: template.id, kind: vev1.id,
                      content: build(:element_value_pulldown_vocabulary, value: vev1.id))]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end

            context "親テンプレートに重複するデータがある場合" do
              before do
                template.update(parent_id: parent.id, service_id: service.id)
                el.update(template_id: parent.id)
                build(:template_record, template_id: parent.id,
                  values: [build(:element_value, element_id: el.id, template_id: parent.id, kind: vev1.id,
                      content: build(:element_value_pulldown_vocabulary, value: vev1.id))]).save!
              end
              it_behaves_like("エラー発生時の処理")
            end
          end
        end

        context "必須入力項目が未入力の場合" do
          [{key: "line", val: "１行入力欄", content_type: "ElementValue::StringContent", value: "松江城"},
            {key: "multi_line", val: "複数行入力欄", content_type: "ElementValue::TextContent", value: "松江のお城です。\nとてもきれいです。"},
            {key: "dates", val: "日付入力欄", content_type: "ElementValue::DateContent", value: "2014-01-01"}].each do |hash|
            context "#{hash[:val]}が必須入力の場合で未入力の場合" do
              let(:el){create(:"element_by_it_#{hash[:key]}", template_id: template.id, required: true)}
              let(:content){create(:"element_value_#{hash[:key]}", value: hash[:value])}
              let(:ev){create(:element_value, template_id: template.id, content: content)}
              let(:tr){create(:template_record, values: [ev])}

              let(:tr_params){
                {
                  el.id => {
                    1 => {
                      0 => {id: ev.id.to_s, content_id: content.id, value: "", template_id: template.id}.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }.stringify_keys
              }

              subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}

              it_behaves_like("エラー発生時の処理")
            end
          end

          {kokudo_location: "国土地理院位置情報", osm_location: "OpenStreetMap位置情報", google_location: "Google位置情報"}.each do |key, val|
            context "#{val}入力欄が必須入力の場合で未入力の場合" do
              let(:el){create(:"element_by_it_#{key}", template_id: template.id, required: true)}
              let(:lon_content){create(:"element_value_#{key}_lon")}
              let(:lat_content){create(:"element_value_#{key}_lat")}
              let(:lon_ev){create(:element_value, content: lon_content, element_id: el.id, template_id: template.id)}
              let(:lat_ev){create(:element_value, content: lat_content, element_id: el.id, template_id: template.id)}
              let(:tr){create(:template_record, template_id: template.id, values: [lat_ev, lon_ev])}
              let(:tr_params){
                {
                  el.id => {
                    1 => {
                      ElementValue::KINDS[key][:latitude] => {
                        value: "", content_id: "", template_id: template.id, id: lat_ev.id
                      }.stringify_keys,
                      ElementValue::KINDS[key][:longitude] => {
                        value: "", content_id: "", template_id: template.id, id: lon_ev.id
                      }.stringify_keys
                    }.stringify_keys
                  }.stringify_keys
                }.stringify_keys
              }

              subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}
              it_behaves_like("エラー発生時の処理")
            end
          end

          context "チェックボックス（テンプレート）入力欄が必須項目で１つも選択していない場合" do
            let(:source){create(:template)}
            let(:se){create(:element_by_it_line, template_id: source.id)}
            let(:el){create(:element_by_it_checkbox_template, template_id: template.id, required: true, source: source, source_element_id: se.id)}
            let(:val1){create(:template_record, template_id: source.id).id}
            let(:val2){create(:template_record, template_id: source.id).id}
            # content1~trまでは既存データの作成
            let(:content1){create(:element_value_checkbox_template, value: val1)}
            let(:content2){create(:element_value_checkbox_template, value: val2)}
            let(:ev1){create(:element_value, content: content1, element_id: el.id, template_id: template.id)}
            let(:ev2){create(:element_value, content: content2, element_id: el.id, template_id: template.id)}
            let(:tr){create(:template_record, values: [ev1, ev2], template_id: template.id, user_id: current_user.id)}

            let(:tr_params){
              {
                el.id => {
                  1 => {val1 => {content_id: ev1.id, template_id: template.id, value: "", id: content1.id}.stringify_keys}.stringify_keys,
                  2 => {val2 => {content_id: ev2.id, template_id: template.id, value: "", id: content2.id}.stringify_keys}.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}
            it_behaves_like("エラー発生時の処理")
          end

          context "プルダウン（テンプレート）入力欄が必須項目で１つも選択していない場合" do
            let(:source){create(:template)}
            let(:se){create(:element_by_it_line, template_id: source.id)}
            let(:el){create(:element_by_it_checkbox_template, template_id: template.id, required: true, source: source, source_element_id: se.id)}
            let(:val1){create(:template_record, template_id: source.id).id}
            let(:val2){create(:template_record, template_id: source.id).id}
            # content1~trまでは既存データの作成
            let(:content1){create(:element_value_checkbox_template, value: val1)}
            let(:ev1){create(:element_value, content: content1, element_id: el.id, template_id: template.id)}
            let(:tr){create(:template_record, values: [ev1], template_id: template.id, user_id: current_user.id)}

            let(:tr_params){
              {
                el.id => {
                  1 => {val1 => {content_id: ev1.id, template_id: template.id, value: "", id: content1.id}.stringify_keys}.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}
            it_behaves_like("エラー発生時の処理")
          end

          context "チェックボックス（語彙）入力欄が必須項目で１つも選択していない場合" do
            let(:ve){create(:vocabulary_element)}
            let(:el){create(:element_by_it_checkbox_vocabulary, template_id: template.id, required: true, source: ve)}
            let(:val1){create(:vocabulary_element_value, element_id: ve.id).id}
            let(:val2){create(:vocabulary_element_value, element_id: ve.id).id}
            # content1~trまでは既存データの作成
            let(:content1){create(:element_value_checkbox_template, value: val1)}
            let(:content2){create(:element_value_checkbox_template, value: val2)}
            let(:ev1){create(:element_value, content: content1, element_id: el.id, template_id: template.id)}
            let(:ev2){create(:element_value, content: content2, element_id: el.id, template_id: template.id)}
            let(:tr){create(:template_record, values: [ev1, ev2], template_id: template.id, user_id: current_user.id)}

            let(:tr_params){
              {
                el.id => {
                  1 => {val1 => {content_id: ev1.id, template_id: template.id, value: "", id: content1.id}.stringify_keys}.stringify_keys,
                  2 => {val1 => {content_id: ev2.id, template_id: template.id, value: "", id: content2.id}.stringify_keys}.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}
            it_behaves_like("エラー発生時の処理")
          end

          context "プルダウン（テンプレート）入力欄が必須項目で１つも選択していない場合" do
            let(:ve){create(:vocabulary_element)}
            let(:el){create(:element_by_it_checkbox_vocabulary, template_id: template.id, required: true, source: ve)}
            let(:val1){create(:vocabulary_element_value, element_id: ve.id).id}
            let(:val2){create(:vocabulary_element_value, element_id: ve.id).id}
            # content1~trまでは既存データの作成
            let(:content1){create(:element_value_checkbox_template, value: val1)}
            let(:ev1){create(:element_value, content: content1, element_id: el.id, template_id: template.id)}
            let(:tr){create(:template_record, values: [ev1], template_id: template.id, user_id: current_user.id)}

            let(:tr_params){
              {
                el.id => {
                  1 => {val1 => {content_id: ev1.id, template_id: template.id, value: "", id: content1.id}.stringify_keys}.stringify_keys
                }.stringify_keys
              }.stringify_keys
            }

            subject{patch :update, id: tr.id, template_id: template.id, template_record: tr_params}
            it_behaves_like("エラー発生時の処理")
          end
        end
      end
    end

    describe "DELETE destroy" do
      subject{delete :destroy, id: template_record.id, template_id: template.id}

      before do
        template_record
      end

      describe "正常系" do
        it "indexへリダイレクトすること" do
          expect(subject).to redirect_to(template_records_path(template_id: template.id))
        end

        it "flash[:notice]がセットされること" do
          subject
          expect(flash[:notice]).to eq(I18n.t("templates.records.destroy.success"))
        end

        it "レコードが削除されること" do
          expect{subject}.to change(TemplateRecord, :count).by(-1)
        end

        it "関連するElementValueが削除されること" do
          create(:element_value, template_id: template.id, record_id: template_record.id)
          find = ElementValue.where("record_id = ?", template_record.id)
          from = find.count
          expect(from).to_not be_zero
          expect{subject}.to change{find.count}.from(from).to(0)
        end

        InputType::TYPE_CLASS_NAME.each do |k, v|
          it "関連する#{v.name}が削除されること" do
            if k == "checkbox_template" || k == "pulldown_template"
              temp = create(:template, service_id: template.service_id)
              temp_el = create(:element_by_it_line, template_id: temp.id)
              tr = create(:template_record, template_id: temp.id)
              c = create(:"element_value_#{k}", value: tr.id)
              el = create(:"element_by_it_#{k}", source: temp, source_element_id: temp_el.id)
              create(:element_value, content: c, template_id: template.id, record_id: template_record.id, element_id: el.id)
            else
              c = create(:"element_value_#{k}")
              create(:element_value, content: c, template_id: template.id, record_id: template_record.id)
            end
            find = v.joins(:element_value).where("element_values.record_id = ?", template_record.id)
            from = find.count
            expect(from).to_not be_zero
            expect{subject}.to change{find.count}.from(from).to(0)
          end
        end
      end

      describe "異常系" do
        context "選択したデータが@templateのデータではなく、拡張基のデータの場合" do
          before do
            temp = create(:template)
            template.update!(parent_id: temp.id)
            template_record.update!(template_id: temp.id)
          end

          it "indexへリダイレクトすること" do
            expect(subject).to redirect_to(template_records_path(template_id: template.id))
          end

          it "flash[:alert]がセットされること" do
            subject
            expect(flash[:alert]).to eq(I18n.t("templates.records.destroy.alerts.can_not_delete"))
          end

          it "削除されないこと" do
            expect{subject}.to_not change(TemplateRecord, :count).by(-1)
          end
        end

        context "関連づけしているデータの場合" do
          context "選択したデータが他のテンプレートから参照されている場合" do
            before do
              create(:element_value_checkbox_template, value: template_record.id)
            end

            it "indexへリダイレクトすること" do
              expect(subject).to redirect_to(template_records_path(template_id: template.id))
            end

            it "flash[:alert]がセットされること" do
              subject
              expect(flash[:alert]).to eq(I18n.t("templates.records.destroy.alerts.is_referenced"))
            end

            it "削除されないこと" do
              expect{subject}.to_not change(TemplateRecord, :count).by(-1)
            end
          end
        end
      end
    end

    describe "GET import_csv_form" do
      before do
        get :import_csv_form, template_id: template.id
      end

      describe "正常系" do
        it "import_csv_formがrenderされること" do
          expect(response).to render_template(:import_csv_form)
        end

        it "ImportCSVインスタンスを作成していること" do
          expect(assigns[:import_csv]).to be_an_instance_of(ImportCSV)
        end
      end
    end

    describe "POST confirm_import_csv" do
      let(:csv_content) { File.read(Rails.root.join('spec', 'files', 'csv', 'standard.csv')) }
      let(:csv) {
        ActionDispatch::Http::UploadedFile.new({
            :tempfile => File.new(Rails.root.join('spec', 'files', 'csv', 'standard.csv'))
        })
      }

      before do
        8.times{ create(:only_element, template_id: template.id) }
        post :confirm_import_csv, template_id: template.id, import_csv: {csv: csv}
      end

      it "ImportCSVインスタンスを作成していること" do
        expect(assigns[:import_csv]).to be_an_instance_of(ImportCSV)
      end

      it "userを正しくセットしていること" do
        expect(assigns[:import_csv].user).to eq(current_user)
      end

      describe "正常系" do
        context "バリデーションに成功した場合" do
          before do
            allow_any_instance_of(ImportCSV).to receive(:valid?).and_return(true)
            post :confirm_import_csv, template_id: template.id, import_csv: {csv: csv}
          end

          it "import_csv_formがrenderされること" do
            expect(response).to render_template(:confirm_import_csv)
          end
        end
      end

      describe "異常系" do
        context "バリデーションに失敗した場合" do
          before do
            allow_any_instance_of(ImportCSV).to receive(:valid?).and_return(false)
            post :confirm_import_csv, template_id: template.id, import_csv: {csv: csv}
          end

          it "import_csv_formがrenderされること" do
            expect(response).to render_template(:import_csv_form)
          end
        end
      end

      after do
        dirs = Dir[File.join(Settings.files.csv_dir_path, "*")]
        FileUtils.rm_rf(dirs)
      end
    end

    describe "POST import_csv" do
      describe "正常系" do
        context "保存に成功した場合" do
          before do
            allow_any_instance_of(ImportCSV).to receive(:save).and_return(true)
            post :import_csv, template_id: template.id
          end

          it "正しくリダイレクトしていること" do
            expect(response).to redirect_to(complete_import_csv_template_records_path(template))
          end
        end

        context "保存に失敗した場合" do
          before do
            allow_any_instance_of(ImportCSV).to receive(:save).and_return(false)
            post :import_csv, template_id: template.id
          end

          it "正しくリダイレクトしていること" do
            expect(response).to redirect_to(import_csv_form_template_records_path(template))
          end

          it "フラッシュを正しく設定していること" do
            expect(flash[:alert]).to eq(I18n.t('templates.records.import_csv.failure'))
          end
        end
      end

      after do
        dirs = Dir[File.join(Settings.files.csv_dir_path, "*")]
        FileUtils.rm_rf(dirs)
      end
    end

    describe "POST remove_csv_file" do
      it "ImportCSVのインスタンスにremove_csv_fileを呼び出していること" do
        expect(ImportCSV).to receive(:remove_csv_file)
        delete :remove_csv_file, template_id: template.id
      end

      it "正しくリダイレクトしていること" do
        allow(ImportCSV).to receive(:remove_csv_file)
        delete :remove_csv_file, template_id: template.id
        expect(response).to redirect_to(import_csv_form_template_records_path(template))
      end
    end

    describe "GET complete_import_csv" do
      subject{get :complete_import_csv, template_id: template.id}
      describe "正常系" do
        it "complete_import_csvがrenderされること" do
          expect(subject).to render_template(:complete_import_csv)
        end

        it "200が返ること" do
          expect(subject).to be_success
        end
      end
    end

    describe "GET download_csv" do
      let(:content) { 'content' }

      it "Template#convert_records_csvを呼び出していること" do
        expect_any_instance_of(Template).to receive(:convert_records_csv).and_return(content)
        get :download_csv, template_id: template.id, format: :csv
      end

      it "Template#convert_records_csvの結果を出力していること" do
        allow_any_instance_of(Template).to receive(:convert_records_csv).and_return(content)
        get :download_csv, template_id: template.id, format: :csv
        expect(response.body).to eq(content)
      end
    end

    describe "POST search_keyword" do
      let(:element){create(:element_by_it_line, template_id: template.id)}

      describe "正常系" do
        let(:keyword){%q(松江 城 海)}
        subject{xhr :post, :search_keyword, template_id: template.id, element_id: element.id, keyword: keyword}

        it "search_keywordがrenderされること" do
          expect(subject).to render_template(:search_keyword)
        end

        it "@elementにparams[:element_id]で送られたIDと一致するElmenetインスタンスがセットされること" do
          subject
          expect(assigns[:element]).to eq(element)
        end

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "@keywordsにparams[:keyword]で送られた値がスペース区切りで配列でセットされていること" do
          subject
          result = %w(松江 城 海)
          expect(assigns[:keywords]).to eq(result)
        end

        context "該当するデータがある場合" do
          before do
            tr = create(:template_record, template_id: template.id)
            ["松江城", "岡山城", "松江市体育館", "鹿島体育館", "城山公園"].each do |key| # 検索に一致しないデータを１つ追加
              evl = create(:element_value_line, value: key)
              create(:element_value, element_id: element.id, record_id: tr.id, content_type: "ElementValue::StringContent", content_id: evl.id)
            end
            subject
          end

          context "@content_listsの検証" do
            it "@content_listsが配列3件であること" do
              expect(assigns[:content_lists].size).to eq(3)
            end

            it "@content_listsの１つ目の要素に2件あること" do
              expect(assigns[:content_lists][0].size).to eq(2)
            end

            it "@content_listsの１件目に'松江'に一致するElementValue::Lineインスタンスがセットされること" do
              assigns[:content_lists][0].each do |c|
                expect(c.value.include?("松江")).to be_true
              end
            end

            it "@content_listsの2つ目の要素に3件あること" do
              expect(assigns[:content_lists][1].size).to eq(3)
            end

            it "@content_listsの2件目に'城'に一致するElementValue::Lineインスタンスがセットされること" do
              assigns[:content_lists][1].each do |c|
                expect(c.value.include?("城")).to be_true
              end
            end

            it "@content_listsの3件目が空配列であること" do
              expect(assigns[:content_lists][-1]).to be_empty
            end
          end
        end
      end

      describe "異常系" do
        context "params[:keyword]に６個以上のキーワードが渡された場合" do
          let(:keyword){%q(松江 城 海 土 体育館 島根)}
          subject{xhr :post, :search_keyword, template_id: template.id, element_id: element.id, keyword: keyword}

          it "@errorにキーワードが多い旨を伝えるメッセージがセットされること" do
            subject
            result = I18n.t("templates.records.search_keyword.there_are_many_keyword", count: 5)
            expect(assigns[:error]).to eq(result)
          end

          it "@content_listsがセットされないこと" do
            subject
            expect(assigns[:content_lists]).to be_nil
          end
        end
      end
    end

    describe "GET element_description" do
      let(:element){create(:element, template_id: template.id)}
      subject{get :element_description, template_id: template.id, item_number: 5, element_id: element.id}

      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "_element_descriptionがrenderされること" do
          expect(subject).to render_template("_element_description")
        end

        it "@elementにparams[:element_id]をもつElementインスタンスが返ること" do
          subject
          expect(assigns[:element]).to eq(element)
        end

        it "@item_numberにparams[:item_number]の値がセットされること" do
          subject
          expect(assigns[:item_number]).to eq("5")
        end

        it "@conditionsに@element.input_conditionsの値がセットされること" do
          conds = ["必須入力", "ユニーク"]
          Element.stub(:find).with(element.id.to_s){element}
          element.stub(:input_conditions){conds}
          subject
          expect(assigns[:conditions]).to match_array(conds)
        end
      end
    end

    describe "POST element_relation_search_form" do
      let(:selected_ids){(1..5).map{create(:template_record, template_id: template.id).id.to_s}}
      let(:el){create(:element, template_id: template.id)}
      describe "正常系" do
        subject{post :element_relation_search_form, selected_ids: selected_ids, template_id: template.id, element_id: el.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "_element_relation_search_formがrenderされること" do
          expect(subject).to render_template("_element_relation_search_form")
        end

        it "params[:selected_ids]の値が@selected_idsにセットされること" do
          subject
          expect(assigns[:selected_ids]).to eq(selected_ids)
        end
      end
    end

    describe "POST element_relation_search" do
      let(:reference_template){create(:template)}
      let(:input_type){create(:input_type_checkbox_template)}
      let(:el){create(:element, template_id: template.id, source_type: "Template", source_id: reference_template.id, input_type: input_type)}
      let(:ercs_params){{element_id: el.id}}
      let(:values){
        (1..6).map do
          tr = create(:template_record)
          el = create(:element_by_it_line)
          create(:element_value, element_id: el.id)
        end
      }

      before do
        5.times do |n|
          create(:element, template_id: reference_template.id, display: (n%2==0))
        end
      end


      describe "正常系" do
        subject{xhr :post, :element_relation_search,
          selected_id: [1,2],
          template_id: template.id, element_relation_content_search: ercs_params}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "element_relation_searchがrenderされること" do
          expect(subject).to render_template("element_relation_search")
        end

        it "@element_relation_content_searchにはElementRelationContentSearchクラスの新規インスタンスがセットされること" do
          subject
          expect(assigns[:element_relation_content_search]).to be_an_instance_of(ElementRelationContentSearch)
        end

        it "@valuesには@element_relation_content_search.searchを実行した戻り値をページネートしたものがセットされること" do
          ercs = ElementRelationContentSearch.new(ercs_params)
          ElementRelationContentSearch.stub(:new){ercs}
          ercs.stub(:search){values}
          ercs.stub(:reference_template){reference_template}
          subject
          expect(assigns[:values]).to eq(Kaminari.paginate_array(values).page(1).per(5))
        end

        context "エレメントの参照先がテンプレートの場合" do
          let(:source_element){create(:element_by_it_line)}
          before do
            input_type.stub(:template?){true}
            el.update(source_element_id: source_element.id)
          end

          it "@source_elementにElementのsource_element_idにセットされているElementが返ること" do
            subject
            expect(assigns[:source_element]).to eq(source_element)
          end
        end

        context "エレメントの参照先がテンプレート以外の場合" do
          before do
            InputType.any_instance.stub(:template?){false}
          end

          it "@source_elementにnilが返ること" do
            subject
            expect(assigns[:source_element]).to be_nil
          end
        end

        context "エレメントの入力形式がプルダウンの場合" do
          before do
            InputType.any_instance.stub(:pulldown?){true}
          end

          it "@selected_idにparams[:selected_id]の値がセットされること" do
            subject
            expect(assigns[:selected_id]).to eq(["1","2"])
          end
        end

        context "エレメントの入力形式がプルダウンの場合" do
          before do
            InputType.any_instance.stub(:pulldown?){false}
          end

          it "@selected_idにnilがセットされること" do
            subject
            expect(assigns[:selected_id]).to be_nil
          end
        end
      end
    end

    describe "GET display_relation_contents" do
      let(:input_type){create(:input_type_checkbox_template)}
      let(:el){create(:element, template_id: template.id, source_type: "Template", source_id: template.id, input_type_id: input_type.id)}
      let(:te_re){create(:template_record, template_id: template.id)}
      before do
        temp = create(:template, service_id: service.id)
        tr_ids = (1..3).map do |n|
          tr = create(:template_record, template_id: temp.id)
          c = create(:element_value_identifier_content, value: tr.id, type: "ElementValue::CheckboxTemplate")
          create(:element_value, element_id: el.id, content_id: c.id, content_type: "ElementValue::IdentifierContent")
          tr.id
        end
      end

      subject{xhr :get, :display_relation_contents, element_id: el.id, template_id: template.id, id: te_re.id}

      context "@recordsの検証" do
        it "record_id==params[:record_id]のElementValueのcontentが取得されること" do
          subject
          result = ElementValue.where("record_id = ?", te_re.id).map(&:content)
          expect(assigns[:records]).to eq(result)
        end
      end


      context "関連データがTemplateの場合" do
        context "@relation_templateの検証" do
          it "element.source_idに一致するTemplateインスタンスが返ること" do
            subject
            expect(assigns[:relation_template]).to eq(Template.find(el.source_id))
          end
        end

        context "@source_elementの検証" do
          let(:source_element){create(:element_by_it_line)}
          before do
            el.update(source_element_id: source_element.id)
          end

          it "params[:element_id]のElementのsource_elementが返ること" do
            subject
            expect(assigns[:source_element]).to eq(source_element)
          end
        end
      end

      context "関連データがVocabulary::Elementの場合" do
        let(:source){create(:vocabulary_element)}
        let(:el){create(:element_by_it_checkbox_vocabulary, source: source)}

        subject{xhr :get, :display_relation_contents, element_id: el.id, template_id: template.id, id: te_re.id}

        context "@relation_templateの検証" do
          it "element.source_idに一致するVocabulary::Elementインスタンスが返ること" do
            subject
            expect(assigns[:relation_template]).to eq(Vocabulary::Element.find(el.source_id))
          end
        end
      end
    end

    describe "GET download_file" do
      let(:element){create(:element, template_id: template.id)}
      let(:path){Rails.root.join("spec", "files", 'csv', "standard.csv")}
      let(:content){build(:element_value_upload_file, value: File.basename(path))}
      let(:element_value){create(:element_value, element_id: element.id, template_id: template.id, record_id: template_record.id, content: content)}

      before do
        element_value # let call
        ElementValue.any_instance.stub(:content){content}
        content.stub(:path){path}
      end

      subject{get :download_file, template_id: template.id, element_value_id: element_value.id, id: template_record.id}

      describe "正常系" do
        it "@element_valueにparams[:element_id]とparams[:template_id],params[:id]をもとにElementValueインスタンスがセットされること" do
          subject
          expect(assigns[:element_value]).to eq(element_value)
        end

        it "@contentに@element_valueのcontentのElementValue::UploadFileインスタンスがセットされること" do
          subject
          expect(assigns[:content]).to eq(content)
        end

        it "@contentのpathで返るパスのファイルがsend_fileされること" do
          controller.stub(:render){nil}
          expect(controller).to receive(:send_file).with(path, filename: File.basename(path))
          subject
        end
      end

      describe "異常系" do
        shared_examples_for "404が返ること" do
          it "statusが404で返ること" do
            subject
            expect(response.status).to eq(404)
          end
        end

        context "params[:element_id]に不正な値がセットされている場合" do
          subject{get :download_file, template_id: template.id, element_id: "test", id: template_record.id}

          it_behaves_like("404が返ること")
        end

        context "@contentが取得出来なかった場合" do
          before do
            ElementValue.any_instance.stub(:content){nil}
          end

          it_behaves_like("404が返ること")
        end

        context "該当のパスにファイルが存在しない場合" do
          before do
            File.stub(:exist?).with(path){false}
          end

          it_behaves_like("404が返ること")
        end
      end
    end
  end

  describe "private" do
    let(:current_user){create(:editor_user)}
    let(:template){create(:template, user_id: current_user.id)}
    let(:tr){create(:template_record, template_id: template.id)}
    before do
      te = template
      controller.instance_eval do
        @template = te
      end
      controller.stub(:current_user){current_user}
    end

    describe "set_form_assigns" do
      before do
        [:shimane, :tottori, :yamaguchi, :okayama, :hiroshima].each{|a|create("pref_#{a}_with_city_and_address")}
      end

      subject{controller.send(:set_form_assigns)}

      context "@elementsの検証" do
        it "template.all_elementsのなかから、parent_idがnilの値が返ること" do
          result = create(:element)
          other = create(:element, parent_id: 1)
          elements = Element.where(id: [result.id, other.id])

          template.stub(:all_elements){elements}
          subject
          expect(assigns[:elements]).to eq([result])
        end
      end

      it "set_prefs_and_citiesが呼ばれること" do
        controller.should_receive(:set_prefs_and_cities)
        subject
      end
    end

    describe "set_prefs_and_cities" do
      before do
        [:shimane, :tottori, :yamaguchi, :okayama, :hiroshima].each{|a|create("pref_#{a}_with_city_and_address")}
      end

      subject{controller.send(:set_prefs_and_cities)}

      context "@prefsの検証" do
        it "KokudoPrefの全レコードが取得されること" do
          subject
          expect(assigns[:prefs]).to eq(KokudoPref.all)
        end
      end

      context "@citiesの検証" do
        it "@prefsの最初の値に関連するKokudoCityが取得されること" do
          subject
          expect(assigns[:cities]).to eq(assigns[:prefs].first.cities)
        end
      end
    end

    describe "record_params" do
      let(:file) {ActionDispatch::Http::UploadedFile.new({:tempfile => File.new(Rails.root.join('spec', 'files', 'csv', 'standard.csv'))})}
      let(:valid_params){
        {
          values_attributes: {
            "1" => {
              element_id: 1, kind: 1, id: 1, template_id: 1, content_type: "ElementValue::StringContent", content_id: 1,
                content_attributes: {id: 1, value: "test"}.stringify_keys
            }.stringify_keys,
            "2" => {element_id: 2, kind: 2, id: 2, template_id: 2, content_type: "ElementValue::IdentifierContent", content_id: 2,
                content_attributes: {id: 1, value: "test"}.stringify_keys
            }.stringify_keys,
            "3" => {element_id: 3, kind: nil, template_id: 1, content_type: "ElementValue::StringContent", content_id: nil,
                content_attributes: {upload_file: file}.stringify_keys
            }.stringify_keys
          }.stringify_keys
        }.stringify_keys
      }
      let(:invalid_params){valid_params.merge(template_id: 1)}
      subject{controller.send(:record_params)}
      before do
        controller.params[:template_record] = invalid_params
      end

      it "valid_paramsのみが残ること" do
        expect(subject).to eq(valid_params)
      end

    end
  end
end
