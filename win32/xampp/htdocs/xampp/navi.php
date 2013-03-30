<?php
include "langsettings.php";
date_default_timezone_set('UTC');
$xopen   = fopen(".modell", 'r');
$xmodell = "XAMPP"; // Default
$xmodell = fread($xopen, filesize(".modell"));
fclose($xopen);

function rendernavi($category)
{
    include "langsettings.php";
    
    $headline = $category;
    if ($GLOBALS['xmodell'] != "XAMPP") {
        $category = "$category-usb";
    }
    $navfilesexists=false;     
    if ($handle = opendir('.\\navilinks')) {
        while (false !== ($entry = readdir($handle))) {
            $ext = substr(strrchr($entry, '.'), 1);
            if ($ext == "$category") {
                $navfilesexists = true;
                $navfiles[]     = $entry;
            }
        }
    }

    if ($navfilesexists == true) {
      echo "<tr valign=\"top\"><td align=\"right\" class=\"navi\"><br><span class=\"nh\">";
      echo ucfirst($headline);
    
      echo "</span><br></td></tr><tr><td height=\"1\" bgcolor=\"#fb7922\" colspan=\"1\" style=\"background-image:url(img/strichel.gif)\" class=\"white\"></td></tr>";
      echo "<tr valign=\"top\"><td align=\"right\" class=\"navi\">";
      foreach ($navfiles as $value) {
          include "navilinks/$value";
      }
      echo "</td></tr>";
    }
}

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
	"http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta name="author" content="Kai Oswald Seidler, Kay Vogelgesang, Carsten Wiedmann">
		<link href="xampp.css" rel="stylesheet" type="text/css">
		<script language="JavaScript" type="text/javascript" src="xampp.js"></script>
		<title></title>
	</head>

	<body class="n">
		<table border="0" cellpadding="0" cellspacing="0">
			<tr valign="top">
				<td align="right" class="navi">
					<img src="img/blank.gif" alt="" width="145" height="15"><br>
					<span class="nh">&nbsp;<?php include(".modell")?><br><?php include(".version")?>
          </span><br><span class="navi">[PHP: <?php echo phpversion(); ?>]</span><br> <br>
				</td>
			</tr>
			<tr>
				<td height="1" bgcolor="#fb7922" colspan="1" style="background-image:url(img/strichel.gif)" class="white"></td>
			</tr>
			<tr valign="top">
				<td align="right" class="navi">
					<a name="start" id="start" class="nh" target="content" onclick="h(this);" href="start.php"><?php echo $TEXT['navi-welcome']; ?></a><br>
					<a class="n" target="content" onclick="h(this);" href="status.php"><?php print $TEXT['navi-status']; ?></a><br>
					<a class="n" target="new" onclick="h(this);" href="/security/lang.php?<?php echo file_get_contents("lang.tmp"); ?>"><?php echo $TEXT['navi-security']; ?></a><br>
					<a class="n" target="content" onclick="h(this);" href="manuals.php"><?php echo $TEXT['navi-doc']; ?></a><br>
					<a class="n" target="content" onclick="h(this);" href="components.php"><?php echo $TEXT['navi-components']; ?></a><br>
					  </td>
			</tr>
  
  		<?php  
        rendernavi("php");
      ?>
  
  	  <?php  
        rendernavi("perl");
      ?> 
			
	    <?php  
        rendernavi("j2ee");
      ?> 
			
			<?php  
        rendernavi("tools");
      ?>
			
			<tr valign="top">
				<td align="right" class="navi"><br>
<p class=navi>&copy;2002-<?php echo date("Y"); ?><br>
<?php include "langsettings.php"; 
if(file_get_contents("lang.tmp")=="de") { ?>
<a target=content href="http://www.apachefriends.org/de/"><img border=0 src="img/apachefriends.gif"></a><p>
<?php } else { ?>
<a target=content href="http://www.apachefriends.org/en/"><img border=0 src="img/apachefriends.gif"></a><p>
<?php } ?>
				</td>
			</tr>
		</table>
	</body>
</html>
