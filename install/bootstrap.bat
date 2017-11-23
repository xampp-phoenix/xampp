@echo off
set curdir=%cd%
cd %~dp0
if exist busybox.exe goto :install
if %PROCESSOR_ARCHITECTURE% == AMD64 (
    cscript /nologo bootstrap.js win64
) else (
    cscript /nologo bootstrap.js win32
)
:install
.\busybox.exe sh .\install.sh
cd %curdir%
pause
