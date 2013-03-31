; Author: Kay Vogelgesang for ApacheFriends XAMPP win32

;---------------------
;Include Modern UI
   !include "MUI.nsh"
   ; !include "MUI2.nsh"
;--------------------------------


  SetCompressor /solid lzma
  XPStyle on
  ; HM NIS Edit Wizard helper defines
  !define PRODUCT_NAME "XAMPP Portable"
  !define PRODUCT_VERSION "1.8.1"
  !define PRODUCT_PUBLISHER "Kay Vogelgesang, Kai Oswald Seidler, ApacheFriends"
  !define PRODUCT_WEB_SITE "http://www.apachefriends.org"
  !define WORK_DIR "G:\bitnami\workspace"
  !define WORK_XAMPP_DIR "${WORK_DIR}\tmp\xampp"
  Caption "XAMPP ${PRODUCT_VERSION} win32"
  InstallDirRegKey HKLM "Software\xampp" "Install_Dir"
  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  OutFile "${WORK_DIR}\dist\xampp-portable-win32-${PRODUCT_VERSION}-VC9-installer.exe"
  RequestExecutionLevel admin
  BGGradient f87820 FFFFFF FFFFFF
  InstallColors FF8080 000030
  CheckBitmap "${WORK_DIR}\xampp\src\xampp-nsi-installer\icons\classic-cross.bmp"

;--------------------------------

;Remember the installer language
  ;!define MUI_LANGDLL_REGISTRY_ROOT "HKLM"
  ;!define MUI_LANGDLL_REGISTRY_KEY "Software\xampp"
  ;!define MUI_LANGDLL_REGISTRY_VALUENAME "lang"

  !define MUI_ABORTWARNING
  !define MUI_ICON "${WORK_DIR}\xampp\src\xampp-nsi-installer\icons\xampp-icon.ico"
  !define MUI_WELCOMEPAGE
  !define MUI_CUSTOMPAGECOMMANDS
  !define MUI_COMPONENTSPAGE
  !define MUI_COMPONENTSPAGE_NODESC

;Pages
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  ;!insertmacro MUI_UNPAGE_WELCOME
  ;!insertmacro MUI_UNPAGE_CONFIRM
  ;!insertmacro MUI_UNPAGE_INSTFILES
  ;!insertmacro MUI_UNPAGE_FINISH

;Languages
  !insertmacro MUI_LANGUAGE "English" # first language is the default language
  !insertmacro MUI_LANGUAGE "German"
;  !insertmacro MUI_LANGUAGE "Afrikaans"
;  !insertmacro MUI_LANGUAGE "Albanian"
;  !insertmacro MUI_LANGUAGE "Arabic"
;  !insertmacro MUI_LANGUAGE "Basque"
;  !insertmacro MUI_LANGUAGE "Bulgarian"
;  !insertmacro MUI_LANGUAGE "Catalan"
;  !insertmacro MUI_LANGUAGE "Czech"
;  !insertmacro MUI_LANGUAGE "Danish"
;  !insertmacro MUI_LANGUAGE "SimpChinese"
;  !insertmacro MUI_LANGUAGE "TradChinese"
;  !insertmacro MUI_LANGUAGE "Spanish"
;  !insertmacro MUI_LANGUAGE "Farsi"
;  !insertmacro MUI_LANGUAGE "Finnish"
;  !insertmacro MUI_LANGUAGE "French"
;  !insertmacro MUI_LANGUAGE "Hebrew"
;  !insertmacro MUI_LANGUAGE "Italian"
;  !insertmacro MUI_LANGUAGE "Japanese"
;  !insertmacro MUI_LANGUAGE "Korean"
;  !insertmacro MUI_LANGUAGE "Kurdish"
;  !insertmacro MUI_LANGUAGE "Lithuanian"
;  !insertmacro MUI_LANGUAGE "Hungarian"
;  !insertmacro MUI_LANGUAGE "Dutch"
;  !insertmacro MUI_LANGUAGE "Norwegian"
;  !insertmacro MUI_LANGUAGE "Polish"
;  !insertmacro MUI_LANGUAGE "PortugueseBR"
;  !insertmacro MUI_LANGUAGE "Portuguese"
;  !insertmacro MUI_LANGUAGE "Romanian"
;  !insertmacro MUI_LANGUAGE "Russian"
;  !insertmacro MUI_LANGUAGE "Serbian"
;  !insertmacro MUI_LANGUAGE "Slovak"
;  !insertmacro MUI_LANGUAGE "Slovenian"
;  !insertmacro MUI_LANGUAGE "Swedish"


;--------------------------------
;Variables
  Var OPT_MYSQL
  Var OPT_TOMCAT
  Var OPT_PERL
  Var OPT_PMA

InstallDir "c:\xampp-portable"
Icon "${WORK_DIR}\xampp\src\xampp-nsi-installer\icons\xampp-icon.ico"
UninstallIcon "${WORK_DIR}\xampp\src\xampp-nsi-installer\icons\xampp-icon-uninstall.ico"
ShowInstDetails show
ShowUninstDetails show

;Fuctions
Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY

; Missing MS C++ 2008 runtime library warning here
  ReadRegStr $R2 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}' DisplayVersion
  ReadRegStr $R3 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{350AA351-21FA-3270-8B7A-835434E766AD}' DisplayVersion
  ReadRegStr $R4 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2B547B43-DB50-3139-9EBE-37D419E0F5FA}' DisplayVersion

  ReadRegStr $R5 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{9A25302D-30C0-39D9-BD6F-21E6EC160475}' DisplayVersion
  ReadRegStr $R6 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8220EEFE-38CD-377E-8595-13398D740ACE}' DisplayVersion
  ReadRegStr $R7 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5827ECE1-AEB0-328E-B813-6FC68622C1F9}' DisplayVersion

  ReadRegStr $R8 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1F1C2DFC-2D24-3E06-BCB8-725134ADF989}' DisplayVersion
  ReadRegStr $R9 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4B6C7001-C7D6-3710-913E-5BC23FCE91E6}' DisplayVersion
  ReadRegStr $R0 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{977AD349-C2A8-39DD-9273-285C08987C7B}' DisplayVersion

  StrCmp $R2 "" vc9_test2
  GOTO init_end
  vc9_test2:
  StrCmp $R3 "" vc9_test3
  GOTO init_end
  vc9_test3:
  StrCmp $R4 "" vc9_test4
  GOTO init_end
  vc9_test4:
  StrCmp $R5 "" vc9_test5
  GOTO init_end
  vc9_test5:
  StrCmp $R6 "" vc9_test6
  GOTO init_end
  vc9_test6:
  StrCmp $R7 "" vc9_test7
  GOTO init_end
  vc9_test7:
  StrCmp $R8 "" vc9_test8
  GOTO init_end
  vc9_test8:
  StrCmp $R9 "" vc9_test9
  GOTO init_end
  vc9_test9:
  StrCmp $R0 "" no_vc9
  GOTO init_end

  no_vc9:
        StrCmp $LANGUAGE "1031" lang_de
               MessageBox MB_YESNO "Warning: XAMPP (PHP) cannot work without the Microsoft Visual C++ 2008 Redistributable Package. Now open the Microsoft page for this download?" IDNO MsPageOut
               ;MessageBox MB_YESNO "MS C++ 2008 runtime package not found! It is required for PHP. Now open the Microsoft site for this download?" IDNO MsPageOut
               ExecShell "open" "http://www.microsoft.com/en-us/download/details.aspx?id=5582"
               GOTO MsPageOut
               lang_de:
               MessageBox MB_YESNO "Warnung: XAMPP (PHP) benötigt das Microsoft Visual C++ 2008 Redistributable Package! Die Microsoft Seite für diesen Download jetzt öffnen?" IDNO MsPageOut
               ; MessageBox MB_YESNO "MS C++ 2008 runtime Installation fehlt auf Ihrem Rechner! Diese wird für PHP benötigt. Die Microsoft Seite für diesen Download jetzt öffnen?" IDNO MsPageOut
               ExecShell "open" "http://www.microsoft.com/en-us/download/details.aspx?id=5582"
        MsPageOut:
               ; StrCmp $LANGUAGE "1031" lang_de2
               ; MessageBox MB_YESNO "Perhaps XAMPP do not work without the MS VC++ 2008 runtime library. Still go on with the XAMPP installation?" IDNO GoOut
               ; GOTO init_end
               ; lang_de2:
               ; MessageBox MB_YESNO "Ohne die MS VC++ 2008 Runtime Bibliothek könnte XAMPP nicht funktionieren! Die XAMPP Installation trotzdem weiterführen?" IDNO GoOut
               ; GOTO init_end
               ; GoOut:
               ; Abort "Exit by user."
  init_end:

                StrCmp $LANGUAGE "1031" detection_de
                GOTO non_de
                detection_de:
                MessageBox MB_OK "Das Paket ist Wechseldatenträger geeignet. Alle Konfigurationsdateien haben relative Pfade."
                GOTO usb_end
                non_de:
                MessageBox MB_OK "This package is removable device compatible. All configuration files have relative paths."
  usb_end:

FunctionEnd


Function WriteToFile
Exch $0 ;file to write to
Exch
Exch $1 ;text to write

  FileOpen $0 $0 a #open file
  FileSeek $0 0 END #go to end
  FileWrite $0 $1 #write to file
  FileClose $0

Pop $1
Pop $0
FunctionEnd

!macro WriteToFile NewLine File String
  !if `${NewLine}` == true
  Push `${String}$\r$\n`
  !else
  Push `${String}`
  !endif
  Push `${File}`
  Call WriteToFile
!macroend
!define WriteToFile `!insertmacro WriteToFile false`
!define WriteLineToFile `!insertmacro WriteToFile true`


Function .onInstSuccess

CopyFiles "$INSTDIR\xampp-control-portable.ini" "$INSTDIR\xampp-control.ini"
Delete "$INSTDIR\xampp-control-portable.ini"


StrCmp $OPT_MYSQL "" no_mysql
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `MySQL=1`
Goto mysql_out
no_mysql:
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `MySQL=0`
Delete "$INSTDIR\mysql_start.bat"
Delete "$INSTDIR\mysql_stop.bat"
mysql_out:

StrCmp $OPT_TOMCAT "" no_tomcat
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Tomcat=1`
Goto tomcat_out
no_tomcat:
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Tomcat=0`
Delete "$INSTDIR\htdocs\xampp\navilinks\tomcat.j2ee-usb"
Delete "$INSTDIR\catalina_start.bat"
Delete "$INSTDIR\catalina_stop.bat"
Delete "$INSTDIR\catalina_service.bat"
tomcat_out:

StrCmp $OPT_PERL "" no_perl
Goto perl_out
no_perl:
Delete "$INSTDIR\htdocs\xampp\navilinks\perlexamples.perl-usb"
perl_out:

StrCmp $OPT_PMA "" no_pma
Goto pma_out
no_pma:
Delete "$INSTDIR\htdocs\xampp\navilinks\01_phpmyadmin.tools-usb"
pma_out:

StrCmp $LANGUAGE "1031" detection_de
GOTO non_de
detection_de:
MessageBox MB_OK "Das Paket macht keine Registry Änderungen somit keinen Uninstaller. Bitte entfernen Sie das Installationsverzeichnis manuell wenn Sie es nicht mehr benötigen."
GOTO oninstsu_end
non_de:
MessageBox MB_OK "This package make no registry modifications and have no uninstaller. Please remove the installation directory manually if you do not need it anymore."
oninstsu_end:

FunctionEnd

Section "-XAMPP Files"
SetOverwrite ifnewer
SetOutPath "$INSTDIR"
File "${WORK_XAMPP_DIR}\setup_xampp.bat"
File "${WORK_XAMPP_DIR}\readme_en.txt"
File "${WORK_XAMPP_DIR}\xampp-control.exe"
File "${WORK_XAMPP_DIR}\xampp-control.ini"
File "${WORK_XAMPP_DIR}\xampp_start.exe"
File "${WORK_XAMPP_DIR}\xampp_stop.exe"
File "${WORK_XAMPP_DIR}\apache_start.bat"
File "${WORK_XAMPP_DIR}\apache_stop.bat"
File "${WORK_XAMPP_DIR}\catalina_service.bat"
File "${WORK_XAMPP_DIR}\catalina_start.bat"
File "${WORK_XAMPP_DIR}\catalina_stop.bat"
File "${WORK_XAMPP_DIR}\mysql_start.bat"
File "${WORK_XAMPP_DIR}\mysql_stop.bat"
File "${WORK_XAMPP_DIR}\passwords.txt"
File "${WORK_XAMPP_DIR}\readme_de.txt"
File "${WORK_XAMPP_DIR}\test_php.bat"

SetOutPath "$INSTDIR\cgi-bin"
File /r "${WORK_XAMPP_DIR}\cgi-bin\*.*"
SetOutPath "$INSTDIR\contrib"
File /r "${WORK_XAMPP_DIR}\contrib\*.*"
SetOutPath "$INSTDIR\htdocs"
File /r "${WORK_XAMPP_DIR}\htdocs\*.*"
SetOutPath "$INSTDIR\install"
File /r "${WORK_XAMPP_DIR}\install\*.*"
SetOutPath "$INSTDIR\licenses"
File /r "${WORK_XAMPP_DIR}\licenses\*.*"
SetOutPath "$INSTDIR\locale"
File /r "${WORK_XAMPP_DIR}\locale\*.*"
CreateDirectory "$INSTDIR\mailoutput"
SetOutPath "$INSTDIR\mailtodisk"
File /r "${WORK_XAMPP_DIR}\mailtodisk\*.*"
SetOutPath "$INSTDIR\security"
File /r "${WORK_XAMPP_DIR}\security\*.*"
SetOutPath "$INSTDIR\webdav"
File /r "${WORK_XAMPP_DIR}\webdav\*.*"
SetOutPath "$INSTDIR\tmp"
File /r "${WORK_XAMPP_DIR}\tmp\*.*"

${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` ``
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `[Common]`
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `Edition=Beta 4`
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `Editor=notepad.exe`
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `Browser=`
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `Debug=0`
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `Debuglevel=0`
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `TomcatVisible=1`

StrCmp $LANGUAGE "1031" lang_de
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `Language=en`
Goto lang_out
lang_de:
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `Language=de`
lang_out:

${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` ` `
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `[EnableModules]`
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `FileZilla=0`
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `Mercury=0`

SectionEnd


SectionGroup "Server"
Section "Apache"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\apache"
File /r "${WORK_XAMPP_DIR}\apache\*.*"
SectionIn RO
${WriteLineToFile} `$INSTDIR\xampp-control-portable.ini` `Apache=1`
SectionEnd

Section "MySQL"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\mysql"
File /r "${WORK_XAMPP_DIR}\mysql\*.*"
StrCpy $OPT_MYSQL "true"
SectionEnd

Section "Tomcat"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\tomcat"
File /r "${WORK_XAMPP_DIR}\tomcat\*.*"
StrCpy $OPT_TOMCAT "true"
SectionEnd
SectionGroupEnd


SectionGroup "Program languages"
Section "PHP"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\php"
File /r "${WORK_XAMPP_DIR}\php\*.*"
SectionIn RO
SectionEnd

Section "Perl"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\perl"
File /r "${WORK_XAMPP_DIR}\perl\*.*"
StrCpy $OPT_PERL "true"
SectionEnd
SectionGroupEnd


SectionGroup "Tools"
Section "phpMyAdmin"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\phpmyadmin"
File /r "${WORK_XAMPP_DIR}\phpmyadmin\*.*"
StrCpy $OPT_PMA "true"
SectionEnd

Section "Fake Sendmail"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\sendmail"
File /r "${WORK_XAMPP_DIR}\sendmail\*.*"
SectionEnd

SectionGroupEnd

Section "-XAMPPSETUP"
SetOutPath "$INSTDIR"
ExecWait '"$INSTDIR\php\php.exe" -n -d output_buffering=0 "$INSTDIR\install\install.php" usb' $0
StrCmp $0 "0" php_done
       StrCmp $LANGUAGE "1031" lang_de
              MessageBox MB_OK "Installation failed (php.exe). Perhaps you have to install the Microsoft Visual C++ 2008 Redistributable package. After that please execute the setup_xampp.bat in the xampp folder manually."
              GOTO php_done
        lang_de:
              MessageBox MB_OK "Installation gescheitert. Vielleicht sollten Sie das Microsoft Visual C++ 2008 Redistributable Paket auf Ihrem System installieren. Bitte danach die setup_xampp.bat manuell noch einmal ausführen."
php_done:
SectionEnd

