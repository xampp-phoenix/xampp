@ECHO OFF
rmdir /S/Q MercuryMail
REM rmdir /S/Q tomcat
rmdir /S/Q FileZillaFTP
rmdir /S/Q anonymous
rmdir /S/Q webalizer
rmdir /S/Q src
rmdir /S/Q mysql\mysql-test
rmdir /S/Q mysql\sql-bench
rmdir /S/Q mysql\scripts
rmdir /S/Q mysql\include
rmdir /S/Q mysql\lib
REM rmdir /S/Q php\PEAR
REM rmdir /S/Q perl\lib
REM rmdir /S/Q perl\site
REM rmdir /S/Q perl\vendor
REM rmdir /S/Q perl\bin
REM mkdir perl\bin
REM del /F/Q catalina_start.bat
REM del /F/Q catalina_stop.bat
REM del /F/Q catalina_service.bat
del /F/Q filezilla_setup.bat
del /F/Q filezilla_start.bat
del /F/Q filezilla_stop.bat
del /F/Q mercury_start.bat
del /F/Q mercury_stop.bat
del /F/Q service.exe
del /F/Q apache\apache_installservice.bat
del /F/Q apache\apache_uninstallservice.bat
del /F/Q mysql\mysql_installservice.bat
del /F/Q mysql\mysql_uninstallservice.bat
del /F/Q htdocs\xampp\.modell
del /F/Q setup_xampp.bat
copy src\xampp-usb-lite\setup_xampp.bat .
copy src\xampp-usb-lite\xampp-control.ini .
mv htdocs\xampp\.modell-usb htdocs\xampp\.modell
