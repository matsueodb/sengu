#
#=== 語彙データベースからテンプレートの項目を作成するコントローラ
#
# テンプレートが属するサービスの所属の管理者・所属の管理者のみがアクセスできる
#
module Vdb
  class Templates::ElementsController < ::Vdb::ApplicationController
    include ::Concerns::TemplatesController
    
    layout "template_elements"

    before_action :template_operator_check

    #
    #=== テンプレート編集画面
    #
    # GET /vdb/templates/1/elements/new
    #
    # テンプレートのカスタマイズ画面
    #
    #link:../captures/templates/elements/new.png
    def new
      @element = Element.new
      @template_element_search = TemplateElementSearch.new
    end
  end
end
