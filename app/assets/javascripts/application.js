// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery.treetable
//= require jquery.ui.datepicker
//= require jquery.ui.all
//= require jquery.ui.datepicker-ja
//= require twitter/bootstrap
//= require_tree .
//= require turbolinks

//// modal close時に.modal削除
$(document).on('hidden.bs.modal', '.modal', function(){
    $(this).remove()
});

$(document).on("click", ".loading-display", function(){
  loadingShow()
})

$(document).on("ajax:beforeSend", ".ajax-loading-display", function(){
  loadingShow()
})

$(document).on("ajax:complete", ".ajax-loading-display", function(){
  loadingHide()
})

function loadingShow(){
  $('#loading').show()
}

function loadingHide(){
  $('#loading').hide()
}
