//= require ./init
// = require_tree ./admin
//= require active_admin/base

jQuery(document).ready(function($) {
       // get the page action
    var action,model, b = $("body");
    if (b.hasClass("edit")) {
        action = "edit";
    } else if(b.hasClass("view")){
        action = "view";
    } else if(b.hasClass("index")){
        action = "index"
    } else if(b.hasClass("new")){
        action = "new"
    }

    // run the code specific to a model and an action
    for (var m in foodrubix) {
        if (b.hasClass("admin_"+m)) {
            if (foodrubix[m][action] && typeof foodrubix[m][action] == "function") {
                foodrubix[m][action]();
                break;
            }
        }
    }
});