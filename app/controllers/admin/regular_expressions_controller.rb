#
#== 入力値制限マスタ管理
#
class Admin::RegularExpressionsController < ApplicationController
  include Concerns::AdminController
  before_action :set_regular_expression, only: [:show, :edit, :update, :destroy]
  before_action :set_regular_expression_list, only: [:index, :new, :edit]
  before_action :editable_check, only: [:edit, :update]
  before_action :destroyable_check, only: [:destroy]

  add_breadcrumb I18n.t("admin.regular_expressions.index.title"), :regular_expressions, except: [:index]

  #=== 入力値制限マスタ一覧
  #
  # GET /admin/regular_expressions/
  #
  # 入力値制限マスタの一覧を表示する画面
  #link:../captures/admin/regular_expressions/index.png
  def index
  end

  #=== 入力値制限マスタ詳細
  #
  # GET /admin/regular_expressions/1
  #
  # 入力値制限マスタの詳細を表示する画面
  #link:../captures/admin/regular_expressions/show.png
  def show
  end

  #=== 入力値制限マスタ作成
  #
  # GET /admin/regular_expressions/new
  #
  # 入力値制限マスタを作成する画面
  #link:../captures/admin/regular_expressions/new.png
  def new
    @regular_expression = RegularExpression.new
  end

  #=== 入力値制限マスタ作成処理
  #
  # POST /admin/regular_expressions/
  #
  # 入力値制限マスタの作成処理
  def create
    @regular_expression = RegularExpression.new(regular_expression_params)

    if @regular_expression.save
      redirect_to regular_expressions_path, notice: t("notices.create_after")
    else
      set_regular_expression_list
      render 'new'
    end
  end

  #=== 入力値制限マスタ編集
  #
  # GET /admin/regular_expressions/1/edit
  #
  # 入力値制限マスタの編集をする画面
  #link:../captures/admin/regular_expressions/edit.png
  def edit
  end

  #=== 入力値制限マスタ更新処理
  #
  # PATCH /admin/regular_expressions/1/
  #
  # 入力値制限マスタの更新処理
  def update
    @regular_expression.attributes = regular_expression_params

    if @regular_expression.save
      redirect_to regular_expressions_path, notice: t("notices.update_after")
    else
      set_regular_expression_list
      render 'edit'
    end
  end

  #=== 入力値制限マスタ削除処理
  #
  # DELETE /admin/regular_expressions/1/
  #
  # 入力値制限マスタの削除処理
  def destroy
    if @regular_expression.elements.exists?
      return redirect_to regular_expressions_path, alert: t(".failed")
    end
    @regular_expression.destroy
    return redirect_to regular_expressions_path, notice: t("notices.destroy_after")
  end

  private

  #
  #=== params[:id]から@regular_expressionをセット
  #
  def set_regular_expression
    @regular_expression = RegularExpression.find(params[:id])
  end

  #
  #=== @regular_expressionsのセット
  #
  def set_regular_expression_list
    @regular_expressions = RegularExpression.page(params[:page])
  end

  #
  #=== 編集できるかを確認
  #
  def editable_check
    unless @regular_expression.editable?
      redirect_to regular_expressions_path, alert: t("alerts.can_not_edit")
    end
  end

  #
  #=== 削除できるかを確認
  #
  def destroyable_check
    unless @regular_expression.destroyable?
      redirect_to regular_expressions_path, alert: t("alerts.can_not_destroy")
    end
  end

  #
  #=== permit params[:regular_expression]
  #
  def regular_expression_params
    params.require(:regular_expression).permit(:name, :format, :option)
  end
end
