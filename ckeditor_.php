<!doctype html>
<html lang="th-TH">
<head>
<meta charset="utf-8">
<title>CKEditor: Content Templates</title>
</head>
<body>
<form method="post" id="contentF">
  <div id="editor">
    <ul class="nav navbar-nav navbar-right">
      @foreach($menus as $menu)
      <li class="menu-item menu-item-type-custom menu-item-object-custom"><a class="anchor" href="#section{!!$menu['link']!!}">{!!$menu['label']!!}</a></li>
      @endforeach
    </ul>
  </div>
  <textarea id="content" cols="50" rows="10"></textarea>
  <input type="submit" value="Send">
</form>
<script src="vendor/components/jquery/jquery.min.js"></script> 
<script src="vendor/ckeditor/ckeditor/ckeditor.js"></script> 
<script>
$(function(){

	CKEDITOR.inline('editor', {
    "allowedContent": true,
    "autoParagraph": false,
    "basicEntities": false,
    "entities": false,
    "entities_additional": "",
    "entities_greek": false,
    "entities_latin": false,
    "entities_processNumerical": false,
    "htmlEncodeOutput": false,
    "langEntries": "en",
	})

	$('#contentF').submit(function(event) {
			event.preventDefault();
			
		var data = CKEDITOR.instances.editor.getData();	alert()
		jQuery('#content').val(data);
	});

});
</script>
</body>
</html>