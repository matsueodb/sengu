module Templates::ElementsHelper

  #
  #=== InputTypeによって、表示するフォームを切り替える
  #
  def render_form_with_input_type(template, element, input_type, options = {})
    dir = options.delete(:dir) || "forms"
    locals = {input_type: input_type, template: template, element: element}
    locals.merge!(child_index: options.delete(:child_index)) if options[:child_index]
    if input_type.present?
      if input_type.vocabulary?
        return render partial: "templates/elements/#{dir}/vocabulary_form", locals: locals
      elsif input_type.template?
        return render partial: "templates/elements/#{dir}/template_select_form", locals: locals
      end
    end
    render partial: "templates/elements/#{dir}/other_form", locals: locals
  end

  #
  #=== elementsを一括で更新する際のエラーメッセージの表示
  #
  def error_messages_for_nested_elements(elements)
    messages = elements.map do |element|
      element.errors.full_messages.map{ |m| element.full_name + " " + m }
    end.flatten.compact
    render_error_messages(messages)
  end

  #
  #=== 関連データの入力方法のセレクトを表示する。
  #
  #==== 引数
  # * input_type - フォームで選択中の入力タイプ
  # * selected - デフォルトの選択値
  def options_for_select_with_data_input_ways(input_type, selected = "")
    if diws = Element::DATA_INPUT_WAYS[input_type.name.to_sym]
      lists = diws.map{|k,v|[t("element.data_input_way_label.#{k}"), v]}

      options_for_select(lists, selected.to_s)
    end
  end
end
