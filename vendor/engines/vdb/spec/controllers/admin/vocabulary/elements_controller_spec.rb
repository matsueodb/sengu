require 'spec_helper'

describe Admin::Vocabulary::ElementsController do
  describe "フィルタ" do
    describe "authenticate_user!" do

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
        %w(search create_code_list update_by_vdb).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        allow(controller).to receive(:set_element)
        @routes.draw do
          resources :anonymous do
            collection do
              post :search
              post :create_code_list
            end

            member do
              patch :update_by_vdb
            end
          end
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create_code_list) {before{post :create_code_list}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :update_by_vdb) {before{patch :update_by_vdb, id: 1}}
      end

      context "データ登録者のログイン状態" do
        it_behaves_like("データ登録者のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("データ登録者のアクセス制限", :post, :create_code_list) {before{post :create_code_list}}
        it_behaves_like("データ登録者のアクセス制限", :post, :update_by_vdb) {before{patch :update_by_vdb, id: 1}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :post, :search) {before{post :search}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create_code_list) {before{post :create_code_list}}
        it_behaves_like("ログイン時のアクセス制限", :post, :update_by_vdb) {before{patch :update_by_vdb, id: 1}}
      end
    end

   describe "vdb_from_check" do
      shared_examples_for "語彙から取得したコードリストのアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、コードリストトップ画面が表示されること" do
          expect(response).to redirect_to(vocabulary_elements_path)
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
        @element = create(:vocabulary_element, from_vdb: true)
        @routes.draw do
          resources :anonymous, only: [:edit, :update, :destroy]
        end
      end

      it_behaves_like("語彙から取得したコードリストのアクセス制限", :get, :edit) {before{get :edit, id: @element.id}}
      it_behaves_like("語彙から取得したコードリストのアクセス制限", :patch, :update) {before{patch :update, id: @element.id}}
      it_behaves_like("語彙から取得したコードリストのアクセス制限", :delete, :update) {before{delete :destroy, id: @element.id}}
    end
  end

  describe "アクション" do
    let!(:user) { login_user }

    describe "POST search" do
      let(:name) { 'name' }
      let(:response_text) { 'response' }

      before do
        expect_any_instance_of(VocabularySearch).to receive(:search).and_return(response_text)
        post :search, vocabulary_search: {name: name}, format: :js
      end

      it "searchをrenderしていること" do
        expect(subject).to render_template(:search)
      end

      it "@responseに正しい値を設定していること" do
        expect(assigns[:response]).to eq(response_text)
      end
    end

    describe "POST create_code_list" do
      let(:vocabulary) { double('vocabulary') }

      before do
        expect(VocabularySearch).to receive(:find).and_return(vocabulary)
      end

      it "正しいメソッドと引数で保存をしていること" do
        expect(vocabulary).to receive(:save_vocabulary_element)
        post :create_code_list, vocabulary_search: {name: 'name'}
      end

      context "保存に成功した場合" do
        let(:id) { 1 }

        before do
          allow(vocabulary).to receive(:save_vocabulary_element).and_return(id)
          post :create_code_list, vocabulary_search: {name: 'name'}
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(new_vocabulary_element_value_path(id))
        end

        it "flash[:notice]が正しく設定されていること" do
          expect(flash[:notice]).to eq(I18n.t('admin.vocabulary.elements.create_code_list.success'))
        end
      end

      context "保存に失敗した場合" do
        before do
          allow(vocabulary).to receive(:save_vocabulary_element).and_return(false)
          post :create_code_list, vocabulary_search: {name: 'name'}
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(vocabulary_elements_path)
        end

        it "flash[:alert]が正しく設定されていること" do
          expect(flash[:alert]).to eq(I18n.t('admin.vocabulary.elements.create_code_list.failure'))
        end
      end
    end

    describe "PATCH update_by_vdb" do
      let(:vocabulary_element) { create(:vocabulary_element) }

      context "正常系" do
        before do
          allow_any_instance_of(Vocabulary::Element).to receive(:update_by_vdb)
          patch :update_by_vdb, id: vocabulary_element.id
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(new_vocabulary_element_value_path(vocabulary_element))
        end

        it "flash[:notice]に正しいメッセージを設定していること" do
          expect(flash[:notice]).to eq(I18n.t('admin.vocabulary.elements.update_by_vdb.success'))
        end
      end

      context "異常系" do
        before do
          allow_any_instance_of(Vocabulary::Element).to receive(:update_by_vdb).and_return(false)
          patch :update_by_vdb, id: vocabulary_element.id
        end

        it "正しくリダイレクトすること" do
          expect(response).to redirect_to(new_vocabulary_element_value_path(vocabulary_element))
        end

        it "flash[:notice]に正しいメッセージを設定していること" do
          expect(flash[:notice]).to eq(I18n.t('admin.vocabulary.elements.update_by_vdb.success'))
        end
      end
    end
  end

  describe "プライベート" do
    describe "#vocabulary_element_params" do
      let(:params_hash) { {vocabulary_search: {name: '曜日', domain_id: '1'}} }

      before do
        vocabulary_search_params = ActionController::Parameters.new(params_hash)
        @expected_element_params = vocabulary_search_params.require(:vocabulary_search).permit(:name, :description)
        controller.params = vocabulary_search_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:vocabulary_search_params)).to eq(@expected_element_params)
      end
    end
  end
end
