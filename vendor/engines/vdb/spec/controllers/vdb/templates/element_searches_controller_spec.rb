require 'spec_helper'

describe Vdb::Templates::ElementSearchesController do
  describe "フィルタ" do
    describe "authenticate_user!" do
      before do
        controller.stub(:set_template).and_return(true)
        controller.stub(:template_accessible_check).and_return(true)
        controller.stub(:template_operator_check).and_return(true)
        controller.stub(:set_breadcrumbs).and_return(true)
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
        %w(index find search create_element create_complex_type).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous, only: [:index] do
            collection do
              post :find
              post :search
              post :create_element
              post :create_complex_type
            end
          end
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :find) {before{post :find}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create_element) {before{post :create_element}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create_complex_type) {before{post :create_complex_type}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("ログイン時のアクセス制限", :post, :find) {before{post :find}}
        it_behaves_like("ログイン時のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create_element) {before{post :create_element}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create_complex_type) {before{post :create_complex_type}}
      end
    end

    describe "#template_operator_check" do
      before do
        controller.stub(:authenticate_user!).and_return(true)
        controller.stub(:set_template).and_return(true)
        controller.stub(:template_accessible_check).and_return(true)
        controller.stub(:set_breadcrumbs).and_return(true)
      end

      shared_examples_for "異なる所属のユーザがアクセスした場合のアクセス制限" do |met, act|
        before do
          login_user
          user = create(:editor_user)
          service = create(:service, section_id: user.section_id)
          template = create(:template, service_id: service.id)
          controller.instance_eval{ @template = template }
        end

        it "#{met.upcase} #{act}にアクセスしたときサービス一覧画面が表示されること" do
          expect(response).to redirect_to(services_path)
        end
      end

      shared_examples_for "データ登録者がアクセスした場合のアクセス制限" do |met, act|
        before do
          user = login_user(create(:editor_user))
          service = create(:service, section_id: user.section_id)
          template = create(:template, service_id: service.id)
          controller.instance_eval{ @template = template }
        end

        it "#{met.upcase} #{act}にアクセスしたときサービス一覧画面が表示されること" do
          expect(response).to redirect_to(services_path)
        end
      end

      shared_examples_for "管理者がアクセスした場合のアクセス制限"  do |met, act|
        before do
          user = login_user(create(:super_user))
          service = create(:service, section_id: user.section_id)
          template = create(:template, service_id: service.id)
          controller.instance_eval{ @template = template }
        end

        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          (response.body == "ok").should be_true
        end
      end

      shared_examples_for "所属管理者がアクセスした場合のアクセス制限"  do |met, act|
        before do
          user = login_user(create(:section_manager_user))
          service = create(:service, section_id: user.section_id)
          template = create(:template, service_id: service.id)
          controller.instance_eval{ @template = template }
        end

        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          (response.body == "ok").should be_true
        end
      end

      controller do
        %w(index find search create_element create_complex_type).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous, only: [:index] do
            collection do
              post :find
              post :search
              post :create_element
              post :create_complex_type
            end
          end
        end
      end

      context "他の所属のユーザの場合" do
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :post, :find) {before{post :find}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :post, :create_element) {before{post :create_element}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :post, :create_complex_type) {before{post :create_complex_type}}
      end

      context "データ登録者の場合" do
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :post, :find) {before{post :find}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :post, :create_element) {before{post :create_element}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :post, :create_complex_type) {before{post :create_complex_type}}
      end

      context "管理者の場合" do
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :post, :find) {before{post :find}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :post, :create_element) {before{post :create_element}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :post, :create_complex_type) {before{post :create_complex_type}}
      end

      context "所属管理者の場合" do
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :post, :find) {before{post :find}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :post, :create_element) {before{post :create_element}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :post, :create_complex_type) {before{post :create_complex_type}}
      end
    end
  end

  describe "アクション" do
    let(:main_app) { Sengu::Application.routes.url_helpers }
    let(:service) { create(:service, section_id: @user.section_id) }
    let(:template) { create(:template, service: service, user: @user) }

    before do
      @user = login_user
    end

    describe "GET index" do
      before do
        get :index, template_id: template.id, format: :js, use_route: :vdb
      end

      it "新しいTemplateElementSearchインスタンスを作成していること" do
        expect(assigns[:template_element_search]).to be_a_kind_of(TemplateElementSearch)
      end

      it "indexをrenderしていること" do
        expect(response).to render_template(:index)
      end
    end

    describe "POST find" do
      let(:name) { 'name' }
      let(:vdb_response) { "vdb_response" }
      let(:complex) { double('complex', name: "name") }

      before do
        expect_any_instance_of(TemplateElementSearch).to receive(:find_complexes).and_return([vdb_response])
        post :find, template_id: template.id, template_element_search: {name: name}, format: :js, use_route: :vdb
      end

      it "新しいTemplateElementSearchインスタンスを作成していること" do
        expect(assigns[:template_element_search]).to be_a_kind_of(TemplateElementSearch)
      end

      it "@complexesに正しい値を設定していること" do
        expect(assigns[:complexes]).to match_array([vdb_response])
      end

      it "findをrenderしていること" do
        expect(subject).to render_template(:find)
      end
    end

    describe "POST search" do
      let(:name) { 'name' }
      let(:vdb_response) { double('vdb_response', complexes: [complex]) }
      let(:complex) { double('complex', name: "name") }

      context "正常系" do
        before do
          expect_any_instance_of(TemplateElementSearch).to receive(:search).and_return([vdb_response])
          expect_any_instance_of(TemplateElementSearch).to receive(:find_complexes).and_return([vdb_response])
          post :search, template_id: template.id, template_element_search: {name: name}, format: :js, use_route: :vdb
        end

        it "新しいTemplateElementSearchインスタンスを作成していること" do
          expect(assigns[:template_element_search]).to be_a_kind_of(TemplateElementSearch)
        end

        it "@complexesに正しい値を設定していること" do
          expect(assigns[:complexes]).to match_array([vdb_response])
        end

        it "searchをrenderしていること" do
          expect(subject).to render_template(:search)
        end
      end

      context "異常系" do
        before do
          expect_any_instance_of(TemplateElementSearch).to receive(:search).and_return([vdb_response])
          expect_any_instance_of(TemplateElementSearch).not_to receive(:find_complexes)
          post :search, template_id: template.id, template_element_search: {name: name}, format: :js, use_route: :vdb
        end

        describe "complexesが空の場合" do
          let(:vdb_response) { double('vdb_response', complexes: []) }

          it "@complexesがnilであること" do
            expect(assigns[:complexes]).to be_nil
          end

          it "searchをrenderしていること" do
            expect(subject).to render_template(:search)
          end

          it "errorが追加されていること" do
            expect(assigns[:template_element_search].errors[:base]).to eq([I18n.t("vdb.templates.element_searches.search.no_element")])
          end
        end
      end
    end

    describe "POST element_sample_field" do
      let(:element) { build(:element) }
      let(:element_item) { double('element_item', to_element: element) }

      context "正常系" do
        before do
          allow_any_instance_of(TemplateElementSearch).to receive(:find_element).and_return(element_item)
          post :element_sample_field, template_id: template.id, template_element_search: {name: 'name'}, format: :js, use_route: :vdb
        end

        it "@elementsに正しい値を設定していること" do
          expect(assigns[:elements]).to match_array([element])
        end

        it "@template_recordにTemplateRecordの新しいインスタンスを設定していること" do
          expect(assigns[:template_record]).to be_a_new(TemplateRecord)
        end
      end

      context "異常系" do
        before do
          allow_any_instance_of(TemplateElementSearch).to receive(:find_element).and_return(nil)
          post :element_sample_field, template_id: template.id, template_element_search: {name: 'name'}, format: :js, use_route: :vdb
        end

        it "@error_messagesに正しい値を設定していること" do
          expect(assigns[:error_messages]).to eq(I18n.t('vdb.templates.element_searches.element_sample_field.failure'))
        end
      end
    end

    describe "POST complex_sample_field" do
      let(:elements) { [build(:element)] }
      let(:complex) { double('complex', to_elements: elements) }

      context "正常系" do
        before do
          allow_any_instance_of(TemplateElementSearch).to receive(:find_complex).and_return(complex)
          post :complex_sample_field, template_id: template.id, template_element_search: {name: 'name'}, format: :js, use_route: :vdb
        end

        it "@elementsに正しい値を設定していること" do
          expect(assigns[:elements]).to match_array(elements)
        end

        it "@template_recordにTemplateRecordの新しいインスタンスを設定していること" do
          expect(assigns[:template_record]).to be_a_new(TemplateRecord)
        end
      end

      context "異常系" do
        before do
          allow_any_instance_of(TemplateElementSearch).to receive(:find_complex).and_return(nil)
          post :complex_sample_field, template_id: template.id, template_element_search: {name: 'name'}, format: :js, use_route: :vdb
        end

        it "@error_messagesに正しい値を設定していること" do
          expect(assigns[:error_messages]).to eq(I18n.t('vdb.templates.element_searches.complex_sample_field.failure'))
        end
      end
    end


    describe "POST create_element" do
      let(:element) { double('element') }

      it "正しいメソッドと引数で保存をしていること" do
        expect_any_instance_of(TemplateElementSearch).to receive(:find_element).and_return(element)
        expect(element).to receive(:save_element).with(template.id){true}
        post :create_element, template_id: template.id, template_element_search: {name: 'name'}, use_route: :vdb
      end

      context "保存に成功した場合" do
        before do
          expect_any_instance_of(TemplateElementSearch).to receive(:find_element).and_return(element)
          allow(element).to receive(:save_element).and_return(true)
          post :create_element, template_id: template.id, template_element_search: {name: 'name'}, use_route: :vdb
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(main_app.show_elements_template_elements_path(template))
        end

        it "flash[:notice]が正しく設定されていること" do
          expect(flash[:notice]).to eq(I18n.t('vdb.templates.element_searches.create_element.success'))
        end
      end

      context "保存に失敗した場合" do
        let(:error_messages){["error_messages1", "error_messages2"]}
        before do
          expect_any_instance_of(TemplateElementSearch).to receive(:find_element).and_return(element)
          allow(element).to receive(:error_messages).and_return(error_messages)
          allow(element).to receive(:save_element).and_return(false)
          post :create_element, template_id: template.id, template_element_search: {name: 'name'}, use_route: :vdb
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(main_app.show_elements_template_elements_path(template))
        end

        it "flash[:alert]が正しく設定されていること" do
          msgs = error_messages
          msgs << I18n.t("vdb.templates.element_searches.create_element.error.workaround")
          alert = msgs.join("<br />")
          expect(flash[:alert]).to eq(alert)
        end
      end

      context "語彙が取得出来なかった場合" do
        before do
          expect_any_instance_of(TemplateElementSearch).to receive(:find_element).and_return(nil)
          post :create_element, template_id: template.id, template_element_search: {name: 'name'}, use_route: :vdb
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(main_app.show_elements_template_elements_path(template))
        end

        it "flash[:alert]が正しく設定されていること" do
          expect(flash[:alert]).to eq(I18n.t('vdb.shared.vdb_access_failure'))
        end
      end
    end

    describe "POST create_complex_type" do
      let(:complex) { double('complex') }

      it "正しいメソッドと引数で保存をしていること" do
        expect_any_instance_of(TemplateElementSearch).to receive(:find_complex).and_return(complex)
        expect(complex).to receive(:save_element).with(template.id){true}
        post :create_complex_type, template_id: template.id, template_element_search: {name: 'name'}, use_route: :vdb
      end

      context "保存に成功した場合" do
        before do
          expect_any_instance_of(TemplateElementSearch).to receive(:find_complex).and_return(complex)
          allow(complex).to receive(:save_element).and_return(true)
          post :create_complex_type, template_id: template.id, template_element_search: {name: 'name'}, use_route: :vdb
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(main_app.show_elements_template_elements_path(template))
        end

        it "flash[:notice]が正しく設定されていること" do
          expect(flash[:notice]).to eq(I18n.t('vdb.templates.element_searches.create_complex_type.success'))
        end
      end

      context "保存に失敗した場合" do
        let(:error_messages){["error_messages1", "error_messages2"]}
        before do
          expect_any_instance_of(TemplateElementSearch).to receive(:find_complex).and_return(complex)
          allow(complex).to receive(:error_messages).and_return(error_messages)
          allow(complex).to receive(:save_element).and_return(false)
          post :create_complex_type, template_id: template.id, template_element_search: {name: 'name'}, use_route: :vdb
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(main_app.show_elements_template_elements_path(template))
        end

        it "flash[:alert]が正しく設定されていること" do
          msgs = error_messages
          msgs << I18n.t("vdb.templates.element_searches.create_complex_type.error.workaround")
          alert = msgs.join("<br />")
          expect(flash[:alert]).to eq(alert)
        end
      end

      context "語彙が取得出来なかった場合" do
        before do
          expect_any_instance_of(TemplateElementSearch).to receive(:find_complex).and_return(nil)
          post :create_complex_type, template_id: template.id, template_element_search: {name: 'name'}, use_route: :vdb
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(main_app.show_elements_template_elements_path(template))
        end

        it "flash[:alert]が正しく設定されていること" do
          expect(flash[:alert]).to eq(I18n.t('vdb.shared.vdb_access_failure'))
        end
      end
    end
  end

  describe "プライベート" do
    describe "#element_search_params" do
      let(:params_hash) { {template_element_search: {name: '貨物', domain_id: '1', getname: '輸送'}} }
      before do
        element_params = ActionController::Parameters.new(params_hash)
        @expected_element_params = element_params.require(:template_element_search).permit(:name, :domain_id)
        controller.params = element_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:element_search_params)).to eq(@expected_element_params)
      end
    end
  end
end
