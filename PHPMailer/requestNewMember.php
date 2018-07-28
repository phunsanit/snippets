<?php 
header('X-Frame-Options: *');
header("X-XSS-Protection: 1");
header('X-Content-Type-Options: nosniff');
 //ini_set('display_errors', 1);
 //ini_set('display_startup_errors', 1);
//error_reporting(E_ALL);
//ini_set('display_errors', 'On');
require_once("../Connections/conn_database.php");
require_once("../includes/_define.inc.php");

mysql_select_db($database_conn_database, $conn_database);

//ini_set('display_errors', 'On');
//error_reporting(E_ALL);

$isNewUser = true;
if (!function_exists("GetSQLValueString")) {
function GetSQLValueString($theValue, $theType, $theDefinedValue = "", $theNotDefinedValue = "") 
{
  if (PHP_VERSION < 6) {
    $theValue = get_magic_quotes_gpc() ? stripslashes($theValue) : $theValue;
  }

  $theValue = function_exists("mysql_real_escape_string") ? mysql_real_escape_string($theValue) : mysql_escape_string($theValue);

  switch ($theType) {
    case "text":
      $theValue = ($theValue != "") ? "'" . $theValue . "'" : "NULL";
      break;    
    case "long":
    case "int":
      $theValue = ($theValue != "") ? intval($theValue) : "NULL";
      break;
    case "double":
      $theValue = ($theValue != "") ? doubleval($theValue) : "NULL";
      break;
    case "date":
      $theValue = ($theValue != "") ? "'" . $theValue . "'" : "NULL";
      break;
    case "defined":
      $theValue = ($theValue != "") ? $theDefinedValue : $theNotDefinedValue;
      break;
  }
  return $theValue;
}
}

$memberid = (isset($_REQUEST["memberid"]) && $_REQUEST["memberid"]!="")? preg_replace("/[\&#\?\]\[\/\\\<\>\'\"\*\:\(\);]*/i","",$_REQUEST["memberid"]): ""; 
$email = (isset($_REQUEST["email"]) && $_REQUEST["email"]!="")? (preg_replace("/[\&#\?\]\[\/\\\<\>\'\"\*\:\(\);]*/i","",$_REQUEST["email"])) : "";
$birthday = (isset($_REQUEST["dob"]) && $_REQUEST["dob"]!="")? (preg_replace("/[\&#\?\]\[\<\>\'\"\*\:\(\);]*/i","",$_REQUEST["dob"])) : "";
mysql_select_db($database_conn_database, $conn_database);
///echo ('debug 0 ===========');
//request for new password

//echo 'memberid: '.$memberid.'== email'.$email . ' == birthday'.$birthday;
if(!(isset($_REQUEST["memberid"]) && $_REQUEST["memberid"]!="") && (isset($_REQUEST["email"]) && $_REQUEST["email"]!=""))
{
	$isNewUser = false; //forget password
	// check member id is exist or not
	
	
	
	$query_rs_check_memberid = "SELECT * FROM users WHERE username LIKE '".$email."'";
		$rs_check_memberid = mysql_query($query_rs_check_memberid, $conn_database) or die(mysql_error());
		$row_rs_check_memberid = mysql_fetch_assoc($rs_check_memberid);
		$totalRows_rs_check_memberid = mysql_num_rows($rs_check_memberid);
		
		if($totalRows_rs_check_memberid == 1){

			$memberid = $row_rs_check_memberid["memberID"];
			//SELECT  `m_insured`.`m_name`, FROM `datamart`.`m_insured` where `m_insured`.`m_insuredNo` = %s;
			
			$query_member = sprintf("SELECT  `m_insured`.`m_name` FROM `datamart`.`m_insured` where `m_insured`.`m_insuredNo` = %s;", GetSQLValueString($memberid, "text"));
			$rs_member = mysql_query($query_member, $conn_database) or die(mysql_error());
			$row_member = mysql_fetch_assoc($rs_member);

				//check if 
				$query_rs_check_memberid = "SELECT * FROM users WHERE username LIKE '".$email."'";
				$rs_check_memberid = mysql_query($query_rs_check_memberid, $conn_database) or die(mysql_error());
				$row_rs_check_memberid = mysql_fetch_assoc($rs_check_memberid);
				
				/*$updateSQL = sprintf("UPDATE users SET password = md5(concat(upper(memberID),%s)) WHERE memberID = %s",
				GetSQLValueString(md5(HASH_SALT. md5($_POST['password'])), "text"),

							   GetSQLValueString($result_decode["member"], "text"));
		   

				mysql_select_db($database_conn_database, $conn_database);
				$Result1 = mysql_query($updateSQL, $conn_database) or die(mysql_error());*/ 
				
				$token = md5(uniqid());
				
				$insertSQL = sprintf("INSERT INTO `online_service`.`forget_password`(`memberID`,`token`,`createDate`,`active`)VALUES(%s,%s,now(),'YES');",
				GetSQLValueString($_REQUEST["email"], "text"), GetSQLValueString($token, "text"));

				mysql_select_db($database_conn_database, $conn_database);
				$Result1 = mysql_query($insertSQL , $conn_database) or die(mysql_error());
				
				$temp_text_return = sprintf("Your request is successfully completed.<br><br>Information will be sent to your registered email.");
				//$memberID = $result_decode["member"];
				//$memberName = $result_decode["memberInfo"]["name"];
				//$mmberSurname = $result_decode["memberInfo"]["surname"];
				//$password = $result_decode[" array("result"=>"35", "member"=>"37""];
				if(isset($_REQUEST["currDomain"])&& $_REQUEST["currDomain"]!=''){
					if($_REQUEST["currDomain"]=="sea.msh-intl.com"){
						$webUrl = "http://sea.msh-intl.com/onlineservice";
					}else{
						$webUrl = WEBSITE_URL;
					}
				
				}else{
					$webUrl = WEBSITE_URL;
				}
				//if(WEBSITE_URL!='http://'.$_REQUEST["currDomain"]){
				//	$webUrl = "http://sea.msh-intl.com/onlineservice";
				//}
				$emailResetPwdUrl= $webUrl;
				$result_decode = array("result"=>"ok", "member"=>$row_member["m_name"], "memberInfo"=> array("name"=>$row_member["m_name"], "surname"=>""),"password"=> $emailResetPwdUrl."/forgetpassword.php?token=".$token );
				sendUserMail($result_decode,$isNewUser); 
				$ret = Array ("result" => "success", "reference" => $temp_text_return);
				$jsonstring = json_encode($ret);
				
				echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')';
				//echo $jsonstring;
				exit;
			//}
			/*else{



				$ret = Array ("result" => "failed", "reference" => "There are some problems of your request. Please contact  claims@lumahealth.com or +662-665-3600 for any inquiry.<br><br>Thank you.");
				
				$jsonstring = json_encode($ret);
				echo $jsonstring;
				exit;
			}*/
			exit; 
			
		}else{ 
			$ret = Array ("result" => "failed", "reference" => "Your requested information is not valid.");
				
				$jsonstring = json_encode($ret);
				
				echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')';
				exit;
		}
}// request for new member
else if(isset($_REQUEST["memberid"]) && $_REQUEST["memberid"]!=""){
			$query_rs_check_all_memberid = "SELECT u.*,i.*
 , hdr.* 

FROM online_service.users u 
right outer join datamart.m_insured i on u.memberID=i.m_insuredDependenceNo 
left outer join 
(select hd.m_name as holderName, hd.m_surname as holderSurName ,
hd.m_insuredDependenceNo as dependenceNo,
hd.m_insuredNo as insuredNo,
hd.m_email as hd_email 
from datamart.m_insured hd  
where hd.m_insuredDependenceNo = (select ii.m_insuredNo from datamart.m_insured ii where ii.m_insuredDependenceNo='".$memberid."'))  hdr
on  i.m_insuredNo = hdr.dependenceNo 
where u.username ='". $email ."'";//
//echo $query_rs_check_all_memberid;
	$rs_check_all_memberid = mysql_query($query_rs_check_all_memberid, $conn_database) or die(mysql_error());
	$row_rs_check_all_memberid = mysql_fetch_assoc($rs_check_all_memberid);
	$totalRows_rs_check_all_memberid = mysql_num_rows($rs_check_all_memberid);
//	echo ('debug 1 totalRows_rs_check_all_memberid :==========='. $totalRows_rs_check_all_memberid);
	if($totalRows_rs_check_all_memberid == 1){
//			
			$ret = Array ("result" => "failed", "reference" => "Email is exist. Please choose different email.");
				
					$jsonstring = json_encode($ret);
					
					echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')';
					exit; 
		
	}
	
	$query_rs_check_all_memberid = "SELECT u.*,i.*
 , hdr.* 

FROM online_service.users u 
right outer join datamart.m_insured i on u.memberID=i.m_insuredDependenceNo 
left outer join 
(select hd.m_name as holderName, hd.m_surname as holderSurName ,
hd.m_insuredDependenceNo as dependenceNo,
hd.m_insuredNo as insuredNo,
hd.m_email as hd_email 
from datamart.m_insured hd 
where hd.m_insuredDependenceNo = (select ii.m_insuredNo from datamart.m_insured ii where ii.m_insuredDependenceNo='".$memberid."'))  hdr
on  i.m_insuredNo = hdr.dependenceNo 
where i.m_insuredDependenceNo ='".$memberid."'";//
//echo $query_rs_check_all_memberid;
	$rs_check_all_memberid = mysql_query($query_rs_check_all_memberid, $conn_database) or die(mysql_error());
	$row_rs_check_all_memberid = mysql_fetch_assoc($rs_check_all_memberid);
	$totalRows_rs_check_all_memberid = mysql_num_rows($rs_check_all_memberid);
//	echo ('debug 1 totalRows_rs_check_all_memberid :==========='. $totalRows_rs_check_all_memberid);
	if($totalRows_rs_check_all_memberid == 1){
//		echo ('debug 1 ===========');
		//case that having no dependency user registered before
		if($row_rs_check_all_memberid['username']=='' && $row_rs_check_all_memberid['m_insuredDependenceNo']== $memberid ){
//			echo ('debug 2 ===========');
			if($row_rs_check_all_memberid['m_relationType']!='Insured'){
//				echo ('debug 3 ===========');

				$temp = $birthday;

					$array = explode("/",$temp);
					$tmpMonth =  date_parse($array[1]);//date('m',strtotime($array[1]));
					$nmonth = $tmpMonth['month'];
					$nmonth = str_pad($nmonth,2,"0",STR_PAD_LEFT);
					$dom = str_pad($array[0],2,"0",STR_PAD_LEFT);  

					$birthday = $array[2].'-'.$nmonth.'-'.$dom ;

					//$birthday = str_replace("/","-",$birthday);//2001-09-15 
					echo '------------ m_birthDate'.$row_rs_check_all_memberid['m_birthDate'].':'.$birthday; 
				if($email== $row_rs_check_all_memberid['hd_email']){ 
					$ret = Array ("result" => "failed", "reference" => "Sorry, This email have been used for Policy Holder's account already. Please use different email.");
				
					$jsonstring = json_encode($ret);
					
					echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')';
					exit; 
				}elseif( $birthday != $row_rs_check_all_memberid['m_birthDate'] ){ 
					$ret = Array ("result" => "failed", "reference" => "Your Date of birth is not correct.");
				
					$jsonstring = json_encode($ret);
					
					echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')';
					exit; 
					 
				}else{
					//echo ('debug 4 ==========='); 
					$name = $row_rs_check_all_memberid['holderName'] ; 
					$surname = $row_rs_check_all_memberid['holderSurName'];
					$receipient = $row_rs_check_all_memberid['hd_email'];  
					 
					$ret = [
						'result' => false,
						'member' => '',
						'password' => '',
						'memberInfo' => '',
						'reference' => ''
					];
					$ret['result'] = true;
					$ret['reference'] = 'Your request is successful. Please wait for acceptace from policy holder, and result will be sent to your email soon.';
					$ret['member'] = $memberid; 
					$ret['password'] = '';//randomPassword();
					$ret['memberInfo'] = [];
				   echo removeHarmfulChar(@$_GET['callback']) . '(' . json_encode($ret) . ')';
					sendMailToPolicyHolder($name,$surname,$memberid,$email,$temp,$receipient);
				}
			}else{ 
				//echo ('debug 6 ====================================================================');
				$query_rs_check_memberid = "SELECT * FROM users WHERE memberID = '".$memberid."' AND username LIKE '".$email."'";
				$rs_check_memberid = mysql_query($query_rs_check_memberid, $conn_database) or die(mysql_error());
				$row_rs_check_memberid = mysql_fetch_assoc($rs_check_memberid);
				$totalRows_rs_check_memberid = mysql_num_rows($rs_check_memberid);

				if($totalRows_rs_check_memberid == 0){

					$temp = $birthday;

					$array = explode("/",$temp);
					$tmpMonth =  date_parse($array[1]);//date('m',strtotime($array[1]));
					$nmonth = $tmpMonth['month'];

					$birthday = $array[2].':'.$nmonth.':'.$array[0];

					$birthday = str_replace("/",":",$birthday);

					$query = sprintf('memberID=%s&email=%s&birthday=%s',$memberid,$email,$birthday);
					//echo WEBSERVICE_URL.'/wflow/services/getNewMemberService.php?'.($query);

					$data = array("customerInfo" => "");
					$data_string = json_encode($data);
					//var_dump ($data_string);
					//REQUEST CHANGE NEW MEMBER
					$ch = curl_init(WEBSERVICE_URL.'/wflow/services/getNewMemberService.php?'.($query));
					curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
					curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
					curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
					curl_setopt($ch, CURLOPT_TIMEOUT, 30);
					curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 30);
		curl_setopt($ch, CURLOPT_REFERER, WEBSERVICE_URL);

					$result = curl_exec($ch);

					curl_close($ch);


					$result = ltrim(rtrim($result, ")"), "(");
					$result_decode = json_decode($result, true);

					//var_dump($result_decode); 

					if($result_decode["result"])
					{ 
						//echo GetSQLValueString( md5(strtoupper($result_decode["member"]). md5(HASH_SALT. md5($result_decode["password"]), "text")))."<br>";
						$insertSQL = sprintf("INSERT INTO users (user_type,memberID,username,password,status) VALUES (%s, %s, %s, '%s', %s)",
									   GetSQLValueString(1, "int"),
									   GetSQLValueString($result_decode["member"], "text"),
									   GetSQLValueString($email, "text"),
									   GetSQLValueString( md5(strtoupper($result_decode["member"]). md5(HASH_SALT. md5($result_decode["password"]), "text"))),
									   GetSQLValueString(1, "int"));

						mysql_select_db($database_conn_database, $conn_database); 
						$Result1 = mysql_query($insertSQL, $conn_database) or die(mysql_error());
						
						//After inser user is completed, 
						//continue create token for member to continue create password.
						$token = md5(uniqid());
						//echo "die here?";
						$insertSQL = sprintf("INSERT INTO `online_service`.`forget_password`(`memberID`,`token`,`createDate`,`active`)VALUES(%s,%s,now(),'YES');",
						GetSQLValueString($email, "text"), GetSQLValueString($token, "text"));
						//echo "die here2?";
						mysql_select_db($database_conn_database, $conn_database);
						$Result1 = mysql_query($insertSQL , $conn_database) or die(mysql_error());
						
						$temp_text_return = sprintf("Your request is successfully completed.<br><br>Information will be sent to your registered email.");
						//$memberID = $result_decode["member"];
						//$memberName = $result_decode["memberInfo"]["name"];
						//$mmberSurname = $result_decode["memberInfo"]["surname"];
						//$password = $result_decode[" array("result"=>"35", "member"=>"37""];
						if(isset($_REQUEST["currDomain"])&& $_REQUEST["currDomain"]!=''){
							if($_REQUEST["currDomain"]=="sea.msh-intl.com"){
								$webUrl = "http://sea.msh-intl.com/onlineservice";
							}else{
								$webUrl = WEBSITE_URL;
							}
						
						}else{
							$webUrl = WEBSITE_URL;
						}
						//if(WEBSITE_URL!='http://'.$_REQUEST["currDomain"]){
						//	$webUrl = "http://sea.msh-intl.com/onlineservice";
						//}
						$emailResetPwdUrl= $webUrl;
						//$result_decode = array("result"=>"ok", "member"=>$row_member["m_name"], "memberInfo"=> array("name"=>$row_member["m_name"], "surname"=>""),"password"=> $emailResetPwdUrl."/forgetpassword.php?token=".$token );
						$result_decode2 = array("result"=>"ok", "member"=>$result_decode["member"], "memberInfo"=> array("name"=>$result_decode["memberInfo"]["name"], "surname"=>$result_decode["memberInfo"]["surname"]),"password"=> $emailResetPwdUrl."/forgetpassword.php?token=".$token );
						
						sendUserMail($result_decode2,$isNewUser); 
						$ret = Array ("result" => "success", "reference" => $temp_text_return);
						$jsonstring = json_encode($ret);
						
						echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')'; 
						
						//end create password
						
						
						//$temp_text_return = sprintf("Your Request is successfully complete<br><br>Your Login Detail is following:<br><br><b>Username : %s</b><br><br><b>Password : %s</b><br><br>Information will be sent to your registered email.<br><br>Please login again and change your password.<br><br>Thank you.",$email,$result_decode["password"]);
						//$temp_text_return = sprintf("Your Request is successfully complete<br><br>Information will be sent to your registered email.<br><br>Please login again and change your password.<br><br>Thank you.");
						//sendUserMail($result_decode);
						//$ret = Array ("result" => "success", "reference" => $temp_text_return);
						//$jsonstring = json_encode($ret);
						//echo  @$_GET['callback'] . '(' .$jsonstring. ')';
						exit;
					}else{



						$ret = Array ("result" => "failed", "reference" => "There are some problems of your request. Please contact  claims@lumahealth.com or +662-665-3600 for any inquiry.<br><br>Thank you.");
						
						$jsonstring = json_encode($ret);
						
						echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')';
						exit;
					}
				}else{
						$ret = Array ("result" => "failed", "reference" => "Username is already exist.<br><br>Please click forget password on login page or contact  claims@lumahealth.com or +662-665-3600 for more information.<br><br>Thank you.");
						$jsonstring = json_encode($ret);
						
						echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')';
						exit;
				}
				//=========================================
			}
			
			
				 
				
		//case that having no dependency user registered before	
		}elseif($row_rs_check_all_memberid['username']!='' && $row_rs_check_all_memberid['m_insuredDependenceNo']== $memberid){
			//echo ('debug 7 ===========');
			$ret = Array ("result" => "failed", "reference" => "This user is already exist in OnlineService.");
				
				$jsonstring = json_encode($ret);
				
				echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')';
				exit;
			
		}
		
	}else{
		$ret = Array ("result" => "failed", "reference" => "Your requested information is not valid.");
				
				$jsonstring = json_encode($ret);
				
				echo  removeHarmfulChar(@$_GET['callback']) . '(' .$jsonstring. ')';
				exit;
		
	}
	
	
	
	
	
		
}

function removeHarmfulChar($str){
 return (isset($str) && $str!="")? preg_replace("/[\&#\?\]\[\/\\\<\>\'\"\*\:\(\);]*/i","",$str): ""; 
}
function sendUserMail($result_decode,$isNewUser){
	if($result_decode["result"]){
	require '../PHPMailer/PHPMailerAutoload.php';

				$memberID = $result_decode["member"];
				$memberName = $result_decode["memberInfo"]["name"];
				$mmberSurname = $result_decode["memberInfo"]["surname"];
				$password = $result_decode["password"];
				$memberemail =  $result_decode["memberInfo"]["email"];
				//$webUrl = WEBSITE_URL;
				if(isset($_REQUEST["currDomain"])&& $_REQUEST["currDomain"]!=''){
					if($_REQUEST["currDomain"]=="sea.msh-intl.com"){
						$webUrl = "http://sea.msh-intl.com/";
					}else{
						$webUrl = WEBSITE_URL;
					}
				
				}else{
					$webUrl = WEBSITE_URL;
				}
				if(WEBSITE_URL!=$_REQUEST["currDomain"]){
					$webUrl = "http://sea.msh-intl.com/onlineservice/";
				}
				
							//get mail footer template
				$filename = "../mailtemplate/mail_footer.txt";
				$handle = fopen($filename, "r");
				$footer  = fread($handle, filesize($filename));
				fclose($handle);
				
				if($isNewUser){
	
				
				//get member template
				$subject="Website ".$webUrl." - Your login details 1/2";
				$filename = "../mailtemplate/request_for_new_member_1.txt";
				$handle = fopen($filename, "r");
				$body  = fread($handle, filesize($filename));
				fclose($handle);
				
				//replace param
				$body = str_replace("<MemberName>",ucfirst(strtolower($memberID)),$body);
				$body = str_replace("<Surname>",ucfirst(strtolower($mmberSurname)),$body);
				$body = str_replace("<WebUrl>",$webUrl,$body);
				$body = str_replace("<MemberId>",$email ,$body);
				$body = nl2br($body);
				$body = nl2br($body);
				$body = str_replace("\t",'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',$body);
				$body = $body . $footer;

                $email = new PHPMailer();
				
				$email->SMTPDebug = 0;   
				$email->IsSMTP();				
               
                $email->CharSet = 'UTF-8';
                $email->From      = 'cwfsystem@lumahealth.com';
                $email->FromName  = 'Automatic System';
                $email->Subject   = $subject;
                $email->Body      = $body;
                //$email->AddBCC('claims@lumahealth.com', "Claims team");
				$email->AddBCC('sawinee.ap@gmail.com');
				$email->AddBCC("khemmarin.k@lumahealth.com", "Admin");
                //$email->AddBCC('auttakorn.ph@gmail.com');//sender email
                //$email->AddBCC('atthaphong@lannasoftworks.com');//sender email
                $email->AddAddress($_REQUEST["email"]);//sender email
                $email->isHTML(true);                                  // Set email format to HTML


                //$email->Send();
				
				}
				
				
				//mail password
		
				
				//get member template
				if($isNewUser){
					$subject="Luma Online Service Registration - Luma Health Insurance"; //$subject="Online service login request - Luma Health Insurance";//"Website ".$webUrl." - Your login details 2/2";
					$filename = "../mailtemplate/request_for_new_member_2.txt";
				}else{
					$subject="Luma Online Service Login Request - Luma Health Insurance"; // $subject="Online service Dependency login request - Luma Health Insurance";//"Online Service – Your Request login Password";
					$filename = "../mailtemplate/request_for_password.txt";//$filename = "../mailtemplate/request_for_new_member_2.txt";//$filename = "../mailtemplate/request_for_password.txt";
				}
				
				$handle = fopen($filename, "r");
				$body  = fread($handle, filesize($filename));
				fclose($handle);
				
				//replace param
				$body = str_replace("<MemberName>",ucfirst(strtolower($memberName)),$body);
				$body = str_replace("<Surname>",ucfirst(strtolower($mmberSurname)),$body);
				$body = str_replace("<WebUrl>",$webUrl,$body);
				$body = str_replace("<Password>",$password ,$body);
				$body = str_replace("<customer_email>",$_REQUEST["email"] ,$body);
				$body = nl2br($body);
				$body = nl2br($body);
				$body = str_replace("\t",'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',$body);
				$body = $body . $footer;

                $email = new PHPMailer();
				
				$email->SMTPDebug = 0;    
				$email->IsSMTP();		
               
                $email->CharSet = 'UTF-8';
                $email->From      = 'cwfsystem@lumahealth.com';//gg.sea.msh@gmail.com
                $email->FromName  = 'Automatic System';
                $email->Subject   = $subject;
                $email->Body      = $body;
                //$email->AddBCC('atis.arit@gmail.com');//claim email\
                //$email->AddBCC('atthaphong@lannasoftworks.com');
				//$email->AddBCC('sawinee.ap@gmail.com');
				$email->AddBCC("khemmarin.k@lumahealth.com");
                //$email->AddBCC('auttakorn.ph@gmail.com');//sender email
                $email->AddAddress($_REQUEST["email"]);//sender email $_POST["email"]  //$memberemail
                $email->isHTML(true);                                  // Set email format to HTML
				$mail->SMTPDebug  = 2;

                $email->Send();
	}
}
function sendMailToPolicyHolder($name,$surname,$memberid,$email,$birthday,$receipient){
	//if($result_decode["result"]){
	require '../PHPMailer/PHPMailerAutoload.php';
	$isNewUser = false;

				//$memberID = $result_decode["member"];
				//$memberName = $result_decode["memberInfo"]["name"];
				//$mmberSurname = $result_decode["memberInfo"]["surname"];
				$password = '';//$result_decode["password"];
				//$memberemail =  $result_decode["memberInfo"]["email"];
				//$webUrl = WEBSITE_URL;
				if(isset($_REQUEST["currDomain"])&& $_REQUEST["currDomain"]!=''){
					if($_REQUEST["currDomain"]=="sea.msh-intl.com"){
						$webUrl = "http://sea.msh-intl.com/";
					}else{
						$webUrl = WEBSITE_URL;
					}
				
				}else{ 
					$webUrl = WEBSITE_URL;
				} 
				$webUrl = $webUrl.'/confirmDependencyRequest.php?memberID='.$memberid.'&birthday='.$birthday.'&email='.$email;
				//if(WEBSITE_URL!=$_REQUEST["currDomain"]){
				//	$webUrl = "http://sea.msh-intl.com/onlineservice/";
				//}
				
							//get mail footer template
				$filename = "../mailtemplate/mail_footer.txt";
				$handle = fopen($filename, "r");
				$footer  = fread($handle, filesize($filename));
				fclose($handle);
				
				if($isNewUser){
	
				
				//get member template
				$subject="Website ".$webUrl." - Depedency Login Request";
				$filename = "../mailtemplate/request_for_new_member_3.txt";
				$handle = fopen($filename, "r");
				$body  = fread($handle, filesize($filename));
				fclose($handle);
				
				//replace param
				$body = str_replace("<MemberName>",ucfirst(strtolower($name)),$body);
				$body = str_replace("<Surname>",ucfirst(strtolower($surname)),$body);
				$body = str_replace("<WebUrl>",$webUrl,$body);
				$body = str_replace("<MemberId>",$email ,$body);
				$body = nl2br($body);
				$body = nl2br($body);
				$body = str_replace("\t",'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',$body);
				$body = $body . $footer;

                $email = new PHPMailer();
				
				$email->SMTPDebug = 0;   
				$email->IsSMTP();				
               
                $email->CharSet = 'UTF-8';
                $email->From      = 'cwfsystem@lumahealth.com';
                $email->FromName  = 'Automatic System';
                $email->Subject   = $subject;
                $email->Body      = $body;
                //$email->AddBCC('claims@lumahealth.com', "Claims team");
				//$email->AddBCC('sawinee.ap@gmail.com');
				$email->AddBCC("khemmarin.k@lumahealth.com", "Admin");
                //$email->AddBCC('auttakorn.ph@gmail.com');//sender email
                //$email->AddBCC('atthaphong@lannasoftworks.com');//sender email
                $email->AddAddress($_REQUEST["email"]);//sender email
                $email->isHTML(true);                                  // Set email format to HTML


                //$email->Send();
				
				}
				
				
				//mail password
		
				
				//get member template
					//$subject="Online service Dependency login request - Luma Health Insurance";//"Online Service – Your Request login Password";
					$subject="Luma Online Service Dependent Login Request - Luma Health Insurance";
					$filename = "../mailtemplate/request_for_new_member_3.txt";//$filename = "../mailtemplate/request_for_password.txt";
				
				
				$handle = fopen($filename, "r");
				$body  = fread($handle, filesize($filename));
				fclose($handle);
				
				//replace param
				$body = str_replace("<MemberName>",ucfirst(strtolower($name)),$body);
				$body = str_replace("<Surname>",ucfirst(strtolower($surname)),$body);
				$body = str_replace("<WebUrl>",$webUrl,$body);
				$body = str_replace("<Password>",$password ,$body);
				$body = nl2br($body);
				$body = nl2br($body);
				$body = str_replace("\t",'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',$body);
				$body = $body . $footer;

                $email = new PHPMailer();
				
				$email->SMTPDebug = 0;    
				$email->IsSMTP();		
               
                $email->CharSet = 'UTF-8';
                $email->From      = 'cwfsystem@lumahealth.com';//gg.sea.msh@gmail.com
                $email->FromName  = 'Automatic System';
                $email->Subject   = $subject;
                $email->Body      = $body;
                //$email->AddBCC('atis.arit@gmail.com');//claim email\
                //$email->AddBCC('atthaphong@lannasoftworks.com');
				//$email->AddBCC('sawinee.ap@gmail.com');
				$email->AddBCC("khemmarin.k@lumahealth.com");
                //$email->AddBCC('auttakorn.ph@gmail.com');//sender email
                $email->AddAddress($receipient);//sender email $_POST["email"]  //$memberemail
                $email->isHTML(true);                                  // Set email format to HTML
$mail->SMTPDebug  = 2;

                $email->Send();
	//}
}
?>