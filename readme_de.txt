###### ApacheFriends XAMPP Version 7.1.11 ######

Wichtig! PHP in diesem Paket benötigt die Microsoft Visual C++ 2008 Redistributable Erweiterung von
http://www.microsoft.com/en-us/download/details.aspx?id=5582. Bitte stellen Sie sicher das die VC++ 2008 
Runtime Bibliothek auf Ihrem System installiert ist.

  + Apache 2.4.29
  + MariaDB 10.1.28
  + PHP 7.1.11 (VC14 X86 32bit thread safe) + PEAR
  + phpMyAdmin 4.7.4
  + OpenSSL 1.0.2f
  + ADOdb 518a
  + Mercury Mail Transport System v4.62 (nicht in der Portable Version)
  + FileZilla FTP Server 0.9.41 (nicht in der Portable Version)
  + Webalizer 2.23-04 (nicht in der Portable Version) 
  + Strawberry Perl 5.16.1.1 Portable
  + Tomcat 7.0.56
  + XAMPP Control Panel Version 3.2.2 von hackattack142 (Ein großes Danke Schön!)
    Vgl.: http://www.apachefriends.org/f/viewtopic.php?f=16&t=46743 
  + XAMPP mailToDisk 1.0 (schreibt verdendete Mails über PHP auf die Festplatte unter <xampp>\mailoutput. In der php.ini als Mail Default aktiviert.)

--------------------------------------------------------------- 

* System-Voraussetzungen:
  
  + 64 MB RAM (EMPFOHLEN)
  + 750 MB freier Speicherplatz
  + Windows XP, VISTA, Windows 7, Windows 8, Windows 10
  
* ACHTUNG!!!!

Wenn ihr Probleme mit der mysql Verbindung via php bzw. phpMyAdmin (pber die mysqlnd API) habt dann schaut bitte unbedingt hier: 
http://localhost/xampp/index.php


* SCHNELLINSTALLATION:

[HINWEIS: Auf die obersten Hirachie eines beliebigen Laufwerks bzw. auf dem Wechseldatenträger des USB-Sticks entpacken => E:\ oder W:\. Es entsteht E:\xampp oder W:\xampp. Für den USB-Stick nicht die "setup_xampp.bat" nutzen, um ihn auch transportabel nutzen zu können!]

Schritt 1: Das Setup mit der Datei "setup_xampp.bat" im XAMPP-Verzeichnis starten. Bemerkung: XAMPP macht selbst keine Einträge in die Windows Registry und setzt auch keine Systemvariablen.

Schritt 2: Starten Sie den Apache2 mit PHP5.x mit dem Control Panel (xampp-control.exe) oder wahlweise mit => \xampp\apache_start.bat. 
Stoppen Sie den Apache2 mit PHP5.x mit dem Control Panel (xampp-control.exe) oder wahlweise mit => \xampp\apache_stop.bat. 

Schritt 3: Starten Sie MySQL mit dem Control Panel (xampp-control.exe) oder wahlweise mit => \xampp\mysql_start.bat.
Stoppen Sie MySQL mit dem Control Panel (xampp-control.exe) oder wahlweise mit => \xampp\mysql_stop.bat.

Schritt 4: Öffne deinen Browser und gebe http://127.0.0.1 oder http://localhost ein. Danach gelangst du zu den zahlreichen ApacheFriends-Beispielen auf Ihrem lokalen Server.

Schritt 5: Das Root-Verzeichnis (Hauptdokumente) für HTTP (oft HTML) ist => C:\xampp\htdocs. PHP kann die Endungen  *.php, *.phtml haben, *.shtml für SSI, *.cgi für CGI (z. B.: Perl).

Schritt 6: XAMPP DEINSTALLIEREN?
Einfach das "XAMPP"-Verzeichnis löschen. Vorher aber alle Server stoppen 
bzw. als Dienste deinstallieren.

---------------------------------------------------------------

* PHP MAIL FUNCTION:

Es gibt drei Arten die PHP Mail function testweise zu benutzen.

1) Mit XAMPP mailToDisk wird jede Email die über die Mail Funktion von PHP versendet wird nach <xampp>\mailoutput geschrieben. MailToDisk ist Standard und Bedarf keine Änderung in der php.ini. MailToDisk keinesfalls produktiv einsetzen! 
2) Mit fakemail (sendmail.exe) werden alle Mails versendet mit PHP mail() in ein von ihnen definiertes externes Postfach geschickt. Zuvor müssen sie ihr Postfach in der <xampp>\sendmail\sendmail.ini konfigurieren und auch die sendmail.exe in der php.ini aktivieren.  
3) Sie bnutzen einen eigenen SMTP Server wie der im XAMPP integrierte Mercury Mail Server oder einen externen SMTP Server (wie IIS). Hierzu kommentieren sie in der php.ini alle sendmail_path Zeilen aus und kommentieren dafür die Zeilen -> SMTP = localhost und -> smtp_port = 25 mit ihren Daten ein.  

ACHTUNG: Wenn sie im Installationspfad Leerzeichen verwenden (wie c:\program files\xampp), wird mailToDisk und fakemail (sendmail.exe) u.U. nicht funktionieren. In diesem Fall den <xampp>\mailtodisk bzw. <xampp>\sendmail in ein Vereichnis ohne Leerzeichen kopieren und den neuen Pfad entsprechend in der php.ini aktualisieren.     

---------------------------------------------------------------

* PASSWÖRTER:

1) MySQL:

   Benutzer: root
   Passwort:
   (also kein Passwort!)

2) FileZilla FTP:

   [ Sie müssen erst einen neuen Benutzer über das User FileZilla Interface erstellen. ] 

3) Mercury: 

   Postmaster: Postmaster (postmaster@localhost)
   Administrator: Admin (admin@localhost)

   TestUser: newuser  
   Passwort: wampp 

4) WEBDAV: 

   Benutzer: xampp-dav-unsecure
   Password: ppmax2011 

---------------------------------------------------------------

* NUR FÜR NT-SYSTEME! (NT4 | Windows 2000 | Windows XP | Windows 2003):

- \xampp\apache\apache_installservice.bat 
  ===> Installiert den Apache 2 als Dienst

- \xampp\apache\apache_uninstallservice.bat 
  ===> Deinstalliert den Apache 2 als Dienst

- \xampp\mysql\mysql_installservice.bat 
  ===> Installiert MySQL als Dienst

- \xampp\mysql\mysql_uninstallservice.bat 
  ===> Deinstalliert MySQL als Dienst

==> Nach allen De- / Installationen der Dienste, System unbedingt neustarten! 

---------------------------------------------------------------

* DAS THEMA SICHERHEIT:

Wie schon an anderer Stelle erwähnt ist XAMPP nicht für den Produktionseinsatz gedacht, sondern nur für Entwickler in Entwicklungsumgebungen. Das hat zur Folge, dass XAMPP absichtlich nicht restriktiv sondern im Gegenteil sehr offen vorkonfiguriert ist. Für einen Entwickler ist das ideal, da er so keine Grenzen vom System vorgeschrieben bekommt.
Für einen Produktionseinsatz ist das allerdings überhaupt nicht geeignet!
Hier eine Liste, der Dinge, die an XAMPP absichtlich (!) unsicher sind:

- Der MySQL-Administrator (root) hat kein Passwort.
- Der MySQL-Daemon ist übers Netzwerk erreichbar.
- phpMyAdmin ist über das Netzwerk erreichbar.
- In dem XAMPP-Demo-Seiten (die man unter http://localhost/ findet) gibt es den Punkt "Sicherheitscheck".
  Dort kann man sich den aktuellen Sicherheitszustand seiner XAMPP-Installation anzeigen lassen.

---------------------------------------------------------------

* MYSQL-Hinweise:

(1) Um den MySQL-Daemon zu starten bitte Doppelklick auf \xampp\mysql_start.bat.
Der MySQL Server startet dann im Konsolen-Modus. Das dazu gehörige Konsolenfenster muss offen bleiben (!!) Zum Stop bitte die mysql_stop.bat benutzen!

(2) Wer MySQL als Dienst unter NT / 2000 / XP benutzen möchte, muss unbedingt (!) vorher die "my" bzw."my.ini unter C:\ (also C:\my.ini) implementieren. Danach die "mysql_installservice.bat" im Ordner "mysql" aktivieren. Dienste funktionieren generell NICHT unter Windows Home-Versionen. 

(3) Der MySQL-Server startet ohne Passwort für MySQl-Administrator "root".
Für eine Zugriff in PHP sähe das also aus:

	mysql_connect("localhost", "root", "");

Ein Passwort für "root" könnt ihr über den MySQL-Admin in der Eingabeaufforderung
setzen. Z. B.: 

	C:\xampp\mysql\bin\mysqladmin.exe -u root -p geheim

Wichtig: Nach dem Einsetzen eines neuen Passwortes für Root muss auch phpMyAdmin informiert werden! Das geschieht über die Datei "config.inc.php"; zu finden als C:\xampp\phpmyadmin\config.inc.php. Dort also folgenden 
Zeilen editieren:
   
	$cfg['Servers'][$i]['user']            = 'root';   // MySQL User
	$cfg['Servers'][$i]['auth_type']       = 'http';   // HTTP-Authentifzierung

So wird zuerst das "root"-Passwort vom MySQL-Server abgefragt, bevor phpMyAdmin zugreifen darf.
    
---------------------------------------------------------------	
    
		Have a lot of fun! | Viel Spaß! | Bonne Chance!
