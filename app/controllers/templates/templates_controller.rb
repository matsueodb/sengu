require 'csv'

#
#== オープンデータ管理
#
class Templates::TemplatesController < ApplicationController
  add_breadcrumb I18n.t("shared.top"), :root

  MEMBER_ACTIONS = [
    :edit, :update, :destroy, :show, :download_description_pdf, :download_csv_format,
    :data_select_upon_extension_form, :data_select_upon_extension, :data_select_upon_extension_preview
  ]
  before_action :authenticate_user!
  before_action :set_template, only: MEMBER_ACTIONS
  before_action :select_data_accessible_check,
    only: [:data_select_upon_extension_form, :data_select_upon_extension]

  before_action :accessible_check,
    only: [
      :edit, :update, :destroy,
      :data_select_upon_extension_form, :data_select_upon_extension,
      :data_select_upon_extension_preview
    ]
  before_action :template_accessible_check, only: [:download_csv_format, :download_description_pdf]
  before_filter :manager_required, only: [:change_order, :change_order_form]
  before_filter :set_service, only: [:change_order, :change_order_form]
  before_filter :section_check, only: [:change_order, :change_order_form]

  #=== オープンデータ作成画面
  #
  # GET /templates/new
  #
  # テンプレートの作成を行う画面
  #link:../captures/templates/templates/new.png
  def new
    if params[:service_id].blank? && params[:parent_id].blank?
      return redirect_to root_path, alert: t(".alerts.please_by_pressing_the_new_button")
    end
    if params[:service_id]
      @service = Service.find(params[:service_id])
    else
      parent = Template.find(params[:parent_id])
      @service = parent.service
    end
    unless @service.addable_template?(current_user)
      return redirect_to root_path, alert: t("alerts.can_not_access")
    end
    @template = Template.new(service_id: @service.id, parent_id: params[:parent_id])
  end

  #=== テンプレート作成処理
  #
  # POST /templates
  #
  # テンプレートの作成処理
  def create
    @template = Template.new(template_params(:create, @template))

    if @template.service && !@template.service.addable_template?(current_user)
      return redirect_to root_path, alert: t("alerts.can_not_access")
    end

    if @template.save
      flash[:notice] = t("notices.create_after")
      if @template.has_parent?
        # 拡張時
        redirect_to data_select_upon_extension_form_template_path(@template.id)
      else
        redirect_to show_elements_template_elements_path(@template.id)
      end
    else
      render 'new'
    end
  end

  #=== テンプレート編集画面
  #
  # GET /templates/1/edit
  #
  # テンプレートの編集を行う画面
  #link:../captures/templates/templates/edit.png
  def edit
    @user_groups = current_user.section.user_groups
    @services = current_user.section.services
  end

  #=== テンプレート更新処理
  #
  # PATCH /templates/1
  #
  # テンプレートの更新処理を行う機能
  def update
    @template.attributes = template_params(:update, @template)

    if @template.save
      redirect_to services_path(id: @template.service_id), notice: t("notices.update_after")
    else
      edit
      render 'edit'
    end
  end

  #=== テンプレート削除処理
  #
  # DELETE /templates/1
  #
  # テンプレートの削除処理
  def destroy
    link = services_path(id: @template.service_id)
    if @template.destroyable?(current_user)
      @template.destroy
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".failed")
    end
    return redirect_to link
  end

  #=== 拡張時のデータ選択
  #
  # GET /templates/1/data_select_upon_extension_form
  #
  # 拡張テンプレート作成後に拡張基のデータから使用するデータを選択する
  def data_select_upon_extension_form
    @elements = @template.all_elements.root.includes(:input_type, :source)
  end

  #=== 拡張時のデータ選択処理
  #
  # POST /templates/1/data_select_upon_extension
  #
  # 拡張基のデータから使用するデータを選択処理
  def data_select_upon_extension
    TemplateRecordSelectCondition.create_sql(@template, params[:condition]) if params[:condition]
    flash[:notice] = t(".complete")
    return redirect_to show_elements_template_elements_path(@template.id)
  end

  #=== 拡張時のデータ選択プレビュー表示
  #
  # POST /templates/1/data_select_upon_extension_preview
  #
  # 画面で選択した条件で取得されるデータのプレビュー表示
  def data_select_upon_extension_preview
    @records = TemplateRecordSelectCondition.get_records(@template, params[:condition]).page(params[:page]).includes(values: :content)
    @elements = @template.parent.inputable_elements{|e|e.includes(:input_type)}.select(&:display)
  end

  #=== 関連データの検索画面
  #
  # POST /templates/1/records/element_relation_search_form
  #
  # テンプレート要素が他のテンプレートを参照している場合に、
  # 参照先のテンプレートのデータを選択する際の検索画面
  #link:../captures/templates/records/element_relation_search_form.png
  def element_relation_search_form
    @element_relation_content_search = ElementRelationContentSearch.new(element_id: params[:element_id])
    @selected_ids = params[:selected_ids] ? params[:selected_ids] : []
    render partial: "element_relation_search_form"
  end

  #=== 関連データの検索結果表示
  #
  # POST /templates/1/records/element_relation_search
  #
  # テンプレート要素が他のテンプレートを参照している場合に、
  # 参照先のテンプレートのデータを選択する際の検索処理、検索結果表示画面
  #link:../captures/templates/records/element_relation_search.png
  def element_relation_search
    @element_relation_content_search = ElementRelationContentSearch.new(params[:element_relation_content_search])
    records = @element_relation_content_search.search.to_a
    @records = Kaminari.paginate_array(records).page(params[:page]).per(5)
    if @element_relation_content_search.input_type.template?
      @elements = @element_relation_content_search.reference_template.inputable_elements.select(&:display)
    end
    @selected_id = params[:selected_id] if @element_relation_content_search.input_type.pulldown?
  end

  #
  #=== 説明資料出力機能
  #
  # GET /templates/1/download_description_pdf
  #
  # 説明資料をダウンロードする機能
  # 説明資料はPDFファイルで出力される
  def download_description_pdf
    respond_to do |format|
      format.pdf do
        pdf = Sengu::Template::PDF.new(@template)
        send_data(pdf.render, filename: t('.file_name', template_name: @template.name), type: 'application/pdf')
      end
    end
  end

  #
  #=== CSVフォーマット出力機能
  #
  # GET /templates/1/download_csv_format
  #
  def download_csv_format
    respond_to do |format|
      format.csv do
        send_data(@template.convert_csv_format, filename: "format.csv")
      end
    end
  end

  #
  #=== テンプレートの並び順変更画面
  #
  def change_order_form
    @templates = @service.templates.order(:display_number)
  end

  #
  #=== テンプレートの並び順変更処理
  #
  def change_order
    respond_to do |format|
      format.js do
        @result = Template.change_order(@service, template_params_as_change_order[:display_number_ids])
      end
    end
  end

  private

    #=== params[:id]から@templateにTemplateインスタンスを設定する。
    def set_template
      @template = Template.find(params[:id])
    end

    #=== Templateの作成、更新時に使用するパラメータを許可する
    def template_params(type, template)
      if type == :create
        params[:template].permit(:name, :service_id, :parent_id)
      else
        keys = [:name, :user_group_id, :status]
        keys << :service_id if template && template.editable_of_service?
        params[:template].permit(keys)
      end
    end

    #=== 拡張基データの使用するデータ選択のアクセス制限
    def select_data_accessible_check
      unless @template.has_parent?
        return redirect_to services_path, alert: t("templates.templates.select_data_accessible_check.failed")
      end
    end

    #=== テンプレートに対するアクセス制限
    def accessible_check
      unless @template.operator?(current_user)
        return redirect_to services_path, alert: t("alerts.can_not_access")
      end
    end

    #
    #===ログインユーザがアクセスできるデータかどうかをチェックする
    #
    def template_accessible_check
      unless @template.data_register?(current_user)
        return redirect_to(main_app.services_path, alert: I18n.t("alerts.can_not_access"))
      end
    end

    #=== Templateの並び替え
    def template_params_as_change_order
      params.require(:template).permit(display_number_ids: [])
    end

    #=== params[:service_id]から@serviceをセット
    def set_service
      @service = Service.find(params[:service_id])
    end

    #=== @serviceの所属をチェック
    def section_check
      redirect_to services_url, alert: t('alerts.can_not_access') unless current_user.section_id == @service.section_id
    end
end
