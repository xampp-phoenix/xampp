@echo off
cd /D %~dp0
::apache\bin\pv -f -k httpd.exe -q
taskkill /im /f /t httpd.exe
if not exist apache\logs\httpd.pid GOTO exit
del apache\logs\httpd.pid

:exit
