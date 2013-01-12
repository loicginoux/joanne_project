(function() {

  $(function() {
    $(".datepicker").datepicker({
      dateFormat: "yy-mm-dd"
    });
    $(".clear_filters_btn").click(function() {
      window.location.search = "";
      return false;
    });
    return $(".dropdown_button").popover();
  });

}).call(this);
