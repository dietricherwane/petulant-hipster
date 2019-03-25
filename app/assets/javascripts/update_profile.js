//$("#numero_unique").hide();
//$("#liste_numeros").hide();

$(document).ready(function(){
  $("#post_profile_id").change(function() {
    var selected_profile = $("#post_profile_id option:selected").text();
    /*alert(selected_profile);
    if(selected_profile = "Numéro unique"){
      alert("1");
      $("#numero_unique").show();
      $("#liste_numeros").hide();
      $("#tarea").hide();
    }
    if(selected_profile = "Liste de numéros"){
      alert("2");
      $("#numero_unique").hide();
      $("#liste_numeros").show();
      $("#tarea").hide();
    }
    if(selected_profile != "Numéro unique" && selected_profile != "Liste de numéros"){
      alert("3");
      $("#numero_unique").hide();
      $("#liste_numeros").hide();
    }*/

    //$(this).get_search_params();
    //$.blockUI({ message: 'Veuillez patienter' });
    //if(selected_profile != "Numéro unique" && selected_profile != "Liste de numéros"){
      //alert("4");
      var message = $("#post_message").val();
      $(this).display_custom_fields(selected_profile, message);
    //}
    //$.unblockUI();
  });



  $.fn.display_custom_fields = function(selected_profile, message) {
    $.ajax({
      url: "/administrator/profile/custom_fields",
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
