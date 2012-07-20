

<?php

if (authentication($_POST['id'], $_POST['passwd'])) {	

    $campaign = $_POST['campaign'];

    $to = $_POST['email'];
    //$user_name = $_POST['name'];
    $subject = "Congrat! Here is your reward, just arrived.";
    //$body = "Dear " . $user_name .  "\n\nYou received a digital coupon from SecondCommercials.\nPlease Check the attached. \n\nThank you very much!";
    
    
    
    $cmp = "";
    if (!strcmp($campaign, "campaign_a")) {
            $cmp = "a";
    } else  if (!strcmp($campaign, "campaign_b")) {
            $cmp = "b";
    } else  if (!strcmp($campaign, "campaign_c")) {
            $cmp = "c";
    } else  if (!strcmp($campaign, "campaign_d")) {
            $cmp = "d";
    } else  if (!strcmp($campaign, "campaign_e")) {
            $cmp = "e";
    } else  if (!strcmp($campaign, "campaign_f")) {
            $cmp = "f";
    } else  if (!strcmp($campaign, "3_0_2_campaign_a")) {
            $cmp = "a";
    } else  if (!strcmp($campaign, "3_0_2_campaign_a")) {
            $cmp = "a";
    }






    $body = '
<html>
<head>
<title>email_voucher</title>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
</head>
<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<!-- ImageReady Slices (email_voucher_' . $cmp . '.ai) -->
<table id="Table_01" width="799" height="556" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="7">
			<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp .'_01.png" width="799" height="192" alt=""></td>
	</tr>
	<tr>
		<td colspan="2" rowspan="2">
			<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_02.png" width="533" height="120" alt=""></td>
		<td colspan="2" align="left" valign="top">
			<a target="_blank" href="http://www.gmarket.com.sg/">
				<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_03.png" width="129" height="47" border="0" alt=""></a></td>
		<td colspan="3" rowspan="2">
			<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_04.png" width="137" height="120" alt=""></td>
	</tr>
	<tr>
		<td colspan="2">
			<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_05.png" width="129" height="73" alt=""></td>
	</tr>
	<tr>
		<td rowspan="4">
			<img src="ihttp://211.115.71.69/logic/images/email_voucher_' . $cmp . '_06.png" width="478" height="243" alt=""></td>
		<td colspan="5" align="left" valign="top">
			<a target="_blank" href="http://bit.ly/Q10sgdoff_shipping">
				<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_07.png" width="254" height="27" border="0" alt=""></a></td>
		<td rowspan="4">
			<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_08.png" width="67" height="243" alt=""></td>
	</tr>
	<tr>
		<td colspan="5">
			<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_09.png" width="254" height="191" alt=""></td>
	</tr>
	<tr>
		<td colspan="2" rowspan="2">
			<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_10.png" width="157" height="25" alt=""></td>
		<td colspan="2" align="left" valign="top">
			<a target="_blank" href="http://www.facebook.com/pages/Secondcommercials/318165364868518?sk=app_291626854213649">
				<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_11.png" width="43" height="15" border="0" alt=""></a></td>
		<td rowspan="2">
			<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_12.png" width="54" height="25" alt=""></td>
	</tr>
	<tr>
		<td colspan="2">
			<img src="http://211.115.71.69/logic/images/email_voucher_' . $cmp . '_13.png" width="43" height="10" alt=""></td>
	</tr>
	<tr>
		<td>
			<img src="http://211.115.71.69/logic/images/spacer.gif" width="478" height="1" alt=""></td>
		<td>
			<img src="http://211.115.71.69/logic/images/spacer.gif" width="55" height="1" alt=""></td>
		<td>
			<img src="http://211.115.71.69/logic/images/spacer.gif" width="102" height="1" alt=""></td>
		<td>
			<img src="http://211.115.71.69/logic/images/spacer.gif" width="27" height="1" alt=""></td>
		<td>
			<img src="http://211.115.71.69/logic/images/spacer.gif" width="16" height="1" alt=""></td>
		<td>
			<img src="http://211.115.71.69/logic/images/spacer.gif" width="54" height="1" alt=""></td>
		<td>
			<img src="http://211.115.71.69/logic/images/spacer.gif" width="67" height="1" alt=""></td>
	</tr>
</table>
<!-- End ImageReady Slices -->
</body>
</html>
	    ';

        $headers = "From: reward@secondcommercials.com\r\nReply-To: reward@secondcommercials.com\r\nContent-type:text/html";

    if (mail($to, $subject, $body, $headers)) {
        echo("successful");
    } else {
        echo("failed");
    }
}

function authentication($username, $passwd)
{	    
    if (!strcmp($username,"SecondCommercials") && 
		!strcmp($passwd,"second1234567")) {
		return 1;
	} else {
		return 0;
	}	
}
?>







