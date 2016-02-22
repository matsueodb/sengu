#
#== 語彙データ管理機能
#
class Admin::Vocabulary::Elements::ValuesController < ApplicationController
  include Concerns::AdminController
  before_action :set_element
  before_action :set_element_value, only: [:edit, :update, :destroy]

  add_breadcrumb I18n.t("admin.vocabulary.elements.index.title"), :vocabulary_elements

  #
  #=== 語彙データ内容設定画面
  #
  # GET /vocabulary/elements/:id/values/new
  #
  # 語彙データのコードリストの中身の値を設定する画面
  #
  #link:../captures/admin/vocabulary/elements/values/new.png
  def new
    @element_value = ::Vocabulary::ElementValue.new
  end

  #
  #=== 語彙データ内容作成
  #
  # POST /vocabulary/elements/:id/values
  #
  # 語彙データのコードリストの中身の値を作成する
  #
  def create
    @element_value = @element.values.build(vocabulary_element_value_params)

    if @element_value.save
      redirect_to new_vocabulary_element_value_path(@element), notice: t('.success')
    else
      render 'new'
    end
  end

  #
  #=== 語彙データ内容編集
  #
  # POST /vocabulary/elements/:id/values/:id/edit
  #
  # 語彙データのコードリストの中身の値を編集する
  #
  #link:../captures/admin/vocabulary/elements/values/edit.png
  def edit
  end

  #
  #=== 語彙データ内容更新
  #
  # PATCH /vocabulary/elements/:id/values/:id
  #
  # 語彙データのコードリストの中身の値を更新する
  #
  def update
    if @element_value.update(vocabulary_element_value_params)
      redirect_to new_vocabulary_element_value_path(@element), notice: t('.success')
    else
      render 'edit'
    end
  end

  #
  #=== 語彙データ内容削除
  #
  # DELETE /vocabulary/elements/:id/values/:id
  #
  # 語彙データのコードリストの中身の値を削除
  #
  def destroy
    @element_value.destroy
    redirect_to new_vocabulary_element_value_path(@element), notice: t('.success')
  end

private

  def set_element
    @element = ::Vocabulary::Element.find(params[:element_id])
  end

  def set_element_value
    @element_value = @element.values.find(params[:id])
  end

  def vocabulary_element_value_params
    params.require(:vocabulary_element_value).permit(:name)
  end
end
