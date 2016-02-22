require 'spec_helper'

describe Vdb::Vocabulary::KeywordsController do
  describe "フィルタ" do
    describe "authenticate_user!" do
      before do
        controller.stub(:set_vocabulary_keyword).and_return(true)
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
        %w(index show create update destroy configure search).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous, only: [:index, :show, :create, :update, :destroy] do
            collection do
              get :configure
              post :search
            end

            member do
              patch :move
            end
          end
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :configure) {before{get :configure}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :search) {before{post :search}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :configure) {before{get :configure}}
        it_behaves_like("ログイン時のアクセス制限", :post, :search) {before{post :search}}
      end
    end

    describe "set_vocabulary_keyword" do
      shared_examples_for "インスタンス変数へのセット" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@vocabulary_keywordに正しい値が設定されること" do
          expect(assigns[:vocabulary_keyword]).to eq(@vocabulary_keyword)
        end
      end

      controller do
        %w(show update destroy).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous, only: [:show, :update, :destroy]
        end

        user = login_user
        @vocabulary_keyword = create(:vocabulary_keyword, user_id: user.id)
      end

      it_behaves_like("インスタンス変数へのセット", :get, :show) {before{get :show, id: @vocabulary_keyword.id}}
      it_behaves_like("インスタンス変数へのセット", :patch, :update) {before{patch :update, id: @vocabulary_keyword.id}}
      it_behaves_like("インスタンス変数へのセット", :delete, :destroy) {before{delete :destroy, id: @vocabulary_keyword.id}}
    end
  end

  describe "アクション" do
    let!(:user) { login_user }

    before do
      create(:input_type_line)
      create(:input_type_multi_line)
      create(:input_type_dates)
      create(:input_type_google_location)
    end

    describe "GET index" do
      let(:vocabulary_keywords) { create_list(:vocabulary_keyword, 5, user_id: user.id) }

      before do
        get :index, use_route: :vdb
      end

      it "@template_element_searchにTemplateElementSearchにインスタンスを設定していること" do
        expect(assigns[:template_element_search]).to be_kind_of(TemplateElementSearch)
      end

      it "@vocabulary_keywordsに正しい値を設定していること" do
        expect(assigns[:vocabulary_keywords]).to eq(vocabulary_keywords)
      end

      it "indexをrenderしていること" do
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      let(:vocabulary_keyword) { create(:vocabulary_keyword, user_id: user.id) }

      subject{ get :show, id: vocabulary_keyword.id, format: :js, use_route: :vdb }

      it "showをrenderしていること" do
        expect(subject).to render_template(:show)
      end
    end

    describe "POST search" do
      let(:response_text) { 'response' }
      before do
        expect_any_instance_of(TemplateElementSearch).to receive(:search).and_return(response_text)
        post :search, template_element_search: {name: "建物", domain_id: TemplateElementSearch::CORE_ID}, format: :js, use_route: :vdb
      end

      it "@template_element_searchにTemplateElementSearchにインスタンスを設定していること" do
        expect(assigns[:template_element_search]).to be_kind_of(TemplateElementSearch)
      end

      it "@responsesに正しい値を設定していること" do
        expect(assigns[:responses]).to eq(response_text)
      end
    end

    describe "POST create" do
      let(:vocabulary_keyword_params) { build(:vocabulary_keyword).attributes }

      describe "正常系" do
        before do
          post :create, vocabulary_keyword: vocabulary_keyword_params, format: :js, use_route: :vdb
        end

        it "@vocabulary_keywordが保存されていること" do
          expect(assigns[:vocabulary_keyword]).to be_persisted
        end

        it "user_idが正しく設定されていること" do
          expect(assigns[:vocabulary_keyword].user_id).to eq(user.id)
        end

        it "success_configureをrenderしていること" do
          expect(response).to render_template(:success_configure)
        end
      end

      describe "異常系" do
        context "保存に失敗した場合" do
          before do
            Vocabulary::Keyword.any_instance.stub(:save).and_return(false)
            post :create, vocabulary_keyword: vocabulary_keyword_params, format: :js, use_route: :vdb
          end

          it "@vocabulary_keywordが保存されていないこと" do
            expect(assigns[:vocabulary_keyword]).to be_a_new(Vocabulary::Keyword)
          end

          it "failure_configureをrenderしていること" do
            expect(response).to render_template(:failure_configure)
          end
        end
      end
    end

    describe "PATCH update" do
      let(:vocabulary_keyword) { create(:vocabulary_keyword, user_id: user.id) }
      let(:vocabulary_keyword_params) { vocabulary_keyword.attributes.merge(content: '施設、自宅、家') }

      describe "正常系" do
        before do
          patch :update, vocabulary_keyword: vocabulary_keyword_params, id: vocabulary_keyword.id, format: :js, use_route: :vdb
        end

        it "@vocabulary_keywordが正しく更新されていること" do
          expect(assigns[:vocabulary_keyword]).to eq(Vocabulary::Keyword.new(vocabulary_keyword_params))
        end

        it "success_configureがrenderされること" do
          expect(response).to render_template(:success_configure)
        end
      end

      describe "異常系" do
        context "更新に失敗した場合" do
          before do
            Vocabulary::Keyword.any_instance.stub(:update).and_return(false)
            patch :update, vocabulary_keyword: vocabulary_keyword_params, id: vocabulary_keyword.id, format: :js, use_route: :vdb
          end

          it "failure_configureをrenderしていること" do
            expect(response).to render_template(:failure_configure)
          end
        end
      end
    end

    describe "DELETE destroy" do
      routes { Vdb::Engine.routes }
      let!(:vocabulary_keyword) { create(:vocabulary_keyword, user_id: user.id) }

      subject{ delete :destroy, id: vocabulary_keyword.id, use_route: :vdb }

      it "Vocabulary::Keywordが減っていること" do
        expect{subject}.to change(Vocabulary::Keyword, :count).by(-1)
      end

      it "正しくリダイレクトすること" do
        expect(subject).to redirect_to(vocabulary_keywords_path)
      end
    end

    describe "GET configure" do
      context "新規作成の場合" do
        before do
          get :configure, format: :js, use_route: :vdb
        end

        it "Vocabulary::Keywordを新しく作成している" do
          expect(assigns[:vocabulary_keyword]).to be_a_new(Vocabulary::Keyword)
        end
      end

      context "編集の場合" do
        let(:vocabulary_keyword) { create(:vocabulary_keyword, user_id: user.id) }

        before do
          get :configure, name: vocabulary_keyword.name, format: :js, use_route: :vdb
        end

        it "Vocabulary::Keywordをfindしていること" do
          expect(assigns[:vocabulary_keyword]).to eq(vocabulary_keyword)
        end
      end
    end
  end

  describe "プライベート" do
    describe "#vocabulary_keyword_params" do
      let(:params_hash) { {vocabulary_keyword: build(:vocabulary_keyword).attributes} }
      before do
        vocabulary_keyword_params = ActionController::Parameters.new(params_hash)
        @expected_vocabulary_keyword_params = vocabulary_keyword_params.require(:vocabulary_keyword).permit(
          :name,
          :scope,
          :content,
          :category
        )
        controller.params = vocabulary_keyword_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:vocabulary_keyword_params)).to eq(@expected_vocabulary_keyword_params)
      end
    end

    describe "#template_element_search_params" do
      let(:params_hash) { {template_element_search: {name: '施設', domain_id: 1} } }
      before do
        template_element_search_params = ActionController::Parameters.new(params_hash)
        @template_element_search_params = template_element_search_params.require(:template_element_search).permit(
          :name,
          :domain_id
        )
        controller.params = template_element_search_params
      end

      it "正しくパーミットされていること" do
        expect(controller.send(:template_element_search_params)).to eq(@template_element_search_params)
      end
    end
  end
end
