require 'spec_helper'

describe Templates::ElementsController do
  describe "フィルタ" do
    describe "authenticate_user!" do
      before do
        controller.stub(:set_element).and_return(true)
        controller.stub(:set_template).and_return(true)
        controller.stub(:template_accessible_check).and_return(true)
        controller.stub(:template_operator_check).and_return(true)
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
        %w(new show edit create update destroy move change_form change_order values).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous do
            collection do
              get :change_form
              patch :change_order
              get :values
            end

            member do
              patch :move
            end
          end
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :move) {before{patch :move, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :change_form) {before{get :change_form}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :change_order) {before{patch :change_order}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :values) {before{get :values}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :move) {before{patch :move, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :change_form) {before{get :change_form}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :change_order) {before{patch :change_order}}
        it_behaves_like("ログイン時のアクセス制限", :get, :values) {before{patch :values}}
      end
    end

    describe "#template_operator_check" do
      before do
        controller.stub(:authenticate_user!).and_return(true)
        controller.stub(:set_element).and_return(true)
        controller.stub(:set_template).and_return(true)
        controller.stub(:template_accessible_check).and_return(true)
        controller.stub(:destroy_check).and_return(true)
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
        %w(new show edit create update destroy move change_form change_order values).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous do
            collection do
              get :change_form
              patch :change_order
              get :values
            end

            member do
              patch :move
            end
          end
        end
      end

      context "他の所属のユーザの場合" do
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :patch, :move) {before{patch :move, id: 1}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :get, :change_form) {before{get :change_form}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :patch, :change_order) {before{patch :change_order}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :get, :values) {before{get :values}}
      end

      context "データ登録者の場合" do
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :patch, :move) {before{patch :move, id: 1}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :change_form) {before{get :change_form}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :patch, :change_order) {before{patch :change_order}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :values) {before{get :values}}
      end

      context "管理者の場合" do
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :patch, :move) {before{patch :move, id: 1}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :change_form) {before{get :change_form}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :patch, :change_order) {before{patch :change_order}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :values) {before{get :values}}
      end

      context "所属管理者の場合" do
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :patch, :move) {before{patch :move, id: 1}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :change_form) {before{get :change_form}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :patch, :change_order) {before{patch :change_order}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :values) {before{get :values}}
      end
    end


    describe "set_element" do
      shared_examples_for "インスタンス変数へのセット" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@elementに正しい値が設定されること" do
          expect(assigns[:element]).to eq(@element)
        end
      end

      controller do
        %w(show edit update destroy move).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous do
            member do
              patch :move
            end
          end
        end

        user = login_user
        template = create(:template, service: create(:service, section_id: user.section_id))
        @element = create(:element, template_id: template.id)
        controller.stub(:set_template).and_return(true)
        controller.stub(:template_accessible_check).and_return(true)
        controller.stub(:template_operator_check).and_return(true)
        controller.instance_eval{ @template = template }
      end

      it_behaves_like("インスタンス変数へのセット", :get, :edit) {before{get :edit, id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :patch, :update) {before{patch :update, id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :delete, :destroy) {before{delete :destroy, id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :patch, :move) {before{patch :move, id: @element.id}}
    end

    describe "#destroy_check" do
      controller do
        define_method(:destroy){ render text: "ok" }
      end

      before do
        @routes.draw do
          resources :anonymous, only: [:destroy]
        end
        login_user
        template = create(:template)
        @element = create(:element, template_id: template.id)
        create(:element_by_it_checkbox_template, source: template, source_element_id: @element.id)
        controller.stub(:set_template).and_return(true)
        controller.stub(:template_accessible_check).and_return(true)
        controller.stub(:template_operator_check).and_return(true)
        controller.instance_eval{ @template = template }

        delete :destroy, id: @element.id, template_id: template.id
      end

      it "要素が他のテンプレートから参照されている場合リダイレクトすること" do
        expect(response).to redirect_to(show_elements_template_elements_path(@element.template_id))
      end
    end
  end

  describe "アクション" do
    let(:service) { create(:service, section_id: @user.section_id) }
    let(:template) { create(:template, user_id: @user.id, service: service) }

    before do
      @user = login_user
    end

    describe "GET new" do
      before do
        get :new, template_id: template.id
      end

      it "新しいElementインスタンスを作成していること" do
        expect(assigns[:element]).to be_a_new(Element)
      end

      it "newをrenderしていること" do
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      let(:element) { create(:element, template_id: template.id) }

      subject{ get :edit, template_id: template.id, id: element.id }

      it "editをrenderしていること" do
        expect(subject).to render_template(:edit)
      end
    end

    describe "GET show" do
      context "パラメータにidが含まれる場合" do
        let(:element) { create(:element, template_id: template.id) }

        before do
          get :show, template_id: template.id, id: element.id, format: :js
        end

        it "@elementに正しい値を設定していること" do
          expect(assigns[:element]).to eq(element)
        end
      end

      context "パラメータにidが含まれない場合" do
        before do
          get :show, template_id: template.id, format: :js
        end

        it "@elementにnilが設定されること" do
          expect(assigns[:element]).to be_nil
        end
      end
    end

    describe "POST create" do
      let(:element_params) { build(:element).attributes }

      describe "正常系" do
        before do
          post :create, element: element_params, template_id: template.id
        end

        it "@elementが保存されていること" do
          expect(assigns[:element]).to be_persisted
        end

        it "templateのidが正しく設定されていること" do
          expect(assigns[:element].template_id).to eq(template.id)
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(show_elements_template_elements_path(template))
        end

        it "flash[:notice]が正しくセットされていること" do
          expect(flash[:notice]).to eq(I18n.t('templates.elements.create.success'))
        end
      end

      describe "異常系" do
        context "saveに失敗した場合" do
          before do
            Element.any_instance.stub(:save).and_return(false)
            post :create, element: element_params, template_id: template.id
          end

          it "保存されていないこと" do
            expect(assigns[:element]).to be_a_new(Element)
          end

          it "newをrenderしていること" do
            expect(response).to render_template(:new)
          end
        end
      end
    end

    describe "PATCH update" do
      let(:element) { create(:element, template_id: template.id) }
      let(:element_params) { element.attributes.merge(name: 'new-name') }

      describe "正常系" do
        before do
          patch :update, template_id: template.id, id: element.id, element: element_params
        end

        it "@elementが更新されていること" do
          expect(assigns[:element]).to eq(Element.new(element_params))
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(show_elements_template_elements_path(template))
        end

        it "flash[:notice]が正しくセットされていること" do
          expect(flash[:notice]).to eq(I18n.t('templates.elements.update.success'))
        end
      end

      describe "異常系" do
        context "saveに失敗した場合" do
          before do
            Element.any_instance.stub(:update).and_return(false)
            patch :update, template_id: template.id, id: element.id, element: element_params
          end

          it "editをrenderしていること" do
            expect(response).to render_template(:edit)
          end
        end
      end
    end

    describe "DELETE destroy" do
      let!(:element) { create(:element, template_id: template.id) }

      subject{ delete :destroy, template_id: template.id, id: element.id }

      it "Elementの数が減っていること" do
        expect{subject}.to change(Element, :count).by(-1)
      end

      it "正しくリダイレクトすること" do
        expect(subject).to redirect_to(show_elements_template_elements_path(template))
      end
    end

    describe "get select_other_element_form" do
      let(:reference_template) { create(:template) }

      before do
        get :select_other_element_form, template_id: template.id, reference_template_id: reference_template.id, format: :js
      end

      it "@reference_templateに正しい値を設定していること" do
        expect(assigns[:reference_template]).to eq(reference_template)
      end

      context "idがパラメータに含まれている場合" do
        let(:element) { create(:element, template_id: reference_template.id) }
        before do
          get :select_other_element_form, id: element.id, template_id: template.id, reference_template_id: reference_template.id, format: :js
        end

        it "@reference_templateに正しい値を設定していること" do
          expect(assigns[:element]).to eq(element)
        end
      end
    end

    describe "PATCH move" do
      let(:element) { create(:element, template_id: template.id) }
      let(:parent_id) { 1 }

      context "更新に成功した場合" do
        before do
          patch :move, template_id: template.id, id: element.id, element: {parent_id: parent_id}, format: :json
          @json = JSON.parse(response.body)
        end

        it "parent_idが変更していること" do
          expect(assigns[:element].parent_id).to eq(parent_id)
        end

        it "resultがtrueであること" do
          expect(@json['result']).to be_true
        end
      end

      context "更新に成功した場合" do
        before do
          Element.any_instance.stub(:update).and_return(false)
          patch :move, template_id: template.id, id: element.id, element: {parent_id: parent_id}, format: :json
          @json = JSON.parse(response.body)
        end

        it "parent_idがnilであること" do
          expect(assigns[:element].parent_id).to be_nil
        end

        it "resultがfalseであること" do
          expect(@json['result']).to be_false
        end
      end
    end

    describe "GET change_form" do
      let(:input_type) { create(:input_type_line) }

      before do
        get :change_form, template_id: template.id, input_type_id: input_type.id, format: :js
      end

      it "@input_typeに正しい値を設定していること" do
        expect(assigns[:input_type]).to eq(input_type)
      end
    end

    describe "PATCH change_order" do
      let(:ids) { [1, 2, 3] }

      it "Element.change_orderを呼び出していること" do
        expect(Element).to receive(:change_order).with(ids)
        get :change_order, template_id: template.id, element: {display_number_ids: ids}, format: :js
      end
    end

    describe "GET values" do
      let(:template_with_records_all_type) { create(:template_with_records_all_type, service: service, user_id: @user.id) }

      before do
        element = template_with_records_all_type.elements.first
        @expected_element_values = element.values
        get :values, template_id: template_with_records_all_type.id, element_id: element.id, format: :js
      end

      it "@element_valuesに正しい値を設定していること" do
        expect(assigns[:element_values]).to match_array @expected_element_values
      end
    end

    describe "GET vocabulary_values" do
      let(:vocabulary_element) { create(:vocabulary_element_with_values) }

      before do
        get :vocabulary_values, template_id: template.id, vocabulary_element_id: vocabulary_element.id, format: :js
      end

      it "@vocabulary_elementへ正しい値を設定していること" do
        expect(assigns[:vocabulary_element]).to eq(vocabulary_element)
      end
    end

    describe "GET edit_settings" do
      let(:template_with_elements) { create(:template_with_elements, service_id: service.id) }

      subject{ get :edit_settings, template_id: template_with_elements.id }

      it "edit_settingsをrenderしていること" do
        expect(subject).to render_template(:edit_settings)
      end
    end

    describe "PATCH update_settings" do
      let(:template_with_elembents) { create(:template_with_elements, service_id: service.id) }
      let(:input_type) { create(:input_type_line) }
      let(:template_params) do
        hash = { }
        updated_attributes = {input_type_id: input_type.id, required: 1, unique: 1, available: 1, display: 0}
        template_with_elembents.elements.each_with_index do |element, i|
          hash[i.to_s] = updated_attributes.merge(id: element.id, name: "test_name_#{i}")
        end
        {elements_attributes: hash}
      end

      describe "正常系" do
        before do
          patch :update_settings, template_id: template_with_elembents.id, template: template_params
        end

        it "@elementが更新されていること" do
          assigns[:template].elements.each_with_index do |element, i|
            expect(element.name).to eql "test_name_#{i}"
            expect(element.input_type_id).to eql input_type.id
            expect(element.required).to be_true
            expect(element.unique).to be_true
            expect(element.available).to be_true
            expect(element.display).to be_false
          end
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(show_elements_template_elements_path(template_with_elembents))
        end

        it "flash[:notice]が正しくセットされていること" do
          expect(flash[:notice]).to eq(I18n.t('templates.elements.update_settings.success'))
        end
      end

      describe "異常系" do
        context "saveに失敗した場合" do
          before do
            Template.any_instance.stub(:save).and_return(false)
            patch :update_settings, template_id: template_with_elembents.id, template: template_params
          end

          it "edit_settingsをrenderしていること" do
            expect(response).to render_template(:edit_settings)
          end
        end
      end
    end
  end

  describe "プライベート" do
    describe "#element_params" do
      let(:params_hash) { {element: build(:element_set_all_attr).attributes} }
      before do
        element_params = ActionController::Parameters.new(params_hash)
        @expected_element_params = element_params.require(:element).permit(
          :name,
          :regular_expression_id,
          :input_type_id,
          :max_digit_number,
          :min_digit_number,
          :description,
          :data_example,
          :required,
          :unique,
          :display,
          :source_id,
          :source_element_id,
          :multiple_input,
          :available,
          :publish,
          :data_input_way,
        )
        controller.params = element_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:element_params)).to eq(@expected_element_params)
      end
    end

    describe "#element_params_as_move" do
      let(:params_hash) { {element: build(:element_set_all_attr).attributes} }
      before do
        element_params = ActionController::Parameters.new(params_hash)
        @expected_element_params = element_params[:element].permit(:parent_id)
        controller.params = element_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:element_params_as_move)).to eq(@expected_element_params)
      end
    end

    describe "#element_params_as_change_order" do
      let(:params_hash) { {element: {display_number_ids:[ 1, 2, 3, 4]}} }
      before do
        element_params = ActionController::Parameters.new(params_hash)
        @expected_element_params = element_params.require(:element).permit(display_number_ids: [])
        controller.params = element_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:element_params_as_change_order)).to eq(@expected_element_params)
      end
    end

    describe "#element_params_as_settings" do
      let(:input_type) { create(:input_type_line) }
      let(:params_hash) { {template: {element_attributes: { "0" =>  {id: 0, name: "test_name", input_type_id: input_type.id, required: 0, unique: 0, available: 0, display: 0, source_id: 1, source_element_id: 1}}}} }
      before do
        element_params = ActionController::Parameters.new(params_hash)
        @expected_element_params = element_params.require(:template).permit(elements_attributes: [:id, :name, :input_type_id, :required, :unique, :available, :display, :source_id, :source_element_id])
        controller.params = element_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:element_params_as_settings)).to eq(@expected_element_params)
      end
    end
  end
end
