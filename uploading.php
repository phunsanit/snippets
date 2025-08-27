<form action="uploading.php" method="post" enctype="multipart/form-data">
<br /><input type="file" name="picture" />
<input type="submit" name="Send">
</form>
<?php
if (isset($_FILES['picture']))
{ // ตรวจดูก่อนว่าอัพโหลดไฟล์เข้ามาจริงๆ
	print_r($_FILES['picture']);
    move_uploaded_file($_FILES['picture']['tmp_name'] ,'C:/xampp/htdocs/snippets/uploads/'.$_FILES['picture']['name']);
}