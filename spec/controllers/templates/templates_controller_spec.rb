require 'spec_helper'

describe Templates::TemplatesController do
  describe "filter" do
    let(:section){create(:section)}
    let(:service){create(:service, section_id: section.id)}
    let(:template){create(:template, service_id: service.id)}
    let(:filters){[
        :authenticate_user!, :set_template,
        :set_form_assigns, :select_data_accessible_check, :accessible_check,
        :manager_required, :section_check, :set_service, :template_accessible_check
    ]}
    controller do
      %w(new edit create update destroy element_relation_search_form element_relation_search data_select_upon_extension_form data_select_upon_extension data_select_upon_extension_preview download_csv_format download_description_pdf change_order_form change_order).each do |act|
        define_method(act) do
          render text: "ok"
        end
      end
    end

    before do
      @routes.draw do
        resources :anonymous, except: [:index, :show] do
          collection do
            post :element_relation_search_form
            post :element_relation_search

            get :change_order_form
            patch :change_order
          end

          member do
            get :data_select_upon_extension_form
            post :data_select_upon_extension
            post :data_select_upon_extension_preview
            get :download_csv_format     # CSVフォーマット出力
            get :download_description_pdf
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
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :element_relation_search_form) {before{post :element_relation_search_form}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :element_relation_search) {before{post :element_relation_search}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :data_select_upon_extension_form) {before{get :data_select_upon_extension_form, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :data_select_upon_extension) {before{post :data_select_upon_extension, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :data_select_upon_extension_preview) {before{post :data_select_upon_extension, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :download_csv_format) {before{get :download_csv_format, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :download_description_pdf) {before{get :download_description_pdf, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :change_order_form) {before{get :change_order_form}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :change_order) {before{patch :change_order}}
      end

      context "未ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :element_relation_search_form) {before{post :element_relation_search_form}}
        it_behaves_like("ログイン時のアクセス制限", :post, :element_relation_search) {before{post :element_relation_search}}
        it_behaves_like("ログイン時のアクセス制限", :get, :data_select_upon_extension_form) {before{get :data_select_upon_extension_form, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :data_select_upon_extension) {before{post :data_select_upon_extension, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :data_select_upon_extension_preview) {before{post :data_select_upon_extension, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :download_csv_format) {before{get :download_csv_format, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :download_description_pdf) {before{get :download_description_pdf, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :change_order_form) {before{get :change_order_form}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :change_order) {before{patch :change_order}}
      end
    end

    describe "#set_template" do
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@templateがセットされていること" do
          expect(assigns[:template]).to eq(template)
        end
      end

      before do
        filters.reject{|f|f == :set_template}.each do |f|
          controller.stub(f)
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :edit) {before{get :edit, id: template.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update) {before{patch :update, id: template.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy) {before{delete :destroy, id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :data_select_upon_extension_form) {before{get :data_select_upon_extension_form, id: template.id}}
      it_behaves_like("インスタンス変数の確認", :post, :data_select_upon_extension) {before{post :data_select_upon_extension, id: template.id}}
      it_behaves_like("インスタンス変数の確認", :post, :data_select_upon_extension_preview) {before{post :data_select_upon_extension_preview, id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :download_csv_format) {before{get :download_csv_format, id: template.id}}
      it_behaves_like("インスタンス変数の確認", :get, :download_description_pdf) {before{get :download_description_pdf, id: template.id}}
    end

    describe "#select_data_accessible_check" do
      shared_examples_for "アクセス権がない場合のアクセス制限" do |met, act|
        before{template.stub(:has_parent?){false}}
        it "#{met.upcase} #{act}にアクセスしたとき、サービス一覧画面が表示されること" do
          expect(subject).to redirect_to(services_path)
        end
      end

      shared_examples_for "アクセス権がある場合のアクセス制限" do |met, act|
        before{template.stub(:has_parent?){true}}
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        filters.reject{|f|f == :select_data_accessible_check}.each do |f|
          controller.stub(f)
        end

        te = template
        controller.instance_eval do
          @template = te
        end
      end

      it_behaves_like("アクセス権がない場合のアクセス制限", :get, :data_select_upon_extension_form) {subject{get :data_select_upon_extension_form, id: template.id}}
      it_behaves_like("アクセス権がない場合のアクセス制限", :post, :data_select_upon_extension) {subject{post :data_select_upon_extension, id: template.id}}

      it_behaves_like("アクセス権がある場合のアクセス制限", :get, :data_select_upon_extension_form) {subject{get :data_select_upon_extension_form, id: template.id}}
      it_behaves_like("アクセス権がある場合のアクセス制限", :post, :data_select_upon_extension) {subject{post :data_select_upon_extension, id: template.id}}
    end

    describe "#accessible_check" do
      shared_examples_for "アクセス権がない場合の処理" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、サービス一覧画面が表示されること" do
          template.stub(:operator?){false}
          expect(subject).to redirect_to(services_path)
        end
      end

      shared_examples_for "アクセス権がある場合の処理" do |met, act|
        before do
          template.stub(:operator?){true}
          template.stub(:has_admin_authority?){true}
        end
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        filters.reject{|f|f == :accessible_check}.each do |f|
          controller.stub(f)
        end
        se, te = service, template
        controller.instance_eval do
          @service = se
          @template = te
        end
      end

      context "ログインユーザがサービスの所属のユーザの場合" do
        context "ログインユーザが管理者ユーザの場合" do
          before{login_user(create(:super_user, section_id: section.id))}
          it_behaves_like("アクセス権がある場合の処理", :get, :edit) {subject{get :edit, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :patch, :update) {subject{patch :update, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {subject{delete :destroy, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :data_select_upon_extension_form) {subject{get :data_select_upon_extension_form, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :data_select_upon_extension) {subject{post :data_select_upon_extension, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :data_select_upon_extension_preview) {subject{post :data_select_upon_extension_preview, id: template.id}}
        end

        context "ログインユーザが所属管理者ユーザの場合" do
          before{login_user(create(:section_manager_user, section_id: section.id))}
          it_behaves_like("アクセス権がある場合の処理", :get, :edit) {subject{get :edit, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :patch, :update) {subject{patch :update, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :delete, :destroy) {subject{delete :destroy, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :get, :data_select_upon_extension_form) {subject{get :data_select_upon_extension_form, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :data_select_upon_extension) {subject{post :data_select_upon_extension, id: template.id}}
          it_behaves_like("アクセス権がある場合の処理", :post, :data_select_upon_extension_preview) {subject{post :data_select_upon_extension_preview, id: template.id}}
        end

        context "ログインユーザがデータ登録者ユーザの場合" do
          before{login_user(create(:editor_user, section_id: section.id))}
          it_behaves_like("アクセス権がない場合の処理", :get, :edit) {subject{get :edit, id: template.id}}
          it_behaves_like("アクセス権がない場合の処理", :patch, :update) {subject{patch :update, id: template.id}}
          it_behaves_like("アクセス権がない場合の処理", :delete, :destroy) {subject{delete :destroy, id: template.id}}
          it_behaves_like("アクセス権がない場合の処理", :get, :data_select_upon_extension_form) {subject{get :data_select_upon_extension_form, id: template.id}}
          it_behaves_like("アクセス権がない場合の処理", :post, :data_select_upon_extension) {subject{post :data_select_upon_extension, id: template.id}}
          it_behaves_like("アクセス権がない場合の処理", :post, :data_select_upon_extension_preview) {subject{post :data_select_upon_extension_preview, id: template.id}}
        end
      end

      context "ログインユーザがサービスの所属のユーザではない場合" do
        before do
          login_user(create(:section_manager_user, section: create(:section)))
        end

        it_behaves_like("アクセス権がない場合の処理", :get, :edit) {subject{get :edit, id: template.id}}
        it_behaves_like("アクセス権がない場合の処理", :patch, :update) {subject{patch :update, id: template.id}}
        it_behaves_like("アクセス権がない場合の処理", :delete, :destroy) {subject{delete :destroy, id: template.id}}
        it_behaves_like("アクセス権がない場合の処理", :get, :data_select_upon_extension_form) {subject{get :data_select_upon_extension_form, id: template.id}}
        it_behaves_like("アクセス権がない場合の処理", :post, :data_select_upon_extension) {subject{post :data_select_upon_extension, id: template.id}}
        it_behaves_like("アクセス権がない場合の処理", :post, :data_select_upon_extension_preview) {subject{post :data_select_upon_extension_preview, id: template.id}}
      end
    end

    describe "#set_service" do
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@templateがセットされていること" do
          expect(assigns[:service]).to eq(service)
        end
      end

      before do
        filters.reject{|f|f == :set_service}.each do |f|
          controller.stub(f)
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :change_order_form) {before{get :change_order_form, service_id: service.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :change_order) {before{patch :change_order, service_id: service.id}}
    end

    describe "#section_check" do
      let(:user){create(:section_manager_user)}

      shared_examples_for "サービスの所属のアクセス制限の確認" do |met, act|
        context "@serviceの所属とログインユーザの所属が等しい場合" do
          before do
            user.stub(:section_id){service.section_id}
          end
          it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
            subject
            expect(response.body).to eq("ok")
          end
        end

        context "@serviceの所属とログインユーザの所属が等しくない場合" do
          before do
            user.stub(:section_id){create(:section).id}
          end

          it "#{met.upcase} #{act}にアクセスしたとき、services#indexにリダイレクトすること" do
            expect(subject).to redirect_to(services_path)
          end

          it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
            subject
            expect(flash[:alert]).to eq(I18n.t("alerts.can_not_access"))
          end
        end
      end

      before do
        filters.reject{|f|f == :section_check}.each do |f|
          controller.stub(f)
        end

        se = service
        controller.instance_eval do
          @service = se
        end

        controller.stub(:current_user){user}
      end

      it_behaves_like("サービスの所属のアクセス制限の確認", :get, :change_order_form) {subject{get :change_order_form, service_id: service.id}}
      it_behaves_like("サービスの所属のアクセス制限の確認", :patch, :change_order) {subject{patch :change_order, service_id: service.id}}
    end
  end

  describe "action" do
    let(:section){create(:section)}
    let(:current_user){create(:section_manager_user, section_id: section.id)}
    let(:service){create(:service, section_id: section.id)}
    let(:template){create(:template, user_id: current_user.id, service_id: service.id)}

    before do
      controller.stub(:authenticate_user!)
      controller.stub(:set_template)
      controller.stub(:select_data_accessible_check)
      controller.stub(:current_user){current_user}
      templates = (1..3).map{build(:template, user: current_user, service: service)}
      Template.import(templates)
    end

    describe "GET new" do
      describe "正常系" do
        subject{get :new, service_id: service.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "newがrenderされること" do
          expect(subject).to render_template("new")
        end

        context "@templateの検証" do
          it "Templateクラスのインスタンスがセットされること" do
            subject
            expect(assigns[:template]).to be_a(Template)
          end

          it "新規インスタンスがセットされること" do
            subject
            expect(assigns[:template]).to be_new_record
          end

          it "params[:parent_id]がある場合、その値がセットされること" do
            get :new, parent_id: 1, service_id: service.id
            expect(assigns[:template].parent_id).to eq(1)
          end

          it "params[:service_id]がセットされること" do
            subject
            expect(assigns[:template].service_id).to eq(service.id)
          end
        end
      end

      describe "異常系" do
        context "params[:service_id]とparams[:parent_id]が無い場合" do
          subject{get :new}

          it "rootにリダイレクトすること" do
            expect(subject).to redirect_to(root_path)
          end

          it "flash[:alert]がセットされること" do
            subject
            msg = I18n.t("templates.templates.new.alerts.please_by_pressing_the_new_button")
            expect(flash[:alert]).to eq(msg)
          end
        end

        context "params[:service_id]で送られたIDをもつサービスに対してテンプレートの作成権限が無い場合" do
          subject{get :new, service_id: service.id}
          before do
            Service.stub(:find).with(service.id.to_s){service}
            service.stub(:addable_template?){false}
          end

          it "rootにリダイレクトすること" do
            expect(subject).to redirect_to(root_path)
          end

          it "flash[:alert]がセットされること" do
            subject
            msg = I18n.t("alerts.can_not_access")
            expect(flash[:alert]).to eq(msg)
          end
        end

        context "params[:parent_id]で送られたIDをもつテンプレートのサービスに対して、テンプレートの作成権限が無い場合" do
          let(:parent){create(:template, service_id: service.id)}
          subject{get :new, parent_id: parent.id}
          before do
            Template.stub(:find).with(parent.id.to_s){parent}
            parent.stub(:service){service}
            service.stub(:addable_template?){false}
          end

          it "rootにリダイレクトすること" do
            expect(subject).to redirect_to(root_path)
          end

          it "flash[:alert]がセットされること" do
            subject
            msg = I18n.t("alerts.can_not_access")
            expect(flash[:alert]).to eq(msg)
          end
        end
      end
    end

    describe "GET edit" do
      before do
        loc = template
        controller.instance_eval do
          @template = loc
        end
      end

      describe "正常系" do
        subject{get :edit, id: template.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "editがrenderされること" do
          expect(subject).to render_template("edit")
        end

        context "@user_groupsの検証" do
          before do
            3.times do
              create(:user_group, section_id: 0)
              create(:user_group, section_id: section.id)
            end
          end

          it "ログインユーザの所属に登録されているグループが返ること" do
            subject
            expect(assigns[:user_groups]).to match_array(section.user_groups)
          end
        end

        context "@servicesの検証" do
          before do
            3.times do
              create(:service, section_id: section.id)
              create(:service, section_id: 0)
            end
          end

          it "ログインユーザの所属に登録されているサービスが返ること" do
            subject
            expect(assigns[:services]).to match_array(section.services)
          end
        end
      end
    end

    describe "POST create" do
      let(:template_params){{"name" => "観光施設", "service_id" => service.id}}
      before do
        template # let
      end

      subject {post :create, template: template_params}

      describe "正常系" do
        context "バリデーションに成功した場合" do
          it "Templateレコードが追加されること" do
            expect{subject}.to change(Template, :count).by(1)
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.create_after")
            expect(flash[:notice]).to eq(msg)
          end

          it "通常のテンプレートの場合、template/:id/elements/show_elementsにリダイレクトすること" do
            expect(subject).to redirect_to(show_elements_template_elements_path(template_id: Template.last.id))
          end

          it "拡張テンプレートの場合、データ選択画面にリダイレクトすること" do
            Template.any_instance.stub(:has_parent?){true}
            expect(subject).to redirect_to(data_select_upon_extension_form_template_path(Template.last.id))
          end
        end
      end

      describe "異常系" do
        context "バリデーションに失敗した場合" do
          before do
            Template.any_instance.stub(:valid?){false}
          end

          it "レコードが追加されないこと" do
            expect{subject}.to change(Template, :count).by(0)
          end

          it "newがrenderされること" do
            expect(subject).to render_template(:new)
          end
        end
      end
    end

    describe "PATCH update" do
      before do
        loc = template
        controller.instance_eval do
          @template = loc
        end
      end

      describe "正常系" do
        let(:template_params){{"name" => "観光施設", "user_group_id" => 1, "service_id" => 1}}
        subject {patch :update, id: template.id, template: template_params}

        context "バリデーションに成功した場合" do
          it "トップにリダイレクトすること" do
            expect(subject).to redirect_to(services_path(id: template.service_id))
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.update_after")
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      describe "異常系" do
        let(:template_params){{"name" => "", "user_group_id" => 1, "service_id" => 1}}
        subject {patch :update, id: template.id, template: template_params}

        context "バリデーションに失敗した場合" do
          before do
            template.stub(:valid?){false}
          end

          it "editがrenderされること" do
            expect(subject).to render_template(:edit)
          end
        end
      end
    end

    describe "GET destroy" do
      before do
        temp = template
        controller.instance_eval do
          @template = temp
        end
      end

      subject{delete :destroy, id: template.id}

      describe "正常系" do
        context "テンプレートの削除権限がある場合" do
          before do
            template.stub(:destroyable?){true}
          end

          it "レコードが１件削除されること" do
            expect{subject}.to change(Template, :count).by(-1)
          end

          it "services#indexへリダイレクトされること" do
            expect(subject).to redirect_to(services_path(id: service.id))
          end
        end
      end

      describe "異常系" do
        context "テンプレートの削除権限が無い場合" do
          before do
            template.stub(:destroyable?){false}
          end

          it "flash[:alert]がセットされること" do
            subject
            msg = I18n.t("templates.templates.destroy.failed")
            expect(flash[:alert]).to eq(msg)
          end

          it "選択したレコードが削除されないこと" do
            expect{subject}.to_not change{Template.exists?(template.id)}.to(true)
          end
        end
      end
    end

    describe "GET download_description_pdf" do
      let(:filename) { 'template.pdf' }
      let(:pdf_content) { 'pdf-content' }

      before do
        loc = template
        controller.instance_eval do
          @template = loc
        end

        allow_any_instance_of(Sengu::Template::PDF).to receive(:render).and_return(pdf_content)
        get :download_description_pdf, id: template.id, format: :pdf
      end

      it "renderした返り値をPDFとしてを出力していること" do
        expect(response.body).to eq(pdf_content)
      end
    end

    describe "GET download_csv_format" do
      let(:content) { 'content' }

      before do
        loc = template
        controller.instance_eval do
          @template = loc
        end
      end

      it "Template#convert_csv_formatを呼び出していること" do
        expect_any_instance_of(Template).to receive(:convert_csv_format).and_return(content)
        get :download_csv_format, id: template.id, format: :csv
      end

      it "Template#convert_csv_formatの結果を出力していること" do
        allow_any_instance_of(Template).to receive(:convert_csv_format).and_return(content)
        get :download_csv_format, id: template.id, format: :csv
        expect(response.body).to eq(content)
      end
    end

    describe "GET data_select_upon_extension_form" do
      before do
        Element.import([
          build(:element_by_it_line, id: 1, template_id: template.id),
          build(:element_by_it_line, id: 2, template_id: template.id, parent_id: 1),
          build(:element_by_it_line, id: 3, template_id: template.id, parent_id: 2),
          build(:element_by_it_line, id: 4, template_id: template.id)
        ])

        loc = template
        controller.instance_eval do
          @template = loc
        end
      end

      subject{get :data_select_upon_extension_form, id: template.id}

      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "data_select_upon_extension_formがrenderされること" do
          expect(subject).to render_template("data_select_upon_extension_form")
        end

        context "@elementsの検証" do
          it "一番親の階層のElementが取得されること" do
            subject
            assigns[:elements].each do |el|
              expect(el.parent_id).to be_nil
            end
          end
        end
      end
    end

    describe "POST data_select_upon_extension" do
      let(:ve){create(:vocabulary_element)}
      let(:el_line){create(:element_by_it_line, template: template)}
      let(:el_mline){create(:element_by_it_multi_line, template: template)}
      let(:el_date){create(:element_by_it_dates, template: template)}
      let(:el_cve){create(:element_by_it_checkbox_vocabulary, source_type: "Vocabulary::Element", source_id: ve.id, template: template)}
      let(:el_pve){create(:element_by_it_pulldown_vocabulary, source_type: "Vocabulary::Element", source_id: ve.id, template: template)}
      let(:condition_params){{
        el_line.id => {"0" => {"string_condition" => "forward_match", "value" => "松江"}},
        el_mline.id => {"0" => {"string_condition" => "middle_match", "value" => "島根"}},
        el_date.id => {"0" => {"value" => "2014-01-01"}},
        el_cve.id => {"1" => {"value" => "1"}, "3" => {"value" => "3"}},
        el_pve.id => {"2" => {"value" => "2"}, "4" => {"value" => "4"}}
      }}

      before do
        loc = template
        controller.instance_eval do
          @template = loc
        end
      end

      subject{post :data_select_upon_extension, id: template.id, condition: condition_params}

      describe "正常系" do
        it "TemplateRecordSelectCondition.create_sqlが呼ばれること" do
          TemplateRecordSelectCondition.should_receive(:create_sql).with(template, condition_params)
          subject
        end

        it "flash[:notice]がセットされること" do
          subject
          result = I18n.t("templates.templates.data_select_upon_extension.complete")
          expect(flash[:notice]).to eq(result)
        end

        it "templates/:id/elements/show_elementsにリダイレクトすること" do
          expect(subject).to redirect_to(show_elements_template_elements_path(template_id: template.id))
        end
      end
    end

    describe "POST data_select_upon_extension_preview" do
      let(:parent){create(:template, service: service, user: current_user)}
      let(:ve){create(:vocabulary_element)}
      let(:el_line){create(:element_by_it_line, template: template)}
      let(:el_mline){create(:element_by_it_multi_line, template: template)}
      let(:el_date){create(:element_by_it_dates, template: template)}
      let(:el_cve){create(:element_by_it_checkbox_vocabulary, source_type: "Vocabulary::Element", source_id: ve.id, template: template)}
      let(:el_pve){create(:element_by_it_pulldown_vocabulary, source_type: "Vocabulary::Element", source_id: ve.id, template: template)}
      let(:condition_params){{
        el_line.id => {"0" => {"string_condition" => "forward_match", "value" => "松江"}},
        el_mline.id => {"0" => {"string_condition" => "middle_match", "value" => "島根"}},
        el_date.id => {"0" => {"value" => "2014-01-01"}},
        el_cve.id => {"1" => {"value" => "1"}, "3" => {"value" => "3"}},
        el_pve.id => {"2" => {"value" => "2"}, "4" => {"value" => "4"}}
      }}

      before do
        template.stub(:parent){parent}
        loc = template
        controller.instance_eval do
          @template = loc
        end
      end

      subject{xhr :post, :data_select_upon_extension_preview, id: template.id, condition: condition_params}

      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "data_select_upon_extension_previewがrenderされること" do
          expect(subject).to render_template("data_select_upon_extension_preview")
        end

        context "@recordsの検証" do
          it "TemplateRecordSelectCondition.get_recordsの結果がセットされること" do
            (1..3).map{|a|create(:template_record, template_id: template.id)}
            records = TemplateRecord.where(template_id: template.id).page(1)
            TemplateRecordSelectCondition.stub(:get_records){records}
            subject
            expect(assigns[:records]).to eq(records)
          end

          it "ページネートされること" do
            (1..11).map{|a|create(:template_record, template_id: template.id)}
            records = TemplateRecord.where(template_id: template.id).page(2)
            TemplateRecordSelectCondition.stub(:get_records){records}
            xhr :post, :data_select_upon_extension_preview, id: template.id, condition: condition_params, page: 2
            expect(assigns[:records]).to eq(records)
          end
        end

        context "@elementsの検証" do
          it "@templateの親テンプレートのinputable_elementsの結果から、display=trueのものがセットされること" do
            elements = (1..5).map{|a|create(:element, display: true, template_id: parent.id)}
            elements2 = (1..5).map{|a|create(:element, display: false, template_id: parent.id)}
            all_elements = elements + elements2
            parent.stub(:inputable_elements){all_elements}
            subject
            expect(assigns[:elements]).to eq(elements)
          end
        end
      end
    end
  end

  describe "private" do
    let(:current_user){create(:editor_user)}
    let(:template){create(:template, user_id: current_user.id)}
    before do
      controller.stub(:current_user){current_user}
    end

    describe "template_params" do
      context "作成の場合(:create)" do
        let(:valid_params){{"name" => "template", "parent_id" => 1, "service_id" => 1}}
        let(:invalid_params){valid_params.merge(status: 0)}
        subject{controller.send(:template_params, :create, template)}
        before do
          controller.params[:template] = invalid_params
        end

        it "valid_paramsのみが残ること" do
          expect(subject).to eq(valid_params.stringify_keys)
        end
      end

      context "更新の場合(:update)" do
        let(:valid_params){{"name" => "template", user_group_id: 1, status: 1}}
        let(:invalid_params){valid_params.merge(user_id: 1, parent_id: 1)}
        subject{controller.send(:template_params, :update, template)}
        before do
          controller.params[:template] = invalid_params
        end

        it "valid_paramsのみが残ること" do
          expect(subject).to eq(valid_params.stringify_keys)
        end
      end
    end

    describe "#template_params_as_change_order" do
      let(:params_hash) { {template: {display_number_ids:[ 1, 2, 3, 4]}} }
      before do
        template_params = ActionController::Parameters.new(params_hash)
        @expected_template_params = template_params.require(:template).permit(display_number_ids: [])
        controller.params = template_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:template_params_as_change_order)).to eq(@expected_template_params)
      end
    end
  end
end
