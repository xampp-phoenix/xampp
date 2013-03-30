<!DOCTYPE HTML Public "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" >
        <title>aspinfo()</title>

        <style type="text/css">
        <!--
        a { text-decoration: none; }
        a:hover { text-decoration: underline; }
        h1 { font-family: arial, helvetica, sans-serif; font-size: 18pt; font-weight: bold;}
        h2 { font-family: arial, helvetica, sans-serif; font-size: 14pt; font-weight: bold;}
        body, td { font-family: arial, helvetica, sans-serif; font-size: 10pt; }
        th { font-family: arial, helvetica, sans-serif; font-size: 10pt; font-weight: bold; }
        -->
        </style>
    </head>

    <body>
        <div align="center">
            <table width="80%" border="0" bgcolor="#000000" cellspacing="1" cellpadding="3">
                <tr>
                <td align="center" valign="top" bgcolor="#FFFFAE" colspan="2"><h3>Apache::ASP</h3></td>
                </tr>
            </table>
            <br> <hr> <br>

            <h3>Server Variables</h3>
            <table width="80%" border="0" bgcolor="#000000" cellspacing="1" cellpadding="3">
                <%
                for(sort keys %{$Request->ServerVariables()}) {
                    $Response->Write("<tr>\n");
                    $Response->Write("<th width=\"30%\" bgcolor=\"#FFFFAE\" align=\"left\">$_</th>\n");
                    $Response->Write("<td bgcolor=\"#FFFFD9\" align=\"left\">$Request->{ServerVariables}{$_}&nbsp;</td>\n");
                    $Response->Write("</tr>\n");
                };
                %>
            </table>

            <br> <hr> <br>
            <h3>Cookies</h3>
            <table width="80%" border="0" bgcolor="#000000" cellspacing="1" cellpadding="3">
                <%
                for(sort keys %{$Request->Cookies()}) {
                    $Response->Write("<tr>\n");
                    $Response->Write("<th width=\"30%\" bgcolor=\"#FFFFAE\" align=\"left\">$_</th>\n");
                    $Response->Write("<td bgcolor=\"#FFFFD9\" align=\"left\">$Request->{Cookies}{$_}&nbsp;</td>\n");
                    $Response->Write("</tr>\n");
                };
                %>
            </table>

            <br><hr><br>
            <h3>Other variables</h3>
            <table width="80%" border="0" bgcolor="#000000" cellspacing="1" cellpadding="3">
                <tr>
                    <th width="30%" bgcolor="#FFFFAE" align="left">Session.SessionID</th>
                    <td bgcolor="#FFFFD9"><%= $Session->{SessionID} %></td>
                </tr>
                <tr>
                    <th width="30%" bgcolor="#FFFFAE" align="left">Server.MapPath</th>
                    <td bgcolor="#FFFFD9"><%= $Server->MapPath("/") %></td>
                </tr>
            </table>
        </div>
    </body>
</html>
