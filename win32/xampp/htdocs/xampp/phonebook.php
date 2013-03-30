<?php  include("langsettings.php"); ?>

<html>
<head>
<title>XAMPP phonebook</title>
<link href="xampp.css" rel="stylesheet" type="text/css">
</head>

<body>

&nbsp;<p>
<h1><?php print $TEXT['phonebook-head']?></h1>

<?php print $TEXT['phonebook-text1']?><p>
<?php print @$TEXT['phonebook-text2']?><p>

<?php

//    Copyright (C) 2003-2004 Kai Seidler, oswald@apachefriends.org
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

	if(!($db=new SQLite3('sqlite/phonebook.sqlite3', '0666')))
	{
		echo "<h2>".$TEXT['phonebook-error']."</h2>";
		die();
	}
?>

<h2><?php print $TEXT['phonebook-head1']?></h2>

<table border=0 cellpadding=0 cellspacing=0>
<tr bgcolor=#f87820>
<td><img src=img/blank.gif width=10 height=25></td>
<td class=tabhead><img src=img/blank.gif width=150 height=6><br><b><?php print $TEXT['phonebook-attrib1']?></b></td>
<td class=tabhead><img src=img/blank.gif width=150 height=6><br><b><?php print $TEXT['phonebook-attrib2']?></b></td>
<td class=tabhead><img src=img/blank.gif width=150 height=6><br><b><?php print $TEXT['phonebook-attrib3']?></b></td>
<td class=tabhead><img src=img/blank.gif width=50 height=6><br><b><?php print $TEXT['phonebook-attrib4']?></b></td>
<td><img src=img/blank.gif width=10 height=25></td>
</tr>


<?php
	$firstname=$db->escapeString(@$_REQUEST['firstname']);
	$lastname=$db->escapeString(@$_REQUEST['lastname']);
	$phone=$db->escapeString(@$_REQUEST['phone']);

	if($firstname!="")
	{
		$db->query("INSERT INTO users (firstname,lastname,phone) VALUES('$firstname','$lastname','$phone')");
	}

	if(@$_REQUEST['action']=="del")
	{
		$db->query("DELETE FROM users WHERE id=".round($_REQUEST['id']));
	}

	$result=$db->query("SELECT id,firstname,lastname,phone FROM users ORDER BY lastname;");
	
	$i=0;
	while( $row=$result->fetchArray(SQLITE3_ASSOC) )
	{
		if($i>0)
		{
			echo "<tr valign=bottom>";
			echo "<td bgcolor=#ffffff background='img/strichel.gif' colspan=6><img src=img/blank.gif width=1 height=1></td>";
			echo "</tr>";
		}
		echo "<tr valign=center>";
		echo "<td class=tabval><img src=img/blank.gif width=10 height=20></td>";
		echo "<td class=tabval><b>".htmlspecialchars($row['lastname'])."</b></td>";
		echo "<td class=tabval>".htmlspecialchars($row['firstname'])."&nbsp;</td>";
		echo "<td class=tabval>".htmlspecialchars($row['phone'])."&nbsp;</td>";

		echo "<td class=tabval><a onclick=\"return confirm('".$TEXT['phonebook-sure']."');\" href=phonebook.php?action=del&id=".$row['id']."><span class=red>[".$TEXT['phonebook-button1']."]</span></a></td>";
		echo "<td class=tabval></td>";
		echo "</tr>";
		$i++;

	}

	echo "<tr valign=bottom>";
        echo "<td bgcolor=#fb7922 colspan=6><img src=img/blank.gif width=1 height=8></td>";
        echo "</tr>";

	$db->close();

?>

</table>

<h2><?php print $TEXT['phonebook-head2']?></h2>

<form action=phonebook.php method=get>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td><?php print $TEXT['phonebook-attrib1']?>:</td><td><input type=text size=20 name=lastname></td></tr>
<tr><td><?php print $TEXT['phonebook-attrib2']?>:</td><td> <input type=text size=20 name=firstname></td></tr>
<tr><td><?php print $TEXT['phonebook-attrib3']?>:</td><td> <input type=text size=20 name=phone></td></tr>
<tr><td></td><td><input type=submit border=0 value="<?php print $TEXT['phonebook-button2']?>"></td></tr>
</table>
</form>
<?php include("showcode.php"); ?>


</body>
</html>
