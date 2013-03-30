; Author: Kay Vogelgesang for ApacheFriends XAMPP win32

;---------------------
;Include Modern UI
   !include "MUI.nsh"
   ; !include "MUI2.nsh"
;--------------------------------


  SetCompressor /solid lzma
  XPStyle on
  ; HM NIS Edit Wizard helper defines
  !define PRODUCT_NAME "XAMPP"
  !define PRODUCT_VERSION "1.8.1"
  !define PRODUCT_PUBLISHER "Kay Vogelgesang, Kai Oswald Seidler, ApacheFriends"
  !define PRODUCT_WEB_SITE "http://www.apachefriends.org"
  !define WORK_DIR "G:\bitnami\workspace"
  Caption "XAMPP ${PRODUCT_VERSION} win32"
  InstallDirRegKey HKLM "Software\xampp" "Install_Dir"
  Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  OutFile "${WORK_DIR}\dist\xampp-win32-${PRODUCT_VERSION}-VC9-installer.exe"
  RequestExecutionLevel admin
  BGGradient f87820 FFFFFF FFFFFF
  InstallColors FF8080 000030
  CheckBitmap "${WORK_DIR}\xampp\src\xampp-nsi-installer\icons\classic-cross.bmp"

;--------------------------------

;Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKLM"
  !define MUI_LANGDLL_REGISTRY_KEY "Software\xampp"
  !define MUI_LANGDLL_REGISTRY_VALUENAME "lang"

  !define MUI_ABORTWARNING
  !define MUI_ICON "${WORK_DIR}\xampp\src\xampp-nsi-installer\icons\xampp-icon.ico"
  !define MUI_UNICON "${WORK_DIR}\xampp\src\xampp-nsi-installer\icons\xampp-icon-uninstall.ico"
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

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;Resevefiles
  ;!insertmacro MUI_RESERVEFILE_LANGDLL
  ;!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

;Languages
  !insertmacro MUI_LANGUAGE "English" # first language is the default language
  !insertmacro MUI_LANGUAGE "German"

;--------------------------------
;Variables
  Var INST_MESS
  Var INST_MESS1
  Var INST_MESS2
  Var MESS_INSTDIR1
  Var MESS_INSTDIR2
  Var DB_DEL
  Var OPT_MYSQL
  Var OPT_FTPD
  Var OPT_MERCUR
  Var OPT_TOMCAT
  Var OPT_PERL
  Var OPT_PMA
  Var OPT_WEBA

InstallDir "c:\xampp"
Icon "${WORK_DIR}\xampp\src\xampp-nsi-installer\icons\xampp-icon.ico"
UninstallIcon "${WORK_DIR}\xampp\src\xampp-nsi-installer\icons\xampp-icon-uninstall.ico"
ShowInstDetails show
ShowUninstDetails show

;Fuctions
Function .onInit

!insertmacro MUI_LANGDLL_DISPLAY
; User Account Control (UAC) warning for VISTA/WIN7
  ReadRegStr $R1 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
        StrCmp $R1 "6.0" detection_VISTA
        StrCmp $R1 "6.1" detection_VISTA
        Goto no_vista
        detection_VISTA:
                        ReadRegStr $R2 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" EnableLUA
                        StrCmp $LANGUAGE "1031" detection_de
                        GOTO no_de
                        detection_de:
                        StrCmp $R2 "1" IS_UACDE
                        MessageBox MB_OK "Die Benutzerkontensteuerung unter Windows (UAC) ist auf Ihrem System deaktiviert (empfohlen). Bitte beachten Sie, das eine nachtr臠liche Aktivierung des Benutzerkontenschutz die Funktionalit舩 der XAMPP-Komponenten beeintr臘htigen kann."
                        GOTO ISNO_UACDE
                        IS_UACDE:
                        MessageBox MB_OK "Warnung! Aufgrund der aktivierten Windows Benutzerkontensteuerung (UAC) auf Ihrem System sind XAMPP-Komponenten und Funktionen ggf. nur eingeschr舅kt einsetzbar. Vermeiden Sie die Installation von XAMPP unter $PROGRAMFILES oder deaktivieren Sie den Benutzerkontensteuerung �ber msconfig nach diesem Setup."
                        ISNO_UACDE:
                        GOTO no_vista
                        no_de:
                        StrCmp $R2 "1" IS_UACE
                        MessageBox MB_OK "The User Account Control (UAC) is deactivated on your system (recommended). Please note: A later activation of UAC can restrict the functionality of XAMPP."
                        GOTO no_vista
                        IS_UACE:
                        MessageBox MB_OK "Important! Because an activated User Account Control (UAC) on your sytem some functions of XAMPP are possibly restricted. With UAC please avoid to install XAMPP to $PROGRAMFILES (missing write permisssions). Or deactivate UAC with msconfig after this setup."
                        no_vista:

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


  ; VC 2010
  ;ReadRegStr $A1 HKLM 'SOFTWARE\Microsoft\VisualStudio\10.0\VC\VCRedist\x86' Installed
  ;ReadRegStr $A2 HKLM 'SOFTWARE\Microsoft\VisualStudio\10.0\VC\VCRedist\x64' Installed
  ;ReadRegStr $A3 HKLM 'SOFTWARE\Microsoft\VisualStudio\10.0\VC\VCRedist\ia64' Installed
  ;ReadRegStr $A4 HKLM 'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\10.0\VC\VCRedist\x64' Installed

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
               MessageBox MB_YESNO "Warnung: XAMPP (PHP) benigt das Microsoft Visual C++ 2008 Redistributable Package! Die Microsoft Seite f�r diesen Download jetzt fnen?" IDNO MsPageOut
               ; MessageBox MB_YESNO "MS C++ 2008 runtime Installation fehlt auf Ihrem Rechner! Diese wird f�r PHP benigt. Die Microsoft Seite f�r diesen Download jetzt fnen?" IDNO MsPageOut
               ExecShell "open" "http://www.microsoft.com/en-us/download/details.aspx?id=5582"
        MsPageOut:
               ; StrCmp $LANGUAGE "1031" lang_de2
               ; MessageBox MB_YESNO "Perhaps XAMPP do not work without the MS VC++ 2008 runtime library. Still go on with the XAMPP installation?" IDNO GoOut
               ; GOTO init_end
               ; lang_de2:
               ; MessageBox MB_YESNO "Ohne die MS VC++ 2008 Runtime Bibliothek knte XAMPP nicht funktionieren! Die XAMPP Installation trotzdem weiterf�hren?" IDNO GoOut
               ; GOTO init_end
               ; GoOut:
               ; Abort "Exit by user."
  init_end:
FunctionEnd

Function un.onInit
!insertmacro MUI_LANGDLL_DISPLAY
;!insertmacro MUI_UNGETLANGUAGE
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

StrCmp $OPT_MYSQL "" no_mysql
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `MySQL=1`
Goto mysql_out
no_mysql:
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `MySQL=0`
Delete "$INSTDIR\mysql_start.bat"
Delete "$INSTDIR\mysql_stop.bat"
mysql_out:

StrCmp $OPT_FTPD "" no_ftpd
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `FileZilla=1`
Goto ftpd_out
no_ftpd:
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `FileZilla=0`
Delete "$INSTDIR\htdocs\xampp\navilinks\02_filezilla.tools"
Delete "$INSTDIR\filezilla_start.bat"
Delete "$INSTDIR\filezilla_stop.bat"
Delete "$INSTDIR\filezilla_setup.bat"
ftpd_out:

StrCmp $OPT_MERCUR "" no_mercury
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Mercury=1`
Goto mercury_out
no_mercury:
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Mercury=0`
Delete "$INSTDIR\mercury_start.bat"
Delete "$INSTDIR\mercury_stop.bat"
mercury_out:

StrCmp $OPT_TOMCAT "" no_tomcat
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Tomcat=1`
Goto tomcat_out
no_tomcat:
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Tomcat=0`
Delete "$INSTDIR\htdocs\xampp\navilinks\tomcat.j2ee"
Delete "$INSTDIR\catalina_start.bat"
Delete "$INSTDIR\catalina_stop.bat"
Delete "$INSTDIR\catalina_service.bat"
tomcat_out:

StrCmp $OPT_PERL "" no_perl
Goto perl_out
no_perl:
Delete "$INSTDIR\htdocs\xampp\navilinks\perlexamples.perl"
perl_out:

StrCmp $OPT_PMA "" no_pma
Goto pma_out
no_pma:
Delete "$INSTDIR\htdocs\xampp\navilinks\01_phpmyadmin.tools"
pma_out:

StrCmp $OPT_WEBA "" no_weba
Goto weba_out
no_weba:
Delete "$INSTDIR\htdocs\xampp\navilinks\03_webalizer.tools"
weba_out:

StrCmp $LANGUAGE "1031" detection_de
GOTO no_de
detection_de:
no_de:

WriteUninstaller "$INSTDIR\Uninstall.exe"
ReadRegStr $4 HKLM "Software\xampp" "lang"

StrCmp $4 "1031" german4
; StrCmp $4 "1041" japan4
StrCpy $INST_MESS "You can manage all the servers (services) with the XAMPP Control Panel. Do you want to start the Control Panel now?"
GOTO Xcontrol
german4:
StrCpy $INST_MESS "Sie knen alle Server (Dienste) mit dem XAMPP Control Panel steuern. Wollen Sie das Control Panel jetzt starten?"
GOTO Xcontrol
; japan4:
; StrCpy $INST_MESS "おめでとうございます。インストールに成功しました。Xamppコントロールパネルを今すぐ起動しますか？"
Xcontrol:
MessageBox MB_YESNO "$INST_MESS" IDNO NoXcontrol
      Exec '"$INSTDIR\xampp-control.exe"'
NoXcontrol:
FunctionEnd

Section "-XAMPP Files"
SetOverwrite ifnewer
SetOutPath "$INSTDIR"
File "${WORK_DIR}\xampp\service.exe"
File "${WORK_DIR}\xampp\setup_xampp.bat"
File "${WORK_DIR}\xampp\readme_en.txt"
File "${WORK_DIR}\xampp\xampp-control.exe"
File "${WORK_DIR}\xampp\xampp_start.exe"
File "${WORK_DIR}\xampp\xampp_stop.exe"
File "${WORK_DIR}\xampp\xampp-control.exe"
File "${WORK_DIR}\xampp\apache_start.bat"
File "${WORK_DIR}\xampp\apache_stop.bat"
File "${WORK_DIR}\xampp\catalina_service.bat"
File "${WORK_DIR}\xampp\catalina_start.bat"
File "${WORK_DIR}\xampp\catalina_stop.bat"
File "${WORK_DIR}\xampp\filezilla_setup.bat"
File "${WORK_DIR}\xampp\filezilla_start.bat"
File "${WORK_DIR}\xampp\filezilla_stop.bat"
File "${WORK_DIR}\xampp\mercury_start.bat"
File "${WORK_DIR}\xampp\mercury_stop.bat"
File "${WORK_DIR}\xampp\mysql_start.bat"
File "${WORK_DIR}\xampp\mysql_stop.bat"
File "${WORK_DIR}\xampp\passwords.txt"
File "${WORK_DIR}\xampp\readme_de.txt"
File "${WORK_DIR}\xampp\test_php.bat"
File "xampp-control.ini"

SetOutPath "$INSTDIR\cgi-bin"
File /r "${WORK_DIR}\xampp\cgi-bin\*.*"
SetOutPath "$INSTDIR\contrib"
File /r "${WORK_DIR}\xampp\contrib\*.*"
SetOutPath "$INSTDIR\htdocs"
File /r "${WORK_DIR}\xampp\htdocs\*.*"
SetOutPath "$INSTDIR\install"
File /r "${WORK_DIR}\xampp\install\*.*"
SetOutPath "$INSTDIR\licenses"
File /r "${WORK_DIR}\xampp\licenses\*.*"
SetOutPath "$INSTDIR\locale"
File /r "${WORK_DIR}\xampp\locale\*.*"
CreateDirectory "$INSTDIR\mailoutput"
SetOutPath "$INSTDIR\mailtodisk"
File /r "${WORK_DIR}\xampp\mailtodisk\*.*"
SetOutPath "$INSTDIR\security"
File /r "${WORK_DIR}\xampp\security\*.*"
SetOutPath "$INSTDIR\webdav"
File /r "${WORK_DIR}\xampp\webdav\*.*"
SetOutPath "$INSTDIR\src"
File /r "${WORK_DIR}\xampp\src\*.*"
SetOutPath "$INSTDIR\tmp"
File /r "${WORK_DIR}\xampp\tmp\*.*"

${WriteLineToFile} `$INSTDIR\xampp-control.ini` ``
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `[Common]`
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Edition=3.1.0`
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Editor=notepad.exe`
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Browser=`
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Debug=0`
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Debuglevel=0`
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `TomcatVisible=1`

StrCmp $LANGUAGE "1031" lang_de
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Language=en`
Goto lang_out
lang_de:
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Language=de`
lang_out:

${WriteLineToFile} `$INSTDIR\xampp-control.ini` ` `
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `[EnableModules]`

WriteRegStr HKLM "Software\xampp" "Install_Dir" "$INSTDIR"
WriteRegStr HKLM "Software\xampp" "apache" "2430"
WriteRegStr HKLM "Software\xampp" "version" "1810"
WriteRegStr HKLM "Software\xampp" "lang" "$LANGUAGE"
WriteRegStr HKLM "Software\xampp" "programfiles" "0"
WriteRegStr HKLM "Software\xampp" "desktopicon" "0"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\xampp" "DisplayName" "${PRODUCT_NAME} ${PRODUCT_VERSION}"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\xampp" "UninstallString" '"$INSTDIR\uninstall.exe"'
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\xampp" "NoModify" 1
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\xampp" "NoRepair" 1
SectionEnd

SectionGroup "XAMPP"
Section "Apachefriends Start Menu"
CreateDirectory "$SMPROGRAMS\Apache Friends\XAMPP"
CreateShortCut "$SMPROGRAMS\Apache Friends\XAMPP" "" ""
CreateShortCut "$SMPROGRAMS\Apache Friends\XAMPP\XAMPP Control Panel.lnk" "$INSTDIR\xampp-control.exe" "" "$INSTDIR\install\xampp.ico"
CreateShortCut "$SMPROGRAMS\Apache Friends\XAMPP\XAMPP htdocs folder.lnk" "$INSTDIR\htdocs" "" "$INSTDIR\install\folder.ico"
CreateShortCut "$SMPROGRAMS\Apache Friends\XAMPP\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\install\xampp-icon-uninstall.ico"
WriteRegStr HKLM "Software\xampp" "programfiles" "1"
SectionEnd

Section "XAMPP Desktop Icon"
CreateShortCut "$DESKTOP\XAMPP Control Panel.lnk" "$INSTDIR\xampp-control.exe" ""
WriteRegStr HKLM "Software\xampp" "desktopicon" "1"
SectionEnd
SectionGroupEnd


SectionGroup "Server"
Section "Apache"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\apache"
File /r "${WORK_DIR}\xampp\apache\*.*"
SectionIn RO
${WriteLineToFile} `$INSTDIR\xampp-control.ini` `Apache=1`
SectionEnd

Section "MySQL"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\mysql"
File /r "${WORK_DIR}\xampp\mysql\*.*"
StrCpy $OPT_MYSQL "true"
SectionEnd

Section "FileZilla FTP Server"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\FileZillaFTP"
File /r "${WORK_DIR}\xampp\FileZillaFTP\*.*"
CreateDirectory "$INSTDIR\anonymous"
StrCpy $OPT_FTPD "true"
SectionEnd

Section "Mercury Mail Server"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\MercuryMail"
File /r "${WORK_DIR}\xampp\MercuryMail\*.*"
StrCpy $OPT_MERCUR "true"
SectionEnd

Section "Tomcat"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\tomcat"
File /r "${WORK_DIR}\xampp\tomcat\*.*"
StrCpy $OPT_TOMCAT "true"
SectionEnd
SectionGroupEnd


SectionGroup "Program languages"
Section "PHP"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\php"
File /r "${WORK_DIR}\xampp\php\*.*"
SectionIn RO
SectionEnd

Section "Perl"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\perl"
File /r "${WORK_DIR}\xampp\perl\*.*"
StrCpy $OPT_PERL "true"
SectionEnd
SectionGroupEnd


SectionGroup "Tools"
Section "phpMyAdmin"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\phpmyadmin"
File /r "${WORK_DIR}\xampp\phpmyadmin\*.*"
StrCpy $OPT_PMA "true"
SectionEnd

Section "Webalizer"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\webalizer"
File /r "${WORK_DIR}\xampp\webalizer\*.*"
StrCpy $OPT_WEBA "true"
SectionEnd

Section "Fake Sendmail"
SetOverwrite ifnewer
SetOutPath "$INSTDIR\sendmail"
File /r "${WORK_DIR}\xampp\sendmail\*.*"
SectionEnd

SectionGroupEnd

Section "-XAMPPSETUP"
SetOutPath "$INSTDIR"
ExecWait '"$INSTDIR\php\php.exe" -n -d output_buffering=0 "$INSTDIR\install\install.php"' $0
StrCmp $0 "0" php_done
       StrCmp $LANGUAGE "1031" lang_de
              MessageBox MB_OK "Installation failed (php.exe). Perhaps you have to install the Microsoft Visual C++ 2008 Redistributable package. After that please execute the setup_xampp.bat in the xampp folder manually."
              GOTO php_done
        lang_de:
              MessageBox MB_OK "Installation gescheitert. Vielleicht sollten Sie das Microsoft Visual C++ 2008 Redistributable Paket auf Ihrem System installieren. Bitte danach die setup_xampp.bat manuell noch einmal ausf�hren."
php_done:

SectionEnd


Section "Uninstall"

;ReadRegStr $9 HKLM "Software\xampp" "lang"
;StrCmp $9 "1031" german0
;MessageBox MB_YESNO "Really uninstall XAMPP?" IDYES NoAbort1
;Abort
;NoAbort1:
;GOTO mess_out
;german0:
;MessageBox MB_YESNO "Wollen Sie wirklich XAMPP desinstallieren?" IDYES mess_out
;Abort
;mess_out:

Exec '"$INSTDIR\apache\bin\pv.exe" -f -k xampp-control.exe'
ReadRegStr $0 HKLM "Software\xampp" "desktopicon"
StrCmp $0 "0" no_icon
Delete "$DESKTOP\XAMPP Control Panel.lnk"
no_icon:
ReadRegStr $8 HKLM "Software\xampp" "programfiles"
StrCmp $8 "0" no_pfiles
  Delete "$SMPROGRAMS\Apache Friends\xampp\*.*"
  RMDir "$SMPROGRAMS\Apache Friends\xampp"
  RMDir "$SMPROGRAMS\Apache Friends"
no_pfiles:

RMDir /r "$INSTDIR\anonymous"
RMDir /r "$INSTDIR\apache"
RMDir /r "$INSTDIR\cgi-bin"
RMDir /r "$INSTDIR\FileZillaFTP"
RMDir /r "$INSTDIR\install"
RMDir /r "$INSTDIR\licenses"
RMDir /r "$INSTDIR\MercuryMail"
RMDir /r "$INSTDIR\perl"
RMDir /r "$INSTDIR\php"
RMDir /r "$INSTDIR\phpMyAdmin"
RMDir /r "$INSTDIR\python"
RMDir /r "$INSTDIR\security"
RMDir /r "$INSTDIR\sendmail"
RMDir /r "$INSTDIR\tmp"
RMDir /r "$INSTDIR\tomcat"
RMDir /r "$INSTDIR\webalizer"
RMDir /r "$INSTDIR\webdav"
RMDir /r "$INSTDIR\nsis"
RMDir /r "$INSTDIR\contrib"
RMDir /r "$INSTDIR\src"
RMDir /r "$INSTDIR\locale"
RMDir /r "$INSTDIR\mailoutput"
RMDir /r "$INSTDIR\mailtodisk"
RMDir /r "$INSTDIR\locale"
RMDir /r "$INSTDIR\mysql"
Delete "$INSTDIR\apache_start.bat"
Delete "$INSTDIR\apache_stop.bat"
Delete "$INSTDIR\filezilla_setup.bat"
Delete "$INSTDIR\filezilla_start.bat"
Delete "$INSTDIR\filezilla_stop.bat"
Delete "$INSTDIR\mercury_start.bat"
Delete "$INSTDIR\mercury_stop.bat"
Delete "$INSTDIR\mysql_start.bat"
Delete "$INSTDIR\mysql_stop.bat"
Delete "$INSTDIR\php-switch.bat"
Delete "$INSTDIR\readme_de.txt"
Delete "$INSTDIR\readme_en.txt"
Delete "$INSTDIR\service.exe"
Delete "$INSTDIR\setup_xampp.bat"
Delete "$INSTDIR\xampp_restart.exe"
Delete "$INSTDIR\xampp_start.exe"
Delete "$INSTDIR\xampp_stop.exe"
Delete "$INSTDIR\xampp-changes.txt"
Delete "$INSTDIR\xampp-portcheck.exe"
Delete "$INSTDIR\Uninstall.exe"
Delete "$INSTDIR\javapath.ini"
Delete "$INSTDIR\readme-addon-perl.txt"
Delete "$INSTDIR\readme-addon-tomcat.txt"
Delete "$INSTDIR\tomcat_start.bat"
Delete "$INSTDIR\tomcat_stop.bat"
Delete "$INSTDIR\passwords.txt"
Delete "$INSTDIR\xampp_cli.exe"
Delete "$INSTDIR\xampp_chkdll.exe"
Delete "$INSTDIR\xampp_service_mercury.exe"
Delete "$INSTDIR\catalina_start.bat"
Delete "$INSTDIR\catalina_stop.bat"
Delete "$INSTDIR\catalina_service.bat"
Delete "$INSTDIR\xampp-control.exe"
Delete "$INSTDIR\xampp-control-old.exe"
Delete "$INSTDIR\xampp-control.ini"
Delete "$INSTDIR\xampp-control.log"
Delete "$INSTDIR\test_php.bat"
Delete "$INSTDIR\changes.txt"

DeleteRegKey HKLM "Software\xampp"
DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\xampp"

; StrCmp $LANGUAGE "1041" japanese2
StrCmp $LANGUAGE "1031" german2
StrCpy $INST_MESS2 "Remove the $INSTDIR\htdocs folder too?"
StrCpy $MESS_INSTDIR1 "Shall the installer try to remove $INSTDIR?"
StrCpy $MESS_INSTDIR2 "Note: $INSTDIR could not be removed!"
GOTO messa2
german2:
StrCpy $INST_MESS2 "Auch das Verzeichnis $INSTDIR\htdocs lchen?"
StrCpy $MESS_INSTDIR1 "Soll der Installer (versuchen) das Verzeichnis $INSTDIR (zu) lchen?"
StrCpy $MESS_INSTDIR2 "Achtung: Knte $INSTDIR nicht lchen!"
GOTO messa2
; japanese2:
; StrCpy $INST_MESS2 "$INSTDIR\htdocs のフォルダーを削除しますか？"
; StrCpy $MESS_INSTDIR1 "Shall the installer try to remove $INSTDIR?"
; StrCpy $MESS_INSTDIR2 "Note: $INSTDIR could not be removed!"
messa2:
MessageBox MB_YESNO|MB_ICONQUESTION "$INST_MESS2" IDYES noHtdocs
Goto NoDelete
noHtdocs:
RMDir /r "$INSTDIR\htdocs"
GOTO NoDocs
NoDelete:
GOTO ExitDel
NoDocs:
StrCmp $DB_DEL "0" NoXaDir

MessageBox MB_YESNO|MB_ICONQUESTION "$MESS_INSTDIR1" IDYES noIDIR
Goto yesIDIR
noIDIR:
RMDir "$INSTDIR"
IfFileExists "$INSTDIR\*.*" ErrorMsg
Goto yesIDIR
ErrorMsg:
MessageBox MB_OK "$MESS_INSTDIR2" ; skipped if file doesn't exist
yesIDIR:

NoXaDir:
ExitDel:
SectionEnd

