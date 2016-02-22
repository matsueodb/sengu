#
#== 語彙コードリストデータ管理機能
#
class Admin::Vocabulary::ElementsController < ApplicationController
  include Concerns::AdminController
  before_action :set_element, only: [:show, :edit, :update, :destroy]
  before_action :destroy_check, only: [:destroy]

  add_breadcrumb "I18n.t('admin.vocabulary.elements.index.title')", :vocabulary_elements, except: [:index], eval: true

  #
  #=== 語彙データ検索画面・一覧表示画面
  #
  # GET /vocabulary/elements/index
  #
  # 語彙データのコードリストの検索・一覧表示を行える
  #
  #link:../captures/vocabulary/elements/index.png
  def index
    @elements = ::Vocabulary::Element.all.order(:id)
  end

  #
  #=== 語彙データ詳細画面　
  #
  # GET /vocabulary/elements/:id
  #
  # 語彙データの詳細表示を行う
  #
  #link:../captures/vocabulary/elements/show.png
  def show
  end

  #
  #=== 語彙データ作成
  #
  # GET /vocabulary/elements/new
  #
  # 語彙データ(Vocabulary::Element)の作成を行う
  #
  #link:../captures/vocabulary/elements/new.png
  def new
    @element = ::Vocabulary::Element.new
  end

  #
  #=== 語彙データ保存
  #
  # POST /vocabulary/elements
  #
  # 語彙データ(Vocabulary::Element)の保存を行う
  #
  def create
    @element = ::Vocabulary::Element.new(vocabulary_element_params)

    if @element.save
      redirect_to new_vocabulary_element_value_path(@element), notice: t('.success')
    else
      render 'new'
    end
  end

  #
  #=== 語彙データ編集
  #
  # GET /vocabulary/elements/:id/edit
  #
  # 語彙データ(Vocabulary::Element)の編集を行う
  #
  #link:../captures/vocabulary/elements/edit.png
  def edit
  end

  #
  #=== 語彙データ更新
  #
  # PATCH /vocabulary/elements/:id
  #
  # 語彙データ(Vocabulary::Element)の更新を行う
  #
  def update
    if @element.update(vocabulary_element_params)
      redirect_to vocabulary_elements_path, notice: t('.success')
    else
      render 'edit'
    end
  end

  #
  #=== 語彙データ削除
  #
  # DELETE /vocabulary/elements/:id
  #
  # 語彙データ(Vocabulary::Element)の削除を行う
  #
  def destroy
    @element.destroy

    redirect_to vocabulary_elements_path, notice: t('.success')
  end

private

  def set_element
    @element = ::Vocabulary::Element.find(params[:id])
  end

  def vocabulary_element_params
    params.require(:vocabulary_element).permit(:name, :description)
  end

  def destroy_check
    return redirect_to vocabulary_elements_path, alert: t('.failure_destroy') unless @element.destroyable?
  end
end
