@echo off
cd /D %~dp0
::apache\bin\pv -f -k mercury.exe -q
taskkill /im /f /t mercury.exe 
