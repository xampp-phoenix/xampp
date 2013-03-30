<?php
	include "langsettings.php";
	extract($_POST);
	extract($_SERVER);
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
	"http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta name="author" content="Kai Oswald Seidler, Kay Vogelgesang, Carsten Wiedmann">
		<link href="xampp.css" rel="stylesheet" type="text/css">
		<title>Simple Email Form</title>
	</head>

	<body>
		&nbsp;<p>
		<h1>Simple Email Form</h1>
		<i>(The request is allowed from localhost only)</i><br/><br/>
		
 #########################################################################
    <br/><br/>
		<form method="post" action="mailsend.php">
			<table width="600" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td align="left" width="200"><?php echo $TEXT['mail-adress']; ?></td>
					<td align="left" width="400"><input type="text" name="knownsender" size="40" value="postmaster@localhost"></td>
				</tr>

				<tr>
					<td align="left" width="200"><?php echo $TEXT['mail-adressat']; ?></td>
					<td align="left" width="400"><input type="text" name="recipients" size="40" value="admin@localhost"></td>
				</tr>

				<tr>
					<td align="left" width="200"><?php echo $TEXT['mail-cc']; ?></td>
					<td align="left" width="400"><input type="text" name="ccaddress" size="40"></td>
				</tr>

				<tr>
					<td align="left" width="200"><?php echo $TEXT['mail-subject']; ?></td>
					<td align="left" width="400"><input type="text" name="subject" size="40"></td>
				</tr>

				<tr>
					<td align="left" width="200">&nbsp;</td>
					<td align="center" width="400">&nbsp;</td>
				</tr>

				<tr>
					<td align="left" width="200"><?php echo $TEXT['mail-message']; ?></td>
					<td align="left" width="400"><textarea rows="6" name="message" cols="34"></textarea></td>
				</tr>

				<tr>
					<td align="left" width="200">&nbsp;</td>
					<td align="center" width="400">&nbsp;</td>
				</tr>

				<tr>
					<td align="left" width="200">&nbsp;</td>
					<td align="left" width="400"><input type="submit" value="Send"> * <input type="reset" value="Reset"></td>
				</tr>
			</table>
		</form><br>
 #########################################################################
<br><br>
<b><?php echo $TEXT['mail-note-important']; ?></b><br><br>
<?php echo $TEXT['mail-note-text1']; ?> 
<ol>
<li><?php echo $TEXT['mail-note-text2']; ?></li>
<li><?php echo $TEXT['mail-note-text3']; ?></li>
<li><?php echo $TEXT['mail-note-text4']; ?> <a href="mercury-help.php"><?php echo $TEXT['mail-hinweise']; ?></a></li>
</ol>

	</body>
</html>
