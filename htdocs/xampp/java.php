<?php
    include 'langsettings.php';
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta name="author" content="Kai Oswald Seidler, Kay Vogelgesang, Carsten Wiedmann">
        <link href="xampp.css" rel="stylesheet" type="text/css">
        <title>Apache Tomcat Servlet/JSP (+mod_jk) - XAMPP AddOn</title>
    </head>

    <body>
        <br><h1>AJP13 Proxy + Apache Tomcat (J2EE Container)</h1>

        <table border="0">
           <tr>
                <td width="300">&nbsp;</td>
                <td width="10">&nbsp;</td>
                <td width="*">&nbsp;</td>
            </tr>
            <?php
            list($partwampp, $directorwampp) = preg_split('|\\\htdocs\\\xampp|', dirname(__FILE__));
    
            ini_set('default_socket_timeout', 1);
            if (!@fsockopen('127.0.0.1', 8080)) {
                echo "<tr><td width='*' colspan='3'><i><b>{$TEXT['info-tomcatwarn']}</b></i></td></tr>";
            }
            ?>
            <tr>
                <td width="300">&nbsp;</td>
                <td width="10">&nbsp;</td>
                <td width="*">&nbsp;</td>
            </tr>
               <tr>
                <td width="300">&nbsp;</td>
                <td width="10">&nbsp;</td>
                <td width="*">&nbsp;</td>
            </tr>
            <tr>
                <td width="300">Apache AJP Proxy configuration:</td>
                <td width="10">&nbsp;</td>
                <td width="*">
                    <?php echo $partwampp."\\apache\\conf\\extra\\httpd-ajp.conf"; ?><br>
                </td>
            </tr>
            
             <tr>
                <td width="300">&nbsp;</td>
                <td width="10">&nbsp;</td>
                <td width="*">&nbsp;</td>
            </tr>
            <tr>
                <td width="300">Tomcat configuration (global):&nbsp;<br>&nbsp;<br>&nbsp;<br></td>
                
                <td width="10">&nbsp;</td>
                <td width="*">
                    <?php echo $partwampp."\\tomcat\\conf\\server.xml"; ?><br>
                    <?php echo $partwampp."\\tomcat\\conf\\web.xml"; ?><br>
                    <?php echo $partwampp."\\tomcat\\conf\\context.xml"; ?>
                </td>
            </tr>
            <tr>
                <td width="300">&nbsp;</td>
                <td width="10">&nbsp;</td>
                <td width="*">&nbsp;</td>
            </tr>
              <tr>
                <td width="300">Tomcat document root:</td>
                <td width="10">&nbsp;</td>
                <td width="*"><?php echo $partwampp."\\tomcat\\webapps\\";?></td>
            </tr>
            <tr>
                <td width="300">Tomcat examples directory:</td>
                <td width="10">&nbsp;</td>
                <td width="*"><?php echo $partwampp."\\tomcat\\webapps\\examples\\";?></td>
            </tr>
            <tr>
                <td width="300">Tomcat default examples (with ajp proxy):</td>
                <td width="10">&nbsp;</td>
                <td width="*"><a href="/examples/" target="_blank">http://localhost/examples/</a></td>
            </tr>
            <tr>
                <td width="300">&nbsp;</td>
                <td width="10">&nbsp;</td>
                <td width="*">&nbsp;</td>
            </tr>
            <tr>
                <td width="300">Tomcat standalone (without ajp13):</td>
                <td width="10">&nbsp;</td>
                <td width="*"><a href="http://127.0.0.1:8080/" target="_blank">http://127.0.0.1:8080/</a></td>
            </tr>
            <tr>
                <td width="300">Tomcat Manager (without ajp13):</td>
                <td width="10">&nbsp;</td>
                <td width="*"><a href="http://127.0.0.1:8080/manager/status" target="_blank">http://127.0.0.1:8080/manager/status</a></td>
            </tr>
            <tr>
                <td width="300">&nbsp;</td>
                <td width="10">&nbsp;</td>
                <td width="*">&nbsp;</td>
            </tr>
            <tr>
                <td width="300">&nbsp;</td>
                <td width="10">&nbsp;</td>
                <td width="*">&nbsp;</td>
            </tr>
            <tr>
                <td width="300">Homepage:</td>
                <td width="10">&nbsp;</td>
                <td width="*"><a href="http://tomcat.apache.org/" target="_blank">http://tomcat.apache.org/</a></td>
            </tr>
            <tr>
                <td width="300">Sun:</td>
                <td width="10">&nbsp;</td>
                <td width="*"><a href="http://www.oracle.com/technetwork/java/javase/downloads/index.html" target="_blank">Java JDK (Oracle)</a></td>
            </tr>
        </table>
    </body>
</html>
