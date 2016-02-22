module Templates::RecordsHelper
  #
  #=== 都道府県のセレクトを返す
  #
  def options_for_select_with_prefs(prefs, selected = "")
    list = prefs.map{|pre|[pre.name, pre.id]}
    options_for_select(list, selected)
  end

  #
  #=== 関連データのプルダウンを返す
  #
  def options_for_select_with_reference_values(element, selected = "")
    lists = element.selection_of_reference_values
    lists.unshift([t("shared.non_select"), ""])
    options_for_select(lists, selected.to_i)
  end

  #
  #=== 関連データのラジオボタンを返す
  #
  def reference_values_radio_button(element, field_name, selected = "", options = {})
    html = ""
    lists = element.selection_of_reference_values
    lists.unshift([t("shared.non_select"), ""])
    lists.each do |label, val|
      html += content_tag(:label, class: "radio-inline") do
        radio_button_tag( field_name, val, (selected == val), options) + label
      end
    end
    return raw html
  end

  #=== 追加ボタンタグ
  def add_button_tag(label = "")
    content_tag(:span, label , class: "glyphicon glyphicon-plus")
  end

  #=== 削除ボタンタグ
  def remove_button_tag(label = "")
    content_tag(:span, label, class: "glyphicon glyphicon-minus")
  end

  #
  #=== 入力フォームの追加ボタンを返す。
  def add_form_button(template, element, index, disabled = false)
    opts = {
      class: "btn btn-success add-form-button ajax-loading-display",
      method: :post,
      data: {
        "element-id" => element.id, "index" => index,
        "href" => add_form_template_records_path(template_id: template.id)
      }
    }
    opts.merge!("disabled" => "disabled") if disabled
    link_to(add_button_tag, "javascript:;", opts)
  end

  #
  #=== 入力フォームの削除ボタンを返す
  def remove_form_button(element_id, index)
    link_to(remove_button_tag, "javascript:;",
      {
        class: "btn btn-danger remove-form-button",
        data: {"remove-id" => "input_form_#{element_id}_#{index}"}
      }
    )
  end

  #
  #=== 必須入力を表すアイコンを表示
  def required_icon
    label = "（#{Element.human_attribute_name(:required)}）"
    content_tag(:strong, label, class: "text-danger")
  end

  #
  #=== ネームスペース単位で入力フォームを追加するボタン
  def add_namespace_form_button(template, element, item_number, index, disabled = false)
    opts = {
      class: "btn btn-success add-namespace-form-button ajax-loading-display",
      method: :post,
      data: {
        "element-id" => element.id, "index" => index,
        "item-number" => item_number,
        "href" => add_namespace_form_template_records_path(template_id: template.id)
      }
    }
    opts.merge!("disabled" => "disabled") if disabled
    link_to(add_button_tag, "javascript:;", opts)
  end

  #
  #=== ネームスペース毎の入力フォームの削除ボタンを返す
  def remove_namespace_form_button(element_id, item_number, index, disabled = false)
    opts = {
      class: "btn btn-danger remove-namespace-form-button",
      data: {"remove-id" => "namespace_field_#{element_id}_#{index}_#{item_number}"}
    }
    opts.merge!("disabled" => "disabled") if disabled
    link_to(remove_button_tag, "javascript:;", opts)
  end

  #
  #=== 時間のセレクトタグを設置
  def options_for_select_with_hours(selected = "")
    lists = (0..23).to_a.map{|n|[("%02d" % n) , n]}
    lists.unshift([t("shared.non_select"), ""])
    options_for_select(lists, (selected.blank? ? "" : selected.to_i))
  end

  #
  #=== 分のセレクトタグを設置
  def options_for_select_with_minutes(selected = "")
    lists = []
    n = 0
    while n < 60
      lists << n
      n += 5
    end
    lists = lists.map{|n|[("%02d" % n) , n]}
    lists.unshift([t("shared.non_select"), ""])
    options_for_select(lists, (selected.blank? ? "" : selected.to_i))
  end
end
