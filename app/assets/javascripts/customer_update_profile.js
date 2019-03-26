$(document).ready(function(){
  $("#numero_unique").hide();
  $("#liste_numeros").hide();
  $("#post_profile_id").change(function() {
    var selected_profile = $(this).find(":selected").text();
    var message = $("#post_message").val();
    $(this).display_allowed_fields(selected_profile);
    //$(this).get_search_params();
    //$.blockUI({ message: 'Veuillez patienter' });
    if(selected_profile != "Numéro unique" && selected_profile != "Liste de numéros"){
      $(this).display_custom_fields(selected_profile, message);
    }
    //$.unblockUI();
  });

  $.fn.display_allowed_fields = function(selected_profile) {
    if(selected_profile == "Numéro unique" || selected_profile == "Email unique"){
      $("#numero_unique").show();
      $("#liste_numeros").hide();
      $("#tarea").hide();
    }
    if(selected_profile == "Liste de numéros" || selected_profile == "Liste d'emails"){
      $("#numero_unique").hide();
      $("#liste_numeros").show();
      $("#tarea").hide();
    }
    if(selected_profile != "Numéro unique" && selected_profile != "Liste de numéros" && selected_profile != "Email unique" && selected_profile != "Liste d'emails"){
      $("#numero_unique").hide();
      $("#liste_numeros").hide();
      $("#tarea").show();
    }
  }

  $.fn.display_custom_fields = function(selected_profile, message) {
    $.ajax({
      url: "/customer/profile/custom_fields",
      cache: false,
      type: "GET",
      data: {selected_profile: selected_profile, message: message},
      dataType: "text",
      error: function(xhr, textStatus, errorThrown){
        alert(errorThrown);
      },
      success: function(response) {
        if(response == "nil"){
          $("#tarea").html("");
        }
        else{
          $("#tarea").html(response);
          $("#custom_columns").uniform();

          $("#custom_columns").change(function() {
            var selected_column = $(this).find(":selected").text();
            var old_tarea_value = $("#post_message").val();
            $("#post_message").val(old_tarea_value + "{" + selected_column + "}");
          });

        }
      }
    });
  }
});
