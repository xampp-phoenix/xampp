<?php include("langsettings.php"); ?>

<?php
if (urlencode(@$_REQUEST['action']) == "getpdf") {
        mysql_connect("localhost", "root", "");
        mysql_select_db("cdcol");

        include ('fpdf/fpdf.php');
        $pdf = new FPDF();
        $pdf->AddPage();

        $pdf->SetFont('Helvetica', '', 14);
        $pdf->Write(5, 'CD Collection');
        $pdf->Ln();

        $pdf->SetFontSize(10);
        $pdf->Write(5, '© 2002/2003 Kai Seidler, oswald@apachefriends.org, GPL');
        $pdf->Ln();

        $pdf->Ln(5);


        $pdf->SetFont('Helvetica', 'B', 10);
        $pdf->Cell(40 ,7, $TEXT['cds-attrib1'], 1);
        $pdf->Cell(100 ,7, $TEXT['cds-attrib2'], 1);
        $pdf->Cell(20 ,7, $TEXT['cds-attrib3'], 1);
        $pdf->Ln();

        $pdf->SetFont('Helvetica', '', 10);

        $result=mysql_query("SELECT titel,interpret,jahr FROM cds ORDER BY interpret");

        while ($row = mysql_fetch_array($result)) {
            $pdf->Cell(40, 7, $row['interpret'], 1);
            $pdf->Cell(100, 7, $row['titel'], 1);
            $pdf->Cell(20, 7, $row['jahr'], 1);
            $pdf->Ln();
        }

        $pdf->Output();
        exit;
    }
?>

<html>
<head>
<title>apachefriends.org cd collection</title>
<link href="xampp.css" rel="stylesheet" type="text/css">
</head>

<body>

&nbsp;<p>
<h1><?php print $TEXT['cds-head']; ?></h1>

<?php print $TEXT['cds-text1']; ?><p>
<?php print $TEXT['cds-text2']; ?><p>

<?php

//    Copyright (C) 2002/2003 Kai Seidler, oswald@apachefriends.org
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


	if(!mysql_connect("localhost","root",""))
	{
		echo "<h2>".$TEXT['cds-error']."</h2>";
		die();
	}
	mysql_select_db("cdcol");
?>

<h2><?php print $TEXT['cds-head1']; ?></h2>

<table border=0 cellpadding=0 cellspacing=0>
<tr bgcolor=#f87820>
<td><img src=img/blank.gif width=10 height=25></td>
<td class=tabhead><img src=img/blank.gif width=200 height=6><br><b><?php print $TEXT['cds-attrib1']; ?></b></td>
<td class=tabhead><img src=img/blank.gif width=200 height=6><br><b><?php print $TEXT['cds-attrib2']; ?></b></td>
<td class=tabhead><img src=img/blank.gif width=50 height=6><br><b><?php print $TEXT['cds-attrib3']; ?></b></td>
<td class=tabhead><img src=img/blank.gif width=50 height=6><br><b><?php print $TEXT['cds-attrib4']; ?></b></td>
<td><img src=img/blank.gif width=10 height=25></td>
</tr>


<?php
	if(@$_REQUEST['interpret']!="")
	{
		$titel=mysql_real_escape_string($_REQUEST['titel']);
		$interpret=mysql_real_escape_string($_REQUEST['interpret']);
		$jahr=mysql_real_escape_string($_REQUEST['jahr']);
		if($jahr=="")$jahr="NULL";
		mysql_query("INSERT INTO cds (titel,interpret,jahr) VALUES('$titel','$interpret',$jahr);");
	}

	if(@$_REQUEST['action']=="del")
	{
		mysql_query("DELETE FROM cds WHERE id=".round($_REQUEST['id']));
	}

	$result=mysql_query("SELECT id,titel,interpret,jahr FROM cds ORDER BY interpret;");
	
	$i=0;
	while( $row=mysql_fetch_array($result) )
	{
		if($i>0)
		{
			echo "<tr valign=bottom>";
			echo "<td bgcolor=#ffffff background='img/strichel.gif' colspan=6><img src=img/blank.gif width=1 height=1></td>";
			echo "</tr>";
		}
		echo "<tr valign=center>";
		echo "<td class=tabval><img src=img/blank.gif width=10 height=20></td>";
		echo "<td class=tabval><b>".htmlspecialchars($row['interpret'])."</b></td>";
		echo "<td class=tabval>".htmlspecialchars($row['titel'])."&nbsp;</td>";
		echo "<td class=tabval>".htmlspecialchars($row['jahr'])."&nbsp;</td>";

		echo "<td class=tabval><a onclick=\"return confirm('".$TEXT['cds-sure']."');\" href=cds.php?action=del&id=".$row['id']."><span class=red>[".$TEXT['cds-button1']."]</span></a></td>";
		echo "<td class=tabval></td>";
		echo "</tr>";
		$i++;

	}

	echo "<tr valign=bottom>";
        echo "<td bgcolor=#fb7922 colspan=6><img src=img/blank.gif width=1 height=8></td>";
        echo "</tr>";


?>

</table>

<h2><?php print $TEXT['cds-head2']; ?></h2>

<form action=cds.php method=get>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td><?php print $TEXT['cds-attrib1']; ?>:</td><td><input type=text size=30 name=interpret></td></tr>
<tr><td><?php print $TEXT['cds-attrib2']; ?>:</td><td> <input type=text size=30 name=titel></td></tr>
<tr><td><?php print $TEXT['cds-attrib3']; ?>:</td><td> <input type=text size=5 name=jahr></td></tr>
<tr><td></td><td><input type=submit border=0 value="<?php print $TEXT['cds-button2']; ?>"></td></tr>
</table>
</form>
<?php include("showcode.php"); ?>

</body>
</html>
