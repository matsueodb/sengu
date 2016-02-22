#
#== データ入出力管理
#
class Templates::RecordsController < ApplicationController
  include Concerns::TemplatesController

  skip_before_filter :verify_authenticity_token, only: [:search_keyword, :element_relation_search_form, :element_relation_search]

  before_action :set_template_record, only: [:show, :edit, :update, :destroy, :display_relation_contents, :download_file]

  before_action :editable_check, only: [:edit, :update]
  before_action :destroyable_check, only: [:destroy]

  layout "template_records", only: [:index, :new, :edit, :create, :update,
    :import_csv, :confirm_import_csv, :import_csv_form, :complete_import_csv]

  #=== 入力データ一覧表示画面
  #
  # GET /templates/1/records
  #
  # 登録されているデータの一覧を表示する画面
  #link:../captures/templates/records/index.png
  def index
    @elements = @template.inputable_elements{|e|e.includes(:input_type)}.select(&:display)
    @template_records = @template.all_records.includes(values: :content).page(params[:page]).order("id DESC")
  end

  #=== 入力データ詳細表示画面
  #
  # GET /templates/1/records/1
  #
  # 登録されているデータの詳細を表示する画面(Ajax modal)
  #link:../captures/templates/records/show.png
  def show
    @elements = @template.all_elements.root.availables.includes(:input_type, :source)
  end


  #=== データ作成画面
  #
  # GET /templates/1/records/new
  #
  # 作成したテンプレートをもとにデータの入力を行う画面
  #link:../captures/templates/records/new.png
  def new
    @template_record ||= @template.template_records.build
    set_form_assigns
  end


  #=== データ登録処理
  #
  # POST /templates/1/records
  #
  # データの登録処理を行う機能
  def create
    @template_record = @template.template_records.build
    @template_record.user_id = current_user.id
    begin
      ActiveRecord::Base.transaction do
        @template_record.save_from_params!(params[:template_record], @template)
      end
      redirect_to template_records_path(template_id: @template.id), notice: t("notices.create_after")
    rescue => ex
      new
      render "new"
    end
  end

  #=== 登録データ編集画面
  #
  # GET /templates/1/records/1/edit
  #
  # 登録したデータの編集を行う画面
  #link:../captures/templates/records/edit.png
  def edit
    set_form_assigns
  end


  #=== 登録データ更新処理
  #
  # PATCH /templates/1/records/1
  #
  # データの更新処理を行う機能
  def update
    begin
      ActiveRecord::Base.transaction do
        @template_record.save_from_params!(params[:template_record], @template)
      end
      redirect_to template_records_path(template_id: @template.id), notice: t("notices.update_after")
    rescue => ex
      edit
      render "edit"
    end
  end

  #=== データ削除処理
  #
  # DELETE /templates/1/records/1
  #
  # データの削除処理を行う機能
  def destroy
    # アクセス制限はfilterでかかる
    if @template.id != @template_record.template_id
      return redirect_to template_records_path(template_id: @template.id), alert: t(".alerts.can_not_delete")
    end

    if @template_record.is_referenced?
      # 他のデータから参照されているとき
      return redirect_to template_records_path(template_id: @template.id), alert: t(".alerts.is_referenced")
    end

    begin
      ActiveRecord::Base.transaction do
        @template_record.destroy
      end
      flash[:notice] = t(".success")
    rescue
      flash[:alert] = t(".failed")
    end
    redirect_to template_records_path(template_id: @template.id)
  end


  #=== CSV一括登録画面
  #
  # GET /templates/1/records/import_csv_form
  #
  # CSVファイルからデータの一括登録を行う画面
  #link:../captures/templates/records/import_csv_form.png
  def import_csv_form
    @import_csv = ImportCSV.new
  end

  #=== CSV一括登録確認画面
  #
  # POST /templates/1/records/confirm_import_csv
  #
  # CSVファイルからデータの一括登録を行う際の確認画面
  #link:../captures/templates/records/confirm_import_csv.png
  def confirm_import_csv
    @import_csv = ImportCSV.new(csv: import_csv_params[:csv].try(:read),
                                user: current_user,
                                template: @template)

    if @import_csv.valid?
      render :confirm_import_csv
    else
      render :import_csv_form
    end
  end

  #
  #=== CSV一括登録処理
  #
  # POST /templates/1/records/import_csv
  #
  # アップロードしたCSVファイルからデータの一括登録処理を行う機能
  def import_csv
    @import_csv = ImportCSV.new(user: current_user, template: @template)

    if @import_csv.save
      redirect_to complete_import_csv_template_records_path(@template)
    else
      redirect_to import_csv_form_template_records_path(@template), alert: t('.failure')
    end
  end

  #
  #=== 選択されたCSVファイルの削除
  #
  # DELETE /templates/1/records/import_csv
  #
  def remove_csv_file
    ImportCSV.remove_csv_file(current_user.id, @template.id)

    redirect_to import_csv_form_template_records_path(@template)
  end

  #=== CSV一括登録完了画面
  #
  # GET /templates/1/records/complete_import_csv
  #
  # CSV一括登録の完了画面
  # 完了メッセージを表示する。
  #link:../captures/templates/records/complete_import_csv.png
  def complete_import_csv
  end


  #=== CSV出力
  #
  # GET /templates/1/records/download_csv
  #
  # 登録されているデータをCSV変換したものを出力する機能
  def download_csv
    respond_to do |format|
      format.csv{ send_data(@template.convert_records_csv, filename: "data.csv") }
    end
  end

  #=== RDF出力
  #
  # GET /templates/1/records/download_rdf
  #
  # 登録されているデータをRDF変換したものを出力する機能
  def download_rdf
    template_records = @template.template_records.order("template_records.id").includes([:user, {values: :content}])
    rdf = Sengu::Rdf::Builder.new(@template, template_records)
    send_data(rdf.to_rdf, filename: "rdf.xml")
  end

  #=== 入力内容のキーワード検索
  #
  # POST /templates/1/records/search_keyword
  #
  # 「登録内容の確認」ボタンを押下された場合にモーダル表示される画面。
  # キーワードに一致した者を表示する。
  #link:../captures/templates/records/search_keyword.png
  def search_keyword
    @element = Element.find(params[:element_id])
    @keywords = params[:keyword].split(" ") # スペース区切り
    if @keywords.size > 5
      @error = t(".there_are_many_keyword", count: 5)
    else
      tp_ids = @template.has_parent? ? [@template.id, @template.parent.id] : [@template.id]
      @content_lists = @keywords.map do |key|
        ElementValue::Line.includes(element_value: :template_record)
                          .references(:element_value)
                          .where("element_values.template_id IN (?)", tp_ids)
                          .where("element_values.element_id = ? AND value LIKE ?", @element.id, "%#{key}%")
      end
    end
  end


  #=== 要素毎の説明表示画面
  #
  # GET /templates/1/records/element_description
  #
  # データの登録画面等でテンプレート要素名の横に表示されるハテナマークを
  # クリックしたときに表示される要素の説明画面
  #link:../captures/templates/records/element_description.png
  def element_description
    @element = Element.find(params[:element_id])
    @item_number = params[:item_number]
    @conditions = @element.input_conditions
    render partial: "element_description"
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
    @item_number = params[:item_number]
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
    values = @element_relation_content_search.search.to_a
    @values = Kaminari.paginate_array(values).page(params[:page]).per(5)
    if @element_relation_content_search.input_type.template?
      @source_element = @element_relation_content_search.element.source_element
    end
    @selected_id = params[:selected_id] if @element_relation_content_search.input_type.pulldown?
  end

  #=== 選択した関連データの表示
  #
  # GET /templates/1/records/1/display_relation_contents
  #
  # チェックボックスやプルダウン項目で選択しているデータを表示する画面
  #link:../captures/templates/records/display_relation_contents.png
  def display_relation_contents
    @element = Element.find(params[:element_id])
    records = @template_record.record_values_by_element(@element).select{|v|v.item_number.to_i == params[:item_number].to_i}.map{|v|v.content.try(:reference)}
    @records = Kaminari.paginate_array(records).page(params[:page]).per(5)

    klass = @element.source_type.constantize
    case klass.name
    when Template.name
      @relation_template = @element.source
      @source_element = @element.source_element
    when Vocabulary::Element.name
      @relation_template = klass.includes(:values).find(@element.source_id)
    end
  end

  #
  #=== ファイルアップロード機能でアップロードしたファイルをダウンロード
  def download_file
    @element_value = @template.element_values.find_by(id: params[:element_value_id], record_id: @template_record.id)
    @content = @element_value.try(:content)
    path = @content.try(:path)
    if params[:element_value_id] =~ /[^0-9]/ || @content.blank? || !File.exist?(path)
      return render nothing: true, status: 404
    end
    send_file(path, filename: @content.value)
  end

  #=== データ登録フォームの追加
  def add_form
    @index = params[:index].to_i
    @element = Element.find(params[:element_id])
  end

  #=== データ登録フォームをネームスペース毎に追加
  def add_namespace_form
    @item_number = params[:item_number].to_i
    @index = params[:index]
    @element = Element.find(params[:element_id])
    set_prefs_and_cities
  end

  #=== データ入力サンプル画面
  #
  # GET /templates/1/records/sample_field
  #
  # 作成したテンプレートをもとにデータの入力画面のサンプルを表示する
  #link:../captures/templates/records/sample_field.png
  def sample_field
    @template_record ||= @template.template_records.build
    set_form_assigns
  end

  private

    #=== フォームで使用するインスタンスのセット
    def set_form_assigns
      @elements = @template.all_elements.root.availables.includes(:input_type, :source)
      set_prefs_and_cities
    end

    #=== 県情報と市町村情報をセット
    def set_prefs_and_cities
      @prefs = KokudoPref.all
      @cities = @prefs.first.try(:cities) || []
    end

    #=== @template_recordをセット
    def set_template_record
      @template_record = TemplateRecord.includes(values: :content).find(params[:id])
    end

    #=== @template_recordが編集できるかを判定
    def editable_check
      unless @template_record.editable?(current_user)
        return redirect_to template_records_path(template_id: @template.id), alert: t("alerts.can_not_access")
      end
    end

    #=== @template_recordが削除できるかを判定
    def destroyable_check
      unless @template_record.destroyable?(current_user)
        return redirect_to template_records_path(template_id: @template.id), alert: t("alerts.can_not_access")
      end
    end

    #=== template_recordのパラメータを検査
    def record_params
      params[:template_record].permit(
        values_attributes: [
          :element_id, :kind, :id, :template_id, :content_type, :content_id,
          content_attributes: [:value, :id, :type, :upload_file]
        ]
      )
    end

    #=== params[:import_csv]パラメータを検査
    def import_csv_params
      params[:import_csv].blank? ? {} : params[:import_csv].permit(:csv)
    end
end
