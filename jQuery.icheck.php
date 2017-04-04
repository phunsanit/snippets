<!doctype html>
<html>
   <head>
      <meta charset="utf-8">
      <title>DataTables: json</title>
      <link href="vendor/twbs/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css">
      <link href="vendor/fronteed/icheck/skins/square/green.css" rel="stylesheet" type="text/css">
      <link href="vendor/fronteed/icheck/skins/square/green.css" rel="stylesheet" type="text/css">
   </head>
   <body>
<?php
if(count($_POST)) {
   echo '<pre>', print_r($_POST, true), '</pre>';
}
?>
      <div class="container">
         <form action="jQuery.icheck.php" id="formA" method="post">
            <fieldset class="form-group row">
               <legend class="col-form-legend col-sm-2">Checkbox</legend>
               <div class="col-sm-10">
                  <div class="form-check">
                     <label class="form-check-label">
                     <input class="form-check-input" name="checkbox1" type="checkbox" value="checkbox1" checked> Check me out
                     </label>
                  </div>
                  <div class="form-check">
                     <label class="form-check-label">
                     <input class="form-check-input" name="checkbox2" type="checkbox" value="checkbox2"> Check me
                     </label>
                  </div>
                  <div class="form-check">
                     <label class="form-check-label">
                     <input class="form-check-input" name="checkbox3" type="checkbox" value="checkbox3" disabled> Check is disabled
                     </label>
                  </div>
               </div>
            </fieldset>
            <fieldset class="form-group row">
               <legend class="col-form-legend col-sm-2">Radios</legend>
               <div class="col-sm-10">
                  <div class="form-check">
                     <label class="form-check-label">
                     <input class="form-check-input" type="radio" name="radio" id="gridRadios1" value="option1" checked> Check me out
                     </label>
                  </div>
                  <div class="form-check">
                     <label class="form-check-label">
                     <input class="form-check-input" type="radio" name="radio" id="gridRadios2" value="option2"> Check me
                     </label>
                  </div>
                  <div class="form-check disabled">
                     <label class="form-check-label">
                     <input class="form-check-input" type="radio" name="radio" id="gridRadios3" value="option3" disabled> Check is disabled
                     </label>
                  </div>
               </div>
            </fieldset>
            <div class="form-group row">
               <label class="col-sm-2"></label> 
               <div class="col-sm-10 text-right">
                  <button class="btn btn-lg btn-primary" type="submit">Save</button>
               </div>
            </div>
         </form>
         <hr>
         <button class="btn btn-lg btn-info" id="ajaxBtn" type="button">AJAX Value</button>
      </div>
      <script src="vendor/components/jquery/jquery.min.js"></script>
      <script src="vendor/fronteed/icheck/icheck.min.js"></script>
      <script>
         $(function () {
         
            $('input').iCheck({
               "checkboxClass": "icheckbox_square-green",
               "radioClass": "iradio_square-green",
            });
         
            $('#ajaxBtn').click(function(){
               var formData = $('#formA').serializeArray();
               var message = '';

               $.each(formData, function (index, item) {
                  message +='\n' +  index + ' ' +  item.name + ' = '+item.value;
               });

               alert(message);

            });

         });     
               
      </script>
   </body>
</html>