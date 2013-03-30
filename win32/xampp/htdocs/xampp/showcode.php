<?php
	echo '&nbsp;<p>&nbsp;<p>';
	if(@$_REQUEST['showcode']!=1)
	{
		echo '<a href="'.htmlentities($_SERVER['PHP_SELF']).'?showcode=1">'.$TEXT['global-showcode'].'</a>';
	}
	else
	{
		if(@$file=="")$file=basename($_SERVER['PHP_SELF']);
		$validfiles['biorhythm.php']=1;
		$validfiles['cds-fpdf.php']=1;
		$validfiles['cds.php']=1;
		$validfiles['iart.php']=1;
		$validfiles['ming.php']=1;
		$validfiles['phonebook.php']=1;
		$f="";
		if(@$validfiles[$file])
			$f=htmlentities(file_get_contents($file));
		echo "<h2>".@$TEXT['global-sourcecode']."</h2>";
		echo "<form><textarea cols=100 rows=10>";
		echo $f;
		echo "</textarea></form>";
		echo "&nbsp;<p>";
		echo "&nbsp;<p>";
	}
?>
