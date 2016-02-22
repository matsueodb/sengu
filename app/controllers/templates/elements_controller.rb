#
#=== テンプレートエレメントの管理を行うコントローラー
#
# テンプレートが属するサービスの所属の管理者・所属の管理者のみがアクセスできる
#
class Templates::ElementsController < ApplicationController
  include Concerns::TemplatesController

  before_action :template_operator_check
  before_action :set_element, only: [:edit, :update, :destroy, :move]
  before_action :destroy_check, only: [:destroy]

  layout "template_elements", only: [:show_elements, :new, :edit, :create, :update, :edit_settings, :update_settings]

  #
  #=== テンプレート編集画面
  #
  # GET /templates/1/elements/new
  #
  # テンプレートのカスタマイズ画面
  #
  #link:../captures/templates/elements/new.png
  def new
    @element = Element.new(input_type_id: InputType.find_line.try(:id))
  end

  #
  #=== テンプレート要素編集画面
  #
  # GET /templates/1/elements/1/edit
  #
  # テンプレート要素編集画面
  #
  #link:../captures/templates/elements/edit.png
  def edit
  end

  #
  #=== テンプレート要素の詳細表示画面
  #
  # GET /templates/1/elements/1
  #
  # テンプレート要素の詳細表示を行う
  # 子要素の表示や、並び替えを行うことが出来る
  #
  #link:../captures/templates/elements/show.png
  def show
    respond_to do |format|
      format.js{ @element = Element.find(params[:id]) if params[:id].present? }
    end
  end

  #
  #=== テンプレート要素の作成
  #
  # POST /templates/1/elements/
  #
  # テンプレート要素の作成を行う
  #
  def create
    @element = @template.elements.build(element_params)

    if @element.save
      redirect_to show_elements_template_elements_path(params[:template_id]), notice: t('.success')
    else
      render :new
    end
  end

  #
  #=== テンプレート要素の更新
  #
  # PATCH /templates/1/elements/1
  #
  # テンプレート要素の更新を行う
  #
  def update
    if @element.update(element_params)
      redirect_to show_elements_template_elements_path(params[:template_id]), notice: t('.success')
    else
      render :edit
    end
  end

  #
  #=== テンプレート要素の削除
  #
  # DELETE /templates/1/elements/1
  #
  # テンプレート要素の削除を行う
  #
  def destroy
    @element.destroy

    redirect_to show_elements_template_elements_path(params[:template_id]), notice: t('.success')
  end

  #
  #=== テンプレートフォームの切り替え
  #
  # GET /templates/1/elements/change_template
  #
  # 語彙データを使用するべき入力タイプが選択された場合に、
  # インラインでフォームを切り替える
  #
  def change_form
    respond_to do |format|
      format.js do
        if params[:id].present?
          @element = Element.find(params[:id])
        else
          @element = Element.new(input_type_id: InputType.find_line.try(:id))
        end
        @input_type = InputType.find(params[:input_type_id])
        @target = params[:target] || "#change-for-input-type-form"
      end
    end
  end


  #
  #=== データ入力時表示項目のプルダウンの切り替え
  #
  # GET /templates/1/elements/select_other_element_form
  #
  # テンプレートを参照するさいに表示する項目を選択するフォームをrenderする
  #
  def select_other_element_form
    respond_to do |format|
      format.js do
        @reference_template = Template.find(params[:reference_template_id])
        @element = @reference_template.elements.find_by(id: params[:id]) if params[:id].present?
        @target = params[:target] || "#select-other-element"
        @dir = params[:dir] || "forms"
      end
    end
  end

  #
  #=== テンプレート要素の移動
  #
  # PATCH /templates/1/elements/1/move
  #
  # テンプレート要素の移動を行う
  # 失敗した場合は、失敗した際のメッセージを返す
  #
  def move
    respond_to do |format|
      format.json do
        if @element.update(parent_id: element_params_as_move[:parent_id])
          render json: { result: true }
        else
          render json: { result: false, messages: @element.errors.full_messages }
        end
      end
    end
  end

  #
  #=== テンプレート要素の順番変更
  #
  # PATCH /templates/1/elements/1/change_order
  #
  # テンプレート要素の順番変更を行う
  #
  def change_order
    respond_to do |format|
      format.js do
        @result = Element.change_order(element_params_as_change_order[:display_number_ids])
      end
    end
  end

  #
  #=== 特定のテンプレート、特定の項目に対するelement_valuesを返す
  #
  # GET /templates/1/elements/1/values
  #
  # 項目の入力データを表示する
  #
  def values
    respond_to do |format|
      format.js do
        template_record_ids = @template.all_records.pluck(:id)
        @element = Element.find(params[:element_id])
        @element_values = ElementValue.where(record_id: template_record_ids, element_id: @element.id)
      end
    end
  end

  #=== 指定されたコードリストの内容を表示する
  #
  # GET /templates/1/elements/1/vocabulary_values
  #
  # 項目の入力データを表示する
  #
  def vocabulary_values
    respond_to do |format|
      format.js do
        @vocabulary_element = Vocabulary::Element.find(params[:vocabulary_element_id])
      end
    end
  end


  #
  #=== 項目一覧画面
  #
  # GET /templates/1/elements/new
  #
  # テンプレートに属する項目一覧画面
  #
  #link:../captures/templates/elements/show_elements.png
  def show_elements
  end

  #
  #=== 項目一括設定画面
  #
  # GET /templates/1/elements/edit_settings
  #
  # テンプレートに属する項目一括設定画面
  #
  #link:../captures/templates/elements/edit_settings.png
  def edit_settings
    @template = Template.where(id: params[:template_id]).includes(:elements => [{:children => :input_type}, :input_type]).first
    @flat_display_numbers = @template.calculate_flat_display_numbers
  end

  #
  #=== 項目一括更新
  #
  # PATCH /templates/1/elements/update_settings
  #
  # テンプレートに属する項目一括更新
  def update_settings
    # NOTE: templateに対する更新に見えるが、実際はtemplateが持つelementsを更新している。
    #       実際の更新対象がelementsのみなので、elements_controllerにアクションをもたせている。
    @template = Template.where(id: params[:template_id]).includes(:elements => [{:children => :input_type}, :input_type]).first
    @template.attributes = element_params_as_settings
    if @template.save
      redirect_to show_elements_template_elements_path(@template), notice: t('.success')
    else
      @flat_display_numbers = @template.calculate_flat_display_numbers
      render :edit_settings
    end
  end

  private

    def set_element
      @element = @template.elements.find(params[:id])
    end

    def element_params
      params.require(:element).permit(
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
    end

    def element_params_as_move
      params[:element].permit(:parent_id)
    end

    def element_params_as_change_order
      params.require(:element).permit(display_number_ids: [])
    end

    def element_params_as_settings
      params.require(:template).permit(elements_attributes: [:id, :name, :input_type_id, :required, :unique, :available, :display, :source_id, :source_element_id, :data_input_way])
    end

    def destroy_check
      unless @element.destroyable?
        return redirect_to show_elements_template_elements_path(params[:template_id]), alert: t('.failure_destroy')
      end
    end
end
