require 'spec_helper'

describe Admin::Vocabulary::Elements::ValuesController do
  describe "フィルター" do
    describe "authenticate_user!" do
      before do
        controller.stub(:set_element).and_return(true)
        controller.stub(:set_element_value).and_return(true)
      end

      shared_examples_for "未ログイン時のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、ログイン画面が表示されること" do
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      shared_examples_for "データ登録者のアクセス制限" do |met, act|
        before{ login_user(create(:editor_user)) }
        it "#{met.upcase} #{act}にアクセスしたとき、ログイン画面が表示されること" do
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
        %w(new show edit create update destroy).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous, except: [:index]
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
      end

      context "未ログイン状態" do
        it_behaves_like("データ登録者のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("データ登録者のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("データ登録者のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("データ登録者のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("データ登録者のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("データ登録者のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
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
        controller.stub(:set_element_value).and_return(true)
      end

      it_behaves_like("インスタンス変数へのセット", :get, :new) {before{get :new, element_id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :get, :edit) {before{get :edit, id: 1, element_id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :get, :show) {before{get :show, id: 1, element_id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :post, :create) {before{post :create, element_id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :patch, :update) {before{patch :update, id: 1, element_id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :delete, :destroy) {before{delete :destroy, id: 1, element_id: @element.id}}
    end

    describe "set_element_value" do
      shared_examples_for "インスタンス変数へのセット" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@element_valueに正しい値が設定されること" do
          expect(assigns[:element_value]).to eq(@element_value)
        end
      end

      controller do
        %w(show edit update destroy).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous, except: [:index, :new, :create]
        end

        login_user
        @element = create(:vocabulary_element)
        @element_value = create(:vocabulary_element_value, element_id: @element.id)
      end

      it_behaves_like("インスタンス変数へのセット", :get, :edit) {before{get :edit, id: @element_value.id, element_id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :patch, :update) {before{patch :update, id: @element_value.id, element_id: @element.id}}
      it_behaves_like("インスタンス変数へのセット", :delete, :destroy) {before{delete :destroy, id: @element_value.id, element_id: @element.id}}
    end
  end

  describe "アクション" do
    before do
      @element = create(:vocabulary_element)
    end

    let!(:user) { login_user }

    describe "GET new" do
      before do
        get :new, element_id: @element.id
      end

      it "新しいVocabulary::Element::Valueインスタンスを作成していること" do
        expect(assigns[:element_value]).to be_a_new(Vocabulary::ElementValue)
      end

      it "newをrenderしていること" do
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      let(:element_value) { create(:vocabulary_element_value, element_id: @element.id) }

      subject{ get :edit, id: element_value.id, element_id: @element.id}

      it "editをrenderしていること" do
        expect(subject).to render_template(:edit)
      end
    end

    describe "POST create" do
      let(:element_value_params) { build(:vocabulary_element_value).attributes }

      describe "正常系" do
        before do
          post :create, element_id: @element.id, vocabulary_element_value: element_value_params
        end

        it "@element_valueが保存されていること" do
          expect(assigns[:element_value]).to be_persisted
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(new_vocabulary_element_value_path(assigns[:element]))
        end

        it "flash[:notice]が正しくセットされていること" do
          expect(flash[:notice]).to eq(I18n.t('admin.vocabulary.elements.values.create.success'))
        end
      end

      describe "異常系" do
        context "saveに失敗した場合" do
          before do
            Vocabulary::ElementValue.any_instance.stub(:save).and_return(false)
            post :create, element_id: @element.id, vocabulary_element_value: element_value_params
          end

          it "保存されていないこと" do
            expect(assigns[:element_value]).to be_a_new(Vocabulary::ElementValue)
          end

          it "newをrenderしていること" do
            expect(response).to render_template(:new)
          end
        end
      end
    end

    describe "PUT update" do
      let(:element_value) { create(:vocabulary_element_value, element_id: @element.id) }
      let(:element_value_params) { element_value.attributes.merge(name: 'new-name') }

      describe "正常系" do
        before do
          patch :update, id: element_value.id, element_id: @element.id, vocabulary_element_value: element_value_params
        end

        it "@element_valueが更新されていること" do
          expect(assigns[:element_value]).to eq(Vocabulary::ElementValue.new(element_value_params))
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(new_vocabulary_element_value_path)
        end

        it "flash[:notice]が正しくセットされていること" do
          expect(flash[:notice]).to eq(I18n.t('admin.vocabulary.elements.values.update.success'))
        end
      end

      describe "異常系" do
        context "saveに失敗した場合" do
          before do
            Vocabulary::ElementValue.any_instance.stub(:update).and_return(false)
            patch :update, element_id: @element.id, id: element_value.id, vocabulary_element_value: element_value_params
          end

          it "editをrenderしていること" do
            expect(response).to render_template(:edit)
          end
        end
      end
    end

    describe "DELETE destroy" do
      let!(:element_value) { create(:vocabulary_element_value, element_id: @element.id) }

      subject{ delete :destroy, element_id: @element.id, id: element_value.id }

      it "Vocabulary::ElementValueの数が減っていること" do
        expect{subject}.to change(Vocabulary::ElementValue, :count).by(-1)
      end

      it "正しくリダイレクトすること" do
        expect(subject).to redirect_to(new_vocabulary_element_value_path(@element))
      end
    end
  end

  describe "プライベート" do
    describe "#vocabulary_element_value_params" do
      let(:params_hash) { {vocabulary_element_value: {name: '男性用', description: '服のサイズ'}} }

      before do
        element_params = ActionController::Parameters.new(params_hash)
        @expected_element_params = element_params.require(:vocabulary_element_value).permit(:name)
        controller.params = element_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:vocabulary_element_value_params)).to eq(@expected_element_params)
      end
    end
  end
end
