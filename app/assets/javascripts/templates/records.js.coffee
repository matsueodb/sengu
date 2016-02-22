# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#=== マップモーダル
$(document).on "click", '.map-search-modal-button', (e) ->
  loadingShow()
  e.preventDefault();

  latitude = $(this).data('latitude')
  longitude = $(this).data('longitude')
  type = $(this).data('map-type')
  element_id = $(this).data('element_id')
  item_number = $(this).data('item_number')
  data = "map[latitude]=" + $("#" + latitude).val()
  data += "&map[longitude]=" + $("#" + longitude).val()
  data += "&map[map_type]=" + type
  data += "&map[element_id]=" + element_id
  data += "&map[latitude_id]=" + latitude
  data += "&map[longitude_id]=" + longitude
  data += "&item_number=" + item_number

  $.ajax
    type: "post",
    url: $(this).attr('data-url'),
    data: data,
    success: (data, status) ->
      $('<div class="modal fade map-modal">' + data + '</div>').modal();
      $('input:text:visible:first').focus();
    error: (data) ->
      loadingHide()


  return false

$(document).on "click", '.confirm-entries-modal-button', (e) ->
  e.preventDefault();

  keyword = $(this).data('keyword')
  href = $(this).data('href')
  data = {keyword: $("#" + keyword).val()}
  $.ajax(type: "post", url: href, data: data)
  return false

$(document).on "click", '.display_relation_contents_button', (e) ->
  e.preventDefault();

  href = $(this).data('href')
  $.ajax(type: "get", url: href)
  return false

# フォームの追加ボタン
$(document).on "click", '.add-form-button', (e) ->
  e.preventDefault();

  element_id = $(this).data('element-id')
  index = $(this).data('index')
  form_object_name = $(this).data('form-object-name')

  next_form_id = "#input_form_" + element_id + "_" + index

  if $(next_form_id).size() == 0
    data = "element_id=" + element_id
    data += "&index=" + index
    data += "&form_object_name=" + form_object_name

    $.ajax
      type: "post",
      url: $(this).data('href'),
      data: data,
      success: (data, status) ->
      error: (data) ->
        loadingHide()

    $(this).attr("disabled", "disabled")

    return false
  else
    # すでに次の要素がある場合は追加できない
    return false

#
#=== フォームの削除ボタン
$(document).on "click", '.remove-form-button', (e) ->
  e.preventDefault();

  remove_id = $(this).data('remove-id')
  remove_form = $("#" + remove_id)
  pa = remove_form.parent()
  remove_form.remove()
  # 項目の中から一番最後の追加ボタンをアクティブに

  $(pa).find(".add-form-button").last().removeAttr("disabled")

# ネームスペース毎のフォームの追加ボタン
$(document).on "click", '.add-namespace-form-button', (e) ->
  e.preventDefault();

  element_id = $(this).data('element-id')
  index = $(this).data('index')
  item_number = $(this).data('item-number')
  form_object_name = $(this).data('form-object-name')

  next_form_id = "#namespace_field_" + element_id + "_" + index + "_" + item_number

  if $(next_form_id).size() == 0
    data = "element_id=" + element_id
    data += "&index=" + index
    data += "&form_object_name=" + form_object_name
    data += "&item_number=" + item_number

    $.ajax
      type: "post",
      url: $(this).data('href'),
      data: data,
      success: (data, status) ->
      error: (data) ->
        loadingHide()

    $(this).attr("disabled", "disabled")
    return false
  else
    # すでに次の要素がある場合は追加できない
    return false

#
#=== フォームの削除ボタン
$(document).on "click", '.remove-namespace-form-button', (e) ->
  e.preventDefault();

  remove_id = $(this).data('remove-id')
  remove_form = $("#" + remove_id)
  pa = remove_form.parent()
  remove_form.remove()

  if $(pa).find(".add-namespace-form-button").size() == 0
    pa.remove()
  else
    # 項目の中から一番最後の追加ボタンをアクティブに
    $(pa).find(".add-namespace-form-button").last().removeAttr("disabled")
