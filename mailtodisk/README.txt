mailToDisk
===================

Version 1.0

A win32 executable in the PHP environment as sendmail dummy for writing emails on locaL disk. 

http://www.apachefriends.org

Copyright
---------

Copyright (C) 2012
    Kay Vogelgesang


Installation
=====================

In php.ini set your sendmail path to mailtodisk.exe e.g.:
    sendmail_path = "C:\xampp\mailtodisk\mailtodisk.exe"

You will find the outgoing mails as text files in <xampp>\mailoutput e.g.:
    C:\xampp\mailoutput 
    
    
Securtity Restriction
=====================

If the mail output folder have more then 300 MB overall size mailToDisk do
not write in anymore. We want prevent a full disk crash here. Then please 
clean up this folder.    


Todos
=====================

- integrate ConfigParser to make mailToDisk configurable
