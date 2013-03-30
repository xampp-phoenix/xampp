#!"\xampp\perl\bin\perl.exe"

#    Copyright (C) 2002/2003 Kai Seidler, oswald@apachefriends.org
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


use CGI;

$form=new CGI;

$f_name = CGI::escapeHTML($form->param("f_name"));
$f_email = CGI::escapeHTML($form->param("f_email"));
$f_text = CGI::escapeHTML($form->param("f_text"));

print "Content-Type: text/html; charset=iso-8859-1\n\n";

if ($f_name) {
    open(FILE, ">>$gb") or die("Cannot open guestbook file");
    print FILE localtime()."\n";
    print FILE "$f_name\n";
    print FILE "$f_email\n";
    print FILE "$f_text\n";
    print FILE "·\n";
    close(FILE);
}

print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"';
print '    "http://www.w3.org/TR/html4/loose.dtd">';
print '<html>';
print '<head>';
print '<meta name="author" content="Kai Oswald Seidler">';
print '<link href="xampp.css" rel="stylesheet" type="text/css">';
print '<title>Guest Book (Example for Perl)</title>';
print '</head>';

print '<body>';

print "<br><h1>Guest Book (Example for Perl)</h1>";

print "<p>A classic and simple guest book!</p>";

open(FILE, "<$gb") or die("Cannot open guestbook file");

while (!eof(FILE)){
    chomp($date = <FILE>);
    chomp($name = <FILE>);
    chomp($email = <FILE>);

    print "<div class='small'>$date</div>";
    print "<table border='0' cellpadding='4' cellspacing='1'>";
    print "<tr><td class='h'>";
    print "<img src='img/blank.gif' alt='' width='250' height='1'><br>";
    print "Name: ".CGI::escapeHTML($name);
    print "</td><td class='h'>";
    print "<img src='img/blank.gif' width='250' height='1'><br>";
    print "E-Mail: ".CGI::escapeHTML($email);
    print "</td></tr>";
    print "<tr><td class='d' colspan='2'>";
    while (1 == 1){
        chomp($line = <FILE>);
        if ($line eq '·') {
            last;
        }
        print CGI::escapeHTML($line)."<br>";
    }
    print "</td></tr>";
    print "</table>";
    print "<br>";
}
close(FILE);

print "<p>Add entry:</p>";

print "<form action='guestbook-en.pl' method='get'>";
print "<table border='0' cellpadding='0' cellspacing='0'>";
print "<tr><td>Name:</td><td><input type='text' size='30' name='f_name'></td></tr>";
print "<tr><td>E-Mail:</td><td> <input type='text' size='30' name='f_email'></td></tr>";
print "<tr><td>Text:</td><td> <textarea rows='3' cols='30' name='f_text'></textarea></td></tr>";
print "<tr><td></td><td><input type='submit' value='WRITE'></td></tr>";
print "</table>";
print "</form>";

print "</body>";
print "</html>";
