# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "click", '.template_search-modal-button', (e) ->
  e.preventDefault();

  keyword_id = $(this).data('keyword')
  data = "template_search[keyword]=" + $("#" + keyword_id).val()

  $.ajax(type: "post", url: $(this).data('url'), data: data)
  return false

$(document).on "click", '.select_data_upon_extension_preview-btn', (e) ->
  e.preventDefault();

  form_id = $(this).data("form-id")
  data = $("#" + form_id).serialize();

  $.ajax(type: "post", url: $(this).data('url'), data: data)
  return false

#
#=== ページネートしてもチェックボックスの内容を記憶する
#
class @RememberCheckboxTableForm
  constructor: (options) ->
    @form = $(options['targetEl'] || 'form')
    @checkboxName = options['checkboxName'] || "ids[]"
    @checkedList = options['defaultSelected'] || new Array
    this.paginated()

    _this = this

    $(@form).on 'submit', (e) ->
      if (!$(this).hasClass("disable-submit"))
        _this.submit()

    $(document).on 'change', '.remember-checkbox', ->
      if ( $(this).is(':checked') )
        _this.checked($(this))
      else
        _this.not_checked($(this))

  checked: (element) ->
    @checkedList.push($(element).val())

  not_checked: (element) ->
    @checkedList.some (v, i) =>
      if (v == $(element).val())
        @checkedList.splice(i, 1)

  paginated: ->
    _checkedList = @checkedList
    $('.remember-checkbox').each ->
      if $.inArray($(this).val(), _checkedList) > -1
        $(this).prop('checked', true)

  submit: ->
    $('.remember-hidden').remove()
    _form = @form
    _checkBoxName = @checkboxName
    $.each @checkedList, ->
      if $('.remember-checkbox[value=' + this + ']').size() == 0
        $('<input>').attr({
          class: 'remember-hidden',
          type: 'hidden',
          name: _checkBoxName,
          value: this
        }).appendTo(_form)
