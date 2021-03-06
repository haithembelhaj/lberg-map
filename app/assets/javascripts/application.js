// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-sprockets
//= require leaflet
//= require leaflet.markercluster
//= require nicEdit.js
//= require_tree .

jQuery(function() {
  jQuery('#flash-messages').delay(8000).fadeOut(800)
  jQuery('.dropdown-toggle').dropdown();
  jQuery('.back-button').click(function() {
    window.history.back();
  });

  // RESPONSIVE HEIGHT
  jQuery(window).resize(function(){
    var navbarHeight = jQuery('.navbar').height();
    jQuery('.map-container').height(jQuery(window).height()).css('margin-top', - (navbarHeight + 15));
    jQuery('.zoom-container').css('top', navbarHeight + 3);
    jQuery('.main-container').css('margin-top', navbarHeight + 15);
  }).resize();
});
