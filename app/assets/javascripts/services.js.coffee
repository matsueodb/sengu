# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'show.bs.collapse', 'div#accordion > div.panel > div.panel-collapse', ->
  icon_id = $(this).data("icon-id")
  $("#" + icon_id).removeClass("glyphicon-chevron-down").addClass("glyphicon-chevron-up");


$(document).on 'hide.bs.collapse', 'div#accordion > div.panel > div.panel-collapse', ->
  icon_id = $(this).data("icon-id")
  $("#" + icon_id).removeClass("glyphicon-chevron-up").addClass("glyphicon-chevron-down");