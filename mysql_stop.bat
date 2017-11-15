@echo off
cd /D %~dp0
echo Mysql shutdowm ...
::apache\bin\pv -f -k mysqld.exe -q
taskkill /im /f /t mysqld.exe 

if not exist mysql\data\%computername%.pid GOTO exit
echo Delete %computername%.pid ...
del mysql\data\%computername%.pid

:exit
