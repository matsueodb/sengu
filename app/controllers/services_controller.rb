#
#== サービスの管理を行うコントローラー
#
class ServicesController < ApplicationController

  before_action :authenticate_user!
  before_filter :manager_required, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_service, only: [:show, :edit, :update, :destroy, :template_list]
  before_action :section_check, only: [:edit, :update, :destroy]
  before_action :destroy_check, only: [:destroy]

  add_breadcrumb I18n.t("shared.top"), :root, except: [:index]

  #
  #=== サービス一覧表示画面
  #
  # GET /services
  #
  # サービスの一覧表示を行う画面
  #
  #link:../captures/services/index.png
  def index
    @services = Service.displayables(current_user).page(params[:page])
    @service = Service.displayables(current_user).find_by(id: params[:id]) if params[:id].present?
    respond_to do |format|
      format.html
      format.js
    end
  end

  #
  #=== サービスの詳細表示画面
  #
  # GET /services/1
  #
  # サービスの詳細表示を行う画面
  #
  #link:../captures/services/show.png
  def show
  end

  #
  #=== サービスの作成画面
  #
  # GET /services/new
  #
  # サービスの作成を行う画面
  #
  #link:../captures/services/new.png
  def new
    @service = current_user.section.services.build
  end

  #
  #=== サービスの編集画面
  #
  # GET /services/1/edit
  #
  # サービスの編集を行う画面
  #
  #link:../captures/services/edit.png
  def edit
  end

  #
  #=== サービスの作成
  #
  # POST /services
  #
  # サービスの作成を行うアクション
  #
  def create
    @service = current_user.section.services.build(service_params)

    if @service.save
      redirect_to services_url(id: @service.id), notice: t('.success')
    else
      render 'new'
    end
  end

  #
  #=== サービスの更新
  #
  # PATCH /services/1
  #
  # サービスの更新を行うアクション
  #
  def update
    if @service.update(service_params)
      redirect_to services_url(id: @service.id), notice: t('.success')
    else
      render 'edit'
    end
  end

  #
  #=== サービスの削除
  #
  # DELETE /services/1
  #
  # サービスの削除を行うアクション
  #
  def destroy
    @service.destroy
    redirect_to services_url, notice: t('.success')
  end

  #
  #=== テンプレートの一覧を表示する
  #
  def template_list
    respond_to do |format|
      format.js do
        @templates = @service.templates.includes(:service).displayables(current_user).order(:display_number)
      end
    end
  end

  #
  #=== サービスを検索する
  #
  def search
    respond_to do |format|
      format.js do
        @services = Service.displayables(current_user).search_by_keyword(service_params_as_search[:keyword]).order(:id)
      end
    end
  end

  private
    def set_service
      @service = Service.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :description)
    end

    def service_params_as_search
      params.require(:service_search).permit(:keyword)
    end

    def destroy_check
      redirect_to services_url, alert: t('.failure_exists_template') if @service.templates.present?
    end

    def section_check
      redirect_to services_url, alert: t('alerts.can_not_access') unless current_user.section_id == @service.section_id
    end
end
