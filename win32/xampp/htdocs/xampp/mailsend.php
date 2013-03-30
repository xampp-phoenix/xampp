<?php
	include "langsettings.php";
	
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
	"http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta name="author" content="Kai Oswald Seidler, Kay Vogelgesang, Carsten Wiedmann">
		<link href="xampp.css" rel="stylesheet" type="text/css">
		<title>Mercury Mail Server</title>
	</head>

	<body>
		&nbsp;<p>
		<h1><?php echo $TEXT['mail-sendnow']; ?></h1>
		<i>(Requests allowed from localhost only)</i><br/><br/>
		<table>
			<tr>
				<td>&nbsp;<p>
					<?php
						if (empty($_POST['knownsender'])) {
							$_POST['knownsender'] = '';
						}
						if (empty($_POST['recipients'])) {
							$_POST['recipients'] = '';
						}
						if (empty($_POST['ccaddress'])) {
							$_POST['ccaddress'] = '';
						}
						if (empty($_POST['subject'])) {
							$_POST['subject'] = '';
						}
						if (empty($_POST['message'])) {
							$_POST['message'] = '';
						}
						$mailtos = $_POST['recipients'];
						$subject = $_POST['subject'];
						$message = $_POST['message'];

						$header  = 'MIME-Version: 1.0' . "\r\n";
						$header .= "Content-type: text/html; charset=iso-8859-1" . "\r\n";
						$header .= "To: $_POST[recipients]" . "\r\n"; 

						if (($_POST['ccaddress'] == "") || ($_POST['ccaddress'] == " ")) {
							$header .= "From: $_POST[knownsender]" . "\r\n";
						} else {
							$header .= "From: $_POST[knownsender]" . "\r\n";
							$header .= "Cc: $_POST[ccaddress]" . "\r\n";
						}

						if (@mail($mailtos, $subject, $message, $header)) {
							echo "<i>".$TEXT['mail-sendok']."</i>";
						} else {
							echo "<i>".$TEXT['mail-sendnotok']."</i>";
						}
					?>
				</td>
			</tr>
			<tr>
				<td>&nbsp;<p>&nbsp;<p>&nbsp;<p>
					<a href="javascript:history.back()">Zurück zum Formular</a>
				</td>
			</tr>
		</table>
	</body>
</html>
