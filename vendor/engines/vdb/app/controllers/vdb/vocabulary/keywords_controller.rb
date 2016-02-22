module Vdb
  module Vocabulary
    class KeywordsController < Vdb::ApplicationController
      add_breadcrumb "I18n.t('shared.top')", "main_app.root_path", eval: true

      before_action :authenticate_user!
      before_action :set_vocabulary_keyword, only: [:show, :update, :destroy]

      #
      #=== 語彙キーワード設定のトップ画面
      #
      # GET /vocabulary/keywords
      #
      # パイロットシステムの語彙データへキーワードを設定する画面のトップ画面
      #
      #link:../captures/vocabulary/keywords/index.png
      def index
        @template_element_search = TemplateElementSearch.new
        @vocabulary_keywords = current_user.vocabulary_keywords
      end

      #
      #=== 語彙キーワード設定詳細画面
      #
      # GET /vocabulary/keywords/:id(.js)
      #
      # 語彙キーワードの詳細画面
      #
      #link:../captures/vocabulary/keywords/show.png
      def show
        respond_to do |format|
          format.js
        end
      end

      #
      #=== 語彙検索キーワード作成
      #
      # POST /vocabulary/keywords/
      #
      # 語彙検索キーワードをデータベースへ登録する
      #
      def create
        @vocabulary_keyword = current_user.vocabulary_keywords.build(vocabulary_keyword_params)

        if @vocabulary_keyword.save
          render 'success_configure'
        else
          render 'failure_configure'
        end
      end

      #
      #=== 語彙検索キーワード更新
      #
      # PATCH /vocabulary/keywords/:id
      #
      # 既に登録されている語彙検索キーワードを更新する
      #
      def update
        if @vocabulary_keyword.update(vocabulary_keyword_params)
          render 'success_configure'
        else
          render 'failure_configure'
        end
      end

      #
      #=== 語彙検索キーワード削除
      #
      # DELETE /vocabulary/keywords/:id
      #
      # 既に登録されている語彙を削除する
      #
      def destroy
        @vocabulary_keyword.destroy
        redirect_to vocabulary_keywords_path, notice: t('.success')
      end

      #
      #=== 語彙データ検索結果画面　
      #
      # GET /vocabulary/keywords/search(.js)
      #
      # 語彙データの検索結果を表示する
      #
      #link:../captures/vocabulary/keywords/search.png
      def search
        respond_to do |format|
          format.js do
            @template_element_search = TemplateElementSearch.new(template_element_search_params)
            @responses = @template_element_search.search(use_keyword: false)
          end
        end
      end

      #
      #=== 語彙データキーワード設定画面
      #
      # GET /vocabulary/keywords/configure
      #
      # 語彙データのキーワードを設定する画面
      #
      #link:../captures/vocabulary/keywords/configure.png
      def configure
        respond_to do |format|
          format.js do
            @vocabulary_keyword = current_user.vocabulary_keywords.find_or_initialize_by(name: params[:name])
          end
        end
      end

      private

      def vocabulary_keyword_params
        params.require(:vocabulary_keyword).permit(:name, :scope, :content, :category)
      end

      def template_element_search_params
        params.require(:template_element_search).permit(:name, :domain_id)
      end

      def set_vocabulary_keyword
        @vocabulary_keyword = current_user.vocabulary_keywords.find(params[:id])
      end
    end
  end
end
