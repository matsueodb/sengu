#
#=== テンプレート要素を語彙データベースから検索し、作成などを行う
#
module Vdb
  class Templates::ElementSearchesController < ::Vdb::ApplicationController
    include ::Concerns::TemplatesController
    helper ::Templates::RecordsHelper

    before_action :template_operator_check
    before_action :set_form_assigns, only: [:element_sample_field, :complex_sample_field]

    #
    #=== 語彙データ検索フォーム画面
    #
    # GET /vdb/templates/1/element_searches
    #
    # 語彙データを検索するフォームをモーダル表示する
    #
    #link:../captures/templates/element_searches/index.png
    def index
      respond_to do |format|
        format.js{ @template_element_search = TemplateElementSearch.new }
      end
    end

    #
    #=== 語彙データ検索結果表示画面
    #
    # POST /vdb/templates/1/element_searches/find
    #
    # 語彙データを検索する
    #
    #link:../captures/templates/element_searches/find.png
    def find
      respond_to do |format|
        format.js do
          @template_element_search = TemplateElementSearch.new(element_search_params)
          if @template_element_search.valid?
            @complexes = @template_element_search.find_complexes
          end
        end
      end
    end

    #
    #=== 語彙データ検索結果表示画面
    #
    # POST /vdb/templates/1/element_searches/search
    #
    # 語彙データを検索する
    #
    #link:../captures/templates/element_searches/search.png
    def search
      respond_to do |format|
        format.js do
          @template_element_search = TemplateElementSearch.new(element_search_params)
          if @template_element_search.valid?
            responses = @template_element_search.search
            return if @template_element_search.errors.present?
            complexes = responses.map(&:complexes).flatten
            if complexes.blank?
              @template_element_search.errors.add(:base, t(".no_element"))
              return
            end

            names = complexes.map(&:name).uniq
            @template_element_search = TemplateElementSearch.new(name: names, user_id: current_user.id)
            @complexes = @template_element_search.find_complexes
          end
        end
      end
    end


    #
    #=== 入力フィールドのサンプル表示
    #
    # POST /vdb/templates/1/element_searches/element_sample_field
    #
    # パイロットシステムから取得した項目の入力フィールドのサンプルを表示する
    #
    def element_sample_field
      respond_to do |format|
        format.js do
          if element_item = TemplateElementSearch.new(element_search_params).find_element
            @elements = [element_item.to_element(@template.id)]
            @elements.each_with_index{|e, idx| e.id = idx }
            @template_record = @template.template_records.build
            @template_record.build_element_values_by_elements(@elements, @template.id)
          else
            @error_messages = t('.failure')
          end
        end
      end
    end

    #
    #=== 入力フィールドのサンプル表示
    #
    # POST /vdb/templates/1/element_searches/complex_sample_field
    #
    # パイロットシステムから取得した型の入力フィールドのサンプルを表示する
    #
    def complex_sample_field
      respond_to do |format|
        format.js do
          if complex = TemplateElementSearch.new(element_search_params).find_complex
            @elements = complex.to_elements(@template.id)
            @elements.each_with_index{|e, idx| e.id = idx }
            @template_record = @template.template_records.build
            @template_record.build_element_values_by_elements(@elements, @template.id)
          else
            @error_messages = t('.failure')
          end

          render 'element_sample_field'
        end
      end
    end

    #
    #=== Element作成
    #
    # POST /vdb/templates/1/element_searches/create_element
    #
    # パイロットシステムから返却された、xsd:elementに当たる要素をElementに変換し作成する
    #
    def create_element
      element_item = TemplateElementSearch.new(element_search_params).find_element

      if element_item
        if element_item.save_element(@template.id)
          redirect_to main_app.show_elements_template_elements_path(@template), notice: t('.success')
        else
          alerts = [element_item.error_messages, t(".error.workaround")].flatten
          alert = alerts.join("<br />").html_safe
          redirect_to main_app.show_elements_template_elements_path(@template), alert: alert
        end
      else
        redirect_to main_app.show_elements_template_elements_path(@template), alert: t("vdb.shared.vdb_access_failure")
      end
    end

    #
    #=== Element作成
    #
    # POST /vdb/templates/1/element_searches/create_complex_type
    #
    # パイロットシステムから返却された、xsd:complexTypetに当たる要素をElementに変換し作成する
    #
    def create_complex_type
      complex = TemplateElementSearch.new(element_search_params).find_complex

      if complex
        if complex.save_element(@template.id)
          redirect_to main_app.show_elements_template_elements_path(@template), notice: t('.success')
        else
          alerts = [complex.error_messages, t(".error.workaround")].flatten
          alert = alerts.join("<br />").html_safe
          redirect_to main_app.show_elements_template_elements_path(@template), alert: alert
        end
      else
        redirect_to main_app.show_elements_template_elements_path(@template), alert: t("vdb.shared.vdb_access_failure")
      end
    end

    def vocabulary_values
      respond_to do |format|
        format.js do
          if code_list = VocabularySearch.find(name: params[:name])
            @vocabulary_element = code_list.to_vocabulary_element
          end
        end
      end
    end

  private

    def element_search_params
      params.require(:template_element_search).permit(:name, :domain_id, :use_category, :user_id)
    end

    def set_form_assigns
      @prefs = KokudoCity.all
      @cities = @prefs.first.try(:cities) || []
    end
  end
end
