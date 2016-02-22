Admin::Vocabulary::ElementsController.class_eval do
  before_action :set_vocabulary_search, only: [:index]
  before_action :set_element, only: [:show, :edit, :update, :destroy, :update_by_vdb]
  before_action :from_vdb_check, only: [:edit, :update, :destroy]
  before_action :destroy_check, only: [:destroy]

  #
  #=== 語彙データ検索
  #
  # GET /vocabulary/elements/search
  #
  # 語彙データのパイロットシステム検索を行う
  #
  #link:../captures/vocabulary/elements/search.png
  def search
    respond_to do |format|
      format.js do
        @vocabulary_search = VocabularySearch.new(vocabulary_search_params)
        @response = @vocabulary_search.search
      end
    end
  end

  #
  #=== 語彙データ作成
  #
  # POST /vocabulary/elements/create_code_list
  #
  # 語彙データのパイロットシステムから個別取得により検索を行い
  # Vocabulary::Elementに変換して保存を行う　
  #
  def create_code_list
    code_list = VocabularySearch.find(vocabulary_search_params)

    if @element = code_list.try(:save_vocabulary_element)
      redirect_to new_vocabulary_element_value_path(@element), notice: t('.success')
    else
      redirect_to vocabulary_elements_path, alert: t('.failure')
    end
  end

  #
  #=== コードリスト更新
  #
  # コードリストを語彙データベースからデータを更新して最新にする
  #
  def update_by_vdb
    if @element.update_by_vdb
      redirect_to new_vocabulary_element_value_path(@element), notice: t('.success')
    else
      redirect_to new_vocabulary_element_value_path(@element), notice: t('.success')
    end
  end

private

  def vocabulary_search_params
    params.require(:vocabulary_search).permit(:name)
  end

  def set_vocabulary_search
    @vocabulary_search = VocabularySearch.new
  end

  def from_vdb_check
    redirect_to vocabulary_elements_path, alert: t('alerts.can_not_access') if @element.from_vdb?
  end
end
