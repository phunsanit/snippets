<<<<<<< HEAD
<!doctype html>
<html>
   <head>
      <meta charset="utf-8"> 
      <title>DataTables: json</title>
      <link href="vendor/twbs/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css"> 
      <link href="vendor/fronteed/icheck/skins/square/green.css" rel="stylesheet" type="text/css"> 
      <link href="vendor/fronteed/icheck/skins/square/green.css" rel="stylesheet" type="text/css"> 
      <style type="text/css"> .icheckbox_square-green.indeterminate {background: #1b7e5a;}</style>
   </head>
   <body>
<?php
if(count($_POST)) {
   echo '<pre>', print_r($_POST, true), '</pre>';
}
?>
      <div class="container"> 
         <form action="jQuery.icheck_indeterminate.php" id="formA" method="post"> 
            <ul>
               <li>
                  <label><input checked="checked" data-group-id="centralThailand" data-group-parent="thailand" indeterminate="true" name="items[]" type="checkbox" value="ภาคกลาง"> ภาคกลาง</label>
                  <ul>
                     <li>
                        <label><input checked="checked" data-group-id="bangkok" data-group-parent="centralThailand" name="items[]" type="checkbox" value="กรุงเทพมหานคร"> กรุงเทพมหานคร</label>
                        <ul>
                           <li><label><input checked="checked" data-group-id="khlongSanDistrict" data-group-parent="bangkok" name="items[]" type="checkbox" value="เขตคลองสาน"> เขตคลองสาน</label></li>
                           <li>
                              <label><input checked="checked" data-group-id="khlongSamWaDistrict" data-group-parent="khlongSanDistrict" name="items[]" type="checkbox" value="เขตคลองสามวา"> เขตคลองสามวา</label>
                              <ul>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงคลองสามวา"> แขวงคลองสามวา</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงทรายกองดิน"> แขวงทรายกองดิน</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงทรายกองดินใต้"> แขวงทรายกองดินใต้</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงบางชัน"> แขวงบางชัน</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงสามวาตะวันตก"> แขวงสามวาตะวันตก</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงสามวาตะวันออ"> แขวงสามวาตะวันออ</label></li>
                              </ul>
                           </li>
                        </ul>
                     <li><label><input data-group-parent="centralThailand" name="items[]" type="checkbox" value="จังหวัดกำแพงเพชร"> จังหวัดกำแพงเพชร</label></li>
                     </li>
                  </ul>
               <li>
                  <label><input checked="checked" data-group-id="southernThailand" data-group-parent="thailand" indeterminate="true" name="items[]" type="checkbox" value="ภาคใต้"> ภาคใต้</label>
                  <ul>
                     <li>
                        <input checked="checked" data-group-id="trangProvince" data-group-parent="southernThailand" name="items[]" type="checkbox" value="จังหวัดตรัง"> <label for="short-1"> จังหวัดตรัง</label>
                        <ul>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="กันตัง"> กันตัง</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="นาโยง"> นาโยง</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="ปะเหลียน"> ปะเหลียน</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="ย่านตาขาว"> ย่านตาขาว</label></li>
                           <li><label><input checked="checked" data-group-parent="trangProvince" name="items[]" type="checkbox" value="รัษฎา"> รัษฎา</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="วังวิเศษ"> วังวิเศษ</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="สิเกา"> สิเกา</label></li>
                           <li><label><input checked="checked" data-group-parent="trangProvince" name="items[]" type="checkbox" value="หาดสำราญ"> หาดสำราญ</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="ห้วยยอด"> ห้วยยอด</label></li>
                           <li><label><input checked="checked" data-group-parent="trangProvince" name="items[]" type="checkbox" value="เมืองตรัง"> เมืองตรัง</label></li>
                        </ul>
                     </li>
                  </ul>
               </li>
               </li>
            </ul>
            <div class="form-group row"> 
               <label class="col-sm-2"> </label>
               <div class="col-sm-10 text-right"> <button class="btn btn-lg btn-primary" type="submit"> Save</button></div>
            </div>
         </form>
         <hr>
         <button class="btn btn-lg btn-info" id="ajaxBtn" type="button"> AJAX Value</button>
      </div>
      <script src="vendor/components/jquery/jquery.min.js"> </script>
      <script src="vendor/fronteed/icheck/icheck.min.js"> </script>
      <script>
$(function() {

   $('input').iCheck({
      "checkboxClass": "icheckbox_square-green",
      "radioClass": "iradio_square-green",
   })
   .on('ifClicked', function() {
      indeterminate ($(this));
   });

   function indeterminate(checkbox) {
      var group_id = checkbox.data('group-parent');

      var checkboxParent = $('[data-group-id="'+group_id+'"]');
      var childs = $('[data-group-parent="'+group_id+'"]');

console.log('attr = ' + checkbox.attr('checked') + ' prop = ' + checkbox.prop('checked'));

      childs.prop('checked', checkbox.prop('checked'));

      if(checkboxParent.length > 0) {

         if(childs.length == childs.filter(':checked').length) {
            checkboxParent
            .removeAttr('indeterminate')
            .iCheck('check')
            .iCheck('determinate');
         } else {
            checkboxParent
            .attr('indeterminate', true)
            .iCheck('uncheck')
            .iCheck('indeterminate');
         }

         indeterminate(checkboxParent);
      }
   }

   $('#ajaxBtn').click(function() {
      var formData = $('#formA').serializeArray();
      var message = '';

      $.each(formData, function(index, item) {
         message += '\n' + index + ' ' + item.name + ' = ' + item.value;
      });

      alert(message);
   });

});     
      </script>
   </body>
=======
<!doctype html>
<html>
   <head>
      <meta charset="utf-8"> 
      <title>DataTables: json</title>
      <link href="vendor/twbs/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css"> 
      <link href="vendor/fronteed/icheck/skins/square/green.css" rel="stylesheet" type="text/css"> 
      <link href="vendor/fronteed/icheck/skins/square/green.css" rel="stylesheet" type="text/css"> 
      <style type="text/css"> .icheckbox_square-green.indeterminate {background: #1b7e5a;}</style>
   </head>
   <body>
<?php
if(count($_POST)) {
   echo '<pre>', print_r($_POST, true), '</pre>';
}
?>
      <div class="container"> 
         <form action="jQuery.icheck_indeterminate.php" id="formA" method="post"> 
            <ul>
               <li>
                  <label><input checked="checked" data-group-id="centralThailand" data-group-parent="thailand" indeterminate="true" name="items[]" type="checkbox" value="ภาคกลาง"> ภาคกลาง</label>
                  <ul>
                     <li>
                        <label><input checked="checked" data-group-id="bangkok" data-group-parent="centralThailand" name="items[]" type="checkbox" value="กรุงเทพมหานคร"> กรุงเทพมหานคร</label>
                        <ul>
                           <li><label><input checked="checked" data-group-id="khlongSanDistrict" data-group-parent="bangkok" name="items[]" type="checkbox" value="เขตคลองสาน"> เขตคลองสาน</label></li>
                           <li>
                              <label><input checked="checked" data-group-id="khlongSamWaDistrict" data-group-parent="khlongSanDistrict" name="items[]" type="checkbox" value="เขตคลองสามวา"> เขตคลองสามวา</label>
                              <ul>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงคลองสามวา"> แขวงคลองสามวา</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงทรายกองดิน"> แขวงทรายกองดิน</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงทรายกองดินใต้"> แขวงทรายกองดินใต้</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงบางชัน"> แขวงบางชัน</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงสามวาตะวันตก"> แขวงสามวาตะวันตก</label></li>
                                 <li><label><input checked="checked" data-group-parent="khlongSamWaDistrict" name="items[]" type="checkbox" value="แขวงสามวาตะวันออ"> แขวงสามวาตะวันออ</label></li>
                              </ul>
                           </li>
                        </ul>
                     <li><label><input data-group-parent="centralThailand" name="items[]" type="checkbox" value="จังหวัดกำแพงเพชร"> จังหวัดกำแพงเพชร</label></li>
                     </li>
                  </ul>
               <li>
                  <label><input checked="checked" data-group-id="southernThailand" data-group-parent="thailand" indeterminate="true" name="items[]" type="checkbox" value="ภาคใต้"> ภาคใต้</label>
                  <ul>
                     <li>
                        <input checked="checked" data-group-id="trangProvince" data-group-parent="southernThailand" name="items[]" type="checkbox" value="จังหวัดตรัง"> <label for="short-1"> จังหวัดตรัง</label>
                        <ul>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="กันตัง"> กันตัง</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="นาโยง"> นาโยง</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="ปะเหลียน"> ปะเหลียน</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="ย่านตาขาว"> ย่านตาขาว</label></li>
                           <li><label><input checked="checked" data-group-parent="trangProvince" name="items[]" type="checkbox" value="รัษฎา"> รัษฎา</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="วังวิเศษ"> วังวิเศษ</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="สิเกา"> สิเกา</label></li>
                           <li><label><input checked="checked" data-group-parent="trangProvince" name="items[]" type="checkbox" value="หาดสำราญ"> หาดสำราญ</label></li>
                           <li><label><input data-group-parent="trangProvince" name="items[]" type="checkbox" value="ห้วยยอด"> ห้วยยอด</label></li>
                           <li><label><input checked="checked" data-group-parent="trangProvince" name="items[]" type="checkbox" value="เมืองตรัง"> เมืองตรัง</label></li>
                        </ul>
                     </li>
                  </ul>
               </li>
               </li>
            </ul>
            <div class="form-group row"> 
               <label class="col-sm-2"> </label>
               <div class="col-sm-10 text-right"> <button class="btn btn-lg btn-primary" type="submit"> Save</button></div>
            </div>
         </form>
         <hr>
         <button class="btn btn-lg btn-info" id="ajaxBtn" type="button"> AJAX Value</button>
      </div>
      <script src="vendor/components/jquery/jquery.min.js"> </script>
      <script src="vendor/fronteed/icheck/icheck.min.js"> </script>
      <script>
$(function() {

   $('input').iCheck({
      "checkboxClass": "icheckbox_square-green",
      "radioClass": "iradio_square-green",
   })
   .on('ifClicked', function() {
      indeterminate ($(this));
   });

   function indeterminate(checkbox) {
      var group_id = checkbox.data('group-parent');

      var checkboxParent = $('[data-group-id="'+group_id+'"]');
      var childs = $('[data-group-parent="'+group_id+'"]');

console.log('attr = ' + checkbox.attr('checked') + ' prop = ' + checkbox.prop('checked'));

      childs.prop('checked', checkbox.prop('checked'));

      if(checkboxParent.length > 0) {

         if(childs.length == childs.filter(':checked').length) {
            checkboxParent
            .removeAttr('indeterminate')
            .iCheck('check')
            .iCheck('determinate');
         } else {
            checkboxParent
            .attr('indeterminate', true)
            .iCheck('uncheck')
            .iCheck('indeterminate');
         }

         indeterminate(checkboxParent);
      }
   }

   $('#ajaxBtn').click(function() {
      var formData = $('#formA').serializeArray();
      var message = '';

      $.each(formData, function(index, item) {
         message += '\n' + index + ' ' + item.name + ' = ' + item.value;
      });

      alert(message);
   });

});     
      </script>
   </body>
>>>>>>> no message
</html>