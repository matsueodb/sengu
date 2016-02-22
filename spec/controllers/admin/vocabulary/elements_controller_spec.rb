require 'spec_helper'

describe Admin::Vocabulary::ElementsController do
  describe "フィルタ" do
    describe "authenticate_user!" do
      before do
        controller.stub(:set_element).and_return(true)
        controller.stub(:destroy_check).and_return(true)
        controller.stub(:from_vdb_check).and_return(true)
      end

      shared_examples_for "未ログイン時のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、ログイン画面が表示されること" do
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      shared_examples_for "データ登録者のアクセス制限" do |met, act|
        before{ login_user(create(:editor_user)) }
        it "#{met.upcase} #{act}にアクセスしたとき、画面が表示されること" do
          expect(response).to redirect_to(root_path)
        end
      end

      shared_examples_for "ログイン時のアクセス制限"  do |met, act|
        before{ login_user }
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          (response.body == "ok").should be_true
        end
      end

      controller do
        %w(index new show edit create update destroy search create_code_list).each do |act|
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
              post :create_code_list
            end
          end
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create_code_list) {before{post :create_code_list}}
      end

      context "データ登録者のログイン状態" do
        it_behaves_like("データ登録者のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("データ登録者のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("データ登録者のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("データ登録者のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("データ登録者のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("データ登録者のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("データ登録者のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("データ登録者のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("データ登録者のアクセス制限", :post, :create_code_list) {before{post :create_code_list}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create_code_list) {before{post :create_code_list}}
      end
    end

    describe "set_element" do
      shared_examples_for "インスタンス変数へのセット" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@elementに正しい値が設定されること" do
          expect(assigns[:element]).to eq(@element)
        end
      end

      controller do
        %w(index new show edit create update destroy).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous
        end

        login_user
        @element = create(:vocabulary_element)
      end

      it_behaves_like("インスタンス変数へのセット", :get, :edit) {before{get :edit, id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :get, :show) {before{get :show, id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :patch, :update) {before{patch :update, id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :delete, :destroy) {before{delete :destroy, id: @element.id}}
    end
  end


  describe "アクション" do
    let!(:user) { login_user }

    describe "GET index" do
      let(:elements) { 3.times.map{ create(:vocabulary_element) } }

      before do
        get :index
      end

      it "@elementsに正しい値を設定していること" do
        expect(assigns[:elements]).to eq(elements)
      end

      it "indexをrenderしていること" do
        expect(response).to render_template(:index)
      end
    end

    describe "GET new" do
      before do
        get :new
      end

      it "新しいVocabulary::Elementインスタンスを作成していること" do
        expect(assigns[:element]).to be_a_new(Vocabulary::Element)
      end

      it "newをrenderしていること" do
        expect(response).to render_template(:new)
      end
    end

    describe "GET show" do
      let(:element) { create(:vocabulary_element) }

      subject{ get :show, id: element.id}

      it "showをrenderしていること" do
        expect(subject).to render_template(:show)
      end
    end

    describe "GET edit" do
      let(:element) { create(:vocabulary_element) }

      subject{ get :edit, id: element.id}

      it "editをrenderしていること" do
        expect(subject).to render_template(:edit)
      end
    end

    describe "POST create" do
      let(:element_params) { build(:vocabulary_element).attributes }

      describe "正常系" do
        before do
          post :create, vocabulary_element: element_params
        end

        it "@elementが保存されていること" do
          expect(assigns[:element]).to be_persisted
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(new_vocabulary_element_value_path(assigns[:element]))
        end

        it "flash[:notice]が正しくセットされていること" do
          expect(flash[:notice]).to eq(I18n.t('admin.vocabulary.elements.create.success'))
        end
      end

      describe "異常系" do
        context "saveに失敗した場合" do
          before do
            Vocabulary::Element.any_instance.stub(:save).and_return(false)
            post :create, vocabulary_element: element_params
          end

          it "保存されていないこと" do
            expect(assigns[:element]).to be_a_new(Vocabulary::Element)
          end

          it "newをrenderしていること" do
            expect(response).to render_template(:new)
          end
        end
      end
    end

    describe "PUT update" do
      let(:element) { create(:vocabulary_element) }
      let(:element_params) { element.attributes.merge(name: 'new-name') }

      describe "正常系" do
        before do
          patch :update, id: element.id, vocabulary_element: element_params
        end

        it "@elementが更新されていること" do
          expect(assigns[:element]).to eq(Vocabulary::Element.new(element_params))
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(vocabulary_elements_path)
        end

        it "flash[:notice]が正しくセットされていること" do
          expect(flash[:notice]).to eq(I18n.t('admin.vocabulary.elements.update.success'))
        end
      end

      describe "異常系" do
        context "saveに失敗した場合" do
          before do
            Vocabulary::Element.any_instance.stub(:update).and_return(false)
            patch :update, id: element.id, vocabulary_element: element_params
          end

          it "editをrenderしていること" do
            expect(response).to render_template(:edit)
          end
        end
      end
    end

    describe "DELETE destroy" do
      let!(:element) { create(:vocabulary_element) }

      subject{ delete :destroy, id: element.id }

      it "Vocabulary::Elementの数が減っていること" do
        expect{subject}.to change(Vocabulary::Element, :count).by(-1)
      end

      it "正しくリダイレクトすること" do
        expect(subject).to redirect_to(vocabulary_elements_path)
      end
    end
  end

  describe "プライベート" do
    describe "#vocabulary_element_params" do
      let(:params_hash) { {vocabulary_element: build(:vocabulary_element).attributes.merge(reject: true)} }

      before do
        element_params = ActionController::Parameters.new(params_hash)
        @expected_element_params = element_params.require(:vocabulary_element).permit(:name, :description)
        controller.params = element_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:vocabulary_element_params)).to eq(@expected_element_params)
      end
    end
  end
end
