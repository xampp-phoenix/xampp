unit uTools;

interface

uses GnuGettext, Classes, Graphics, Windows, SysUtils, TlHelp32, ShellAPI,
  Forms, Dialogs, IniFiles, VersInfo, Character, JCLSecurity, StrUtils;

const
  cRunningColor = 200 * $10000 + 255 * $100 + 200;
  cPartialColor = Graphics.clYellow;
  cStoppedColor = clBtnFace;
  cErrorColor = Graphics.clRed;

  cCompileDate = 'September 20th 2012';
  cr = #13#10;

type
  tLogType = (ltDefault, ltInfo, ltError, ltDebug, ltDebugDetails);

  TWinVersion = record
    WinPlatForm: Byte; // VER_PLATFORM_WIN32_NT, VER_PLATFORM_WIN32_WINDOWS
    WinVersion: string;
    Major: Cardinal;
    Minor: Cardinal;
  end;

  tConfig = class
    Edition: string;
    EditorApp: string;
    BrowserApp: string;
    ShowDebug: boolean;
    DebugLevel: integer;
    Language: string;
    TomcatVisible: boolean;

    ASApache: boolean;
    ASMySQL: boolean;
    ASFileZilla: boolean;
    ASMercury: boolean;
    ASTomcat: boolean;

    EnableChecks: record
      Runtimes: boolean;
      CheckDefaultPorts: boolean;
    end;

    EnableModules: record
      Apache: boolean;
      MySQL: boolean;
      FileZilla: boolean;
      Mercury: boolean;
      Tomcat: boolean;
    end;

    EnableServices: record
      Apache: boolean;
      MySQL: boolean;
      FileZilla: boolean;
      Tomcat: boolean;
    end;

    ServiceNames: record
      Apache: string;
      MySQL: string;
      FileZilla: string;
      Tomcat: string;
    end;

    BinaryNames: record
      Apache: string;
      MySQL: string;
      FileZilla: string;
      FileZillaAdmin: string;
      Mercury: string;
      Tomcat: string;
    end;

    LogSettings: record
      Font: string;
      FontSize: integer;
    end;

    WindowSettings: record
      Left: integer;
      Top: integer;
      Width: integer;
      Height: integer;
    end;

    ServicePorts: record
      Apache:         integer; // 80
      ApacheSSL:      integer; // 443
      MySQL:          integer; // 3306
      FileZilla:      integer; // 21
      FileZillaAdmin: integer; // 14147
      Mercury1:       integer; // 25
      Mercury2:       integer; // 79
      Mercury3:       integer; // 105
      Mercury4:       integer; // 106
      Mercury5:       integer; // 110
      Mercury6:       integer; // 143
      Mercury7:       integer; // 2224
      Tomcat:         integer; // 8005
      TomcatHTTP:     integer; // 8080
      TomcatAJP:      integer; // 8009
    end;

    UserLogs: record
      Apache: tStringList;
      MySQL: tStringList;
      FileZilla: tStringList;
      Mercury: tStringList;
      Tomcat: tStringList;
    end;

    UserConfig: record
      Apache: tStringList;
      MySQL: tStringList;
      FileZilla: tStringList;
      Mercury: tStringList;
      Tomcat: tStringList;
    end;

    constructor Create;
    destructor Destroy; override;
  end;

var
  WinVersion: TWinVersion;
  CurrentUser: string;
  BaseDir: string;
  CachedComputerName: string;
  Config: tConfig;
  IniFileName: string;
  dfsVersionInfoResource1: TdfsVersionInfoResource;
  GlobalProgramversion: string;
  Closing: Boolean;
  pflags: TFixedFileInfoFlags;

procedure LoadSettings;
procedure SaveSettings;
procedure GetSubDirectories(const directory : string; list : TStrings);
function FindMatchText(Strings: TStrings; const SubStr: string): Integer;
function GetWinDir: string;
function IsWindowsAdmin: boolean;
function IntToServiceApp(b: boolean): string;
function GetCurrentUserName: string;
function GetWinVersion: TWinVersion;
function RunProcess(FileName: string; ShowCmd: DWORD; wait: boolean; ProcID: PCardinal = nil): Longword;
function ExecuteFile(FileName, Params, DefaultDir: string; ShowCmd: integer): THandle;
function ShellExecute_AndWait(Operation, FileName, Parameter, Directory: string; Show: Word; bWait: Boolean): Longint;
function RunAsAdmin(FileName, parameters: string; ShowCmd: integer): Cardinal;
function Cardinal2IP(C: Cardinal): string;
function GetComputerName: string;
function SystemErrorMessage(WinErrorCode: Cardinal): string;
function GetSystemLangShort: string;
function TerminateProcessByID(ProcessID: Cardinal): Boolean;
function RemoveWhiteSpace(const s: string): string;
function RemoveDuplicatePorts(s: string): string;
function CompareStrings(List: TStringList; Index1, Index2: Integer): Integer;

implementation

procedure LoadSettings;
var
  mi: TMemIniFile;
begin
  // fMain.AddLog('Loading settings from configuration file: "'+IniFileName+'"',ltDebug);

  mi := nil;
  try
    mi := TMemIniFile.Create(IniFileName);
    Config.Edition := mi.ReadString('Common', 'Edition', 'Beta 6');
    Config.EditorApp := mi.ReadString('Common', 'Editor', 'notepad.exe');
    Config.BrowserApp := mi.ReadString('Common', 'Browser', '');
    Config.ShowDebug := mi.ReadBool('Common', 'Debug', false);
    Config.DebugLevel := mi.ReadInteger('Common', 'Debuglevel', 0);
    Config.Language := mi.ReadString('Common', 'Language', '');
    Config.TomcatVisible := mi.ReadBool('Common', 'TomcatVisible', true);
    Config.LogSettings.Font := mi.ReadString('LogSettings', 'Font', 'Arial');
    Config.LogSettings.FontSize := mi.ReadInteger('LogSettings', 'FontSize', 10);

    Config.WindowSettings.Left := mi.ReadInteger('WindowSettings', 'Left', -1);
    Config.WindowSettings.Top := mi.ReadInteger('WindowSettings', 'Top', -1);
    Config.WindowSettings.Width := mi.ReadInteger('WindowSettings', 'Width', -1);  // 941
    Config.WindowSettings.Height := mi.ReadInteger('WindowSettings', 'Height', -1); // 589

    Config.ASApache := mi.ReadBool('Autostart', 'Apache', false);
    Config.ASMySQL := mi.ReadBool('Autostart', 'MySQL', false);
    Config.ASFileZilla := mi.ReadBool('Autostart', 'FileZilla', false);
    Config.ASMercury := mi.ReadBool('Autostart', 'Mercury', false);
    Config.ASTomcat := mi.ReadBool('Autostart', 'Tomcat', false);

    Config.EnableChecks.Runtimes := mi.ReadBool('Checks', 'CheckRuntimes', true);
    Config.EnableChecks.CheckDefaultPorts := mi.ReadBool('Checks', 'CheckDefaultPorts', true);

    Config.EnableModules.Apache := mi.ReadBool('EnableModules', 'Apache', true);
    Config.EnableModules.MySQL := mi.ReadBool('EnableModules', 'MySQL', true);
    Config.EnableModules.FileZilla := mi.ReadBool('EnableModules', 'FileZilla', true);
    Config.EnableModules.Mercury := mi.ReadBool('EnableModules', 'Mercury', true);
    Config.EnableModules.Tomcat := mi.ReadBool('EnableModules', 'Tomcat', true);

    Config.EnableServices.Apache := mi.ReadBool('EnableServices', 'Apache', true);
    Config.EnableServices.MySQL := mi.ReadBool('EnableServices', 'MySQL', true);
    Config.EnableServices.FileZilla := mi.ReadBool('EnableServices', 'FileZilla', true);
    Config.EnableServices.Tomcat := mi.ReadBool('EnableServices', 'Tomcat', true);

    Config.BinaryNames.Apache := mi.ReadString('BinaryNames', 'Apache', 'httpd.exe');
    Config.BinaryNames.MySQL := mi.ReadString('BinaryNames', 'MySQL', 'mysqld.exe');
    Config.BinaryNames.FileZilla := mi.ReadString('BinaryNames', 'FileZilla', 'filezillaserver.exe');
    Config.BinaryNames.FileZillaAdmin := mi.ReadString('BinaryNames', 'FileZillaAdmin', 'filezilla server interface.exe');
    Config.BinaryNames.Mercury := mi.ReadString('BinaryNames', 'Mercury', 'mercury.exe');
    Config.BinaryNames.Tomcat := mi.ReadString('BinaryNames', 'Tomcat', 'tomcat7.exe');

    Config.ServiceNames.Apache := mi.ReadString('ServiceNames', 'Apache', 'Apache2.4');
    Config.ServiceNames.MySQL := mi.ReadString('ServiceNames', 'MySQL', 'mysql');
    Config.ServiceNames.FileZilla := mi.ReadString('ServiceNames', 'FileZilla', 'FileZillaServer');
    Config.ServiceNames.Tomcat := mi.ReadString('ServiceNames', 'Tomcat', 'Tomcat7');

    Config.ServicePorts.Apache := mi.ReadInteger('ServicePorts', 'Apache', 80);
    Config.ServicePorts.ApacheSSL := mi.ReadInteger('ServicePorts', 'ApacheSSL', 443);
    Config.ServicePorts.MySQL := mi.ReadInteger('ServicePorts', 'MySQL', 3306);
    Config.ServicePorts.FileZilla := mi.ReadInteger('ServicePorts', 'FileZilla', 21);
    Config.ServicePorts.FileZillaAdmin := mi.ReadInteger('ServicePorts', 'FileZillaAdmin', 14147);
    Config.ServicePorts.Mercury1 := mi.ReadInteger('ServicePorts', 'Mercury1', 25);
    Config.ServicePorts.Mercury2 := mi.ReadInteger('ServicePorts', 'Mercury2', 79);
    Config.ServicePorts.Mercury3 := mi.ReadInteger('ServicePorts', 'Mercury3', 105);
    Config.ServicePorts.Mercury4 := mi.ReadInteger('ServicePorts', 'Mercury4', 106);
    Config.ServicePorts.Mercury5 := mi.ReadInteger('ServicePorts', 'Mercury5', 110);
    Config.ServicePorts.Mercury6 := mi.ReadInteger('ServicePorts', 'Mercury6', 143);
    Config.ServicePorts.Mercury7 := mi.ReadInteger('ServicePorts', 'Mercury7', 2224);
    Config.ServicePorts.TomcatHTTP := mi.ReadInteger('ServicePorts', 'TomcatHTTP', 8080);
    Config.ServicePorts.TomcatAJP := mi.ReadInteger('ServicePorts', 'TomcatAJP', 8009);
    Config.ServicePorts.Tomcat := mi.ReadInteger('ServicePorts', 'Tomcat', 8005);

    Config.UserConfig.Apache.DelimitedText := mi.ReadString('UserConfigs', 'Apache', '');
    Config.UserConfig.MySQL.DelimitedText := mi.ReadString('UserConfigs', 'MySQL', '');
    Config.UserConfig.FileZilla.DelimitedText := mi.ReadString('UserConfigs', 'FileZilla', '');
    Config.UserConfig.Mercury.DelimitedText := mi.ReadString('UserConfigs', 'Mercury', '');
    Config.UserConfig.Tomcat.DelimitedText := mi.ReadString('UserConfigs', 'Tomcat', '');

    Config.UserLogs.Apache.DelimitedText := mi.ReadString('UserLogs', 'Apache', '');
    Config.UserLogs.MySQL.DelimitedText := mi.ReadString('UserLogs', 'MySQL', '');
    Config.UserLogs.FileZilla.DelimitedText := mi.ReadString('UserLogs', 'FileZilla', '');
    Config.UserLogs.Mercury.DelimitedText := mi.ReadString('UserLogs', 'Mercury', '');
    Config.UserLogs.Tomcat.DelimitedText := mi.ReadString('UserLogs', 'Tomcat', '');
  except
    on e: exception do
    begin
      MessageDlg(_('Error') + ': ' + e.Message, mtError, [mbOK], 0);
    end;
  end;
  mi.Free;
end;

procedure SaveSettings;
var
  mi: TMemIniFile;
begin
  mi := nil;
  try
    mi := TMemIniFile.Create(IniFileName);
    mi.WriteString('Common', 'Edition', Config.Edition);
    mi.WriteString('Common', 'Editor', Config.EditorApp);
    mi.WriteString('Common', 'Browser', Config.BrowserApp);
    mi.WriteBool('Common', 'Debug', Config.ShowDebug);
    mi.WriteInteger('Common', 'Debuglevel', Config.DebugLevel);
    mi.WriteString('Common', 'Language', Config.Language);
    mi.WriteBool('Common', 'TomcatVisible', Config.TomcatVisible);

    mi.WriteString('LogSettings', 'Font', Config.LogSettings.Font);
    mi.WriteInteger('LogSettings', 'FontSize', Config.LogSettings.FontSize);

    mi.WriteInteger('WindowSettings', 'Left', Config.WindowSettings.Left);
    mi.WriteInteger('WindowSettings', 'Top', Config.WindowSettings.Top);
    mi.WriteInteger('WindowSettings', 'Width', Config.WindowSettings.Width);
    mi.WriteInteger('WindowSettings', 'Height', Config.WindowSettings.Height);

    mi.WriteBool('Autostart', 'Apache', Config.ASApache);
    mi.WriteBool('Autostart', 'MySQL', Config.ASMySQL);
    mi.WriteBool('Autostart', 'FileZilla', Config.ASFileZilla);
    mi.WriteBool('Autostart', 'Mercury', Config.ASMercury);
    mi.WriteBool('Autostart', 'Tomcat', Config.ASTomcat);

    mi.WriteBool('Checks', 'CheckRuntimes', Config.EnableChecks.Runtimes);
    mi.WriteBool('Checks', 'CheckDefaultPorts', Config.EnableChecks.CheckDefaultPorts);

    mi.WriteBool('EnableModules', 'Apache', Config.EnableModules.Apache);
    mi.WriteBool('EnableModules', 'MySQL', Config.EnableModules.MySQL);
    mi.WriteBool('EnableModules', 'FileZilla', Config.EnableModules.FileZilla);
    mi.WriteBool('EnableModules', 'Mercury', Config.EnableModules.Mercury);
    mi.WriteBool('EnableModules', 'Tomcat', Config.EnableModules.Tomcat);

    mi.WriteBool('EnableServices', 'Apache', Config.EnableServices.Apache);
    mi.WriteBool('EnableServices', 'MySQL', Config.EnableServices.MySQL);
    mi.WriteBool('EnableServices', 'FileZilla', Config.EnableServices.FileZilla);
    mi.WriteBool('EnableServices', 'Tomcat', Config.EnableServices.Tomcat);

    mi.WriteString('BinaryNames', 'Apache', Config.BinaryNames.Apache);
    mi.WriteString('BinaryNames', 'MySQL', Config.BinaryNames.MySQL);
    mi.WriteString('BinaryNames', 'FileZilla', Config.BinaryNames.FileZilla);
    mi.WriteString('BinaryNames', 'FileZillaAdmin', Config.BinaryNames.FileZillaAdmin);
    mi.WriteString('BinaryNames', 'Mercury', Config.BinaryNames.Mercury);
    mi.WriteString('BinaryNames', 'Tomcat', Config.BinaryNames.Tomcat);

    mi.WriteString('ServiceNames', 'Apache', Config.ServiceNames.Apache);
    mi.WriteString('ServiceNames', 'MySQL', Config.ServiceNames.MySQL);
    mi.WriteString('ServiceNames', 'FileZilla', Config.ServiceNames.FileZilla);
    mi.WriteString('ServiceNames', 'Tomcat', Config.ServiceNames.Tomcat);

    mi.WriteInteger('ServicePorts', 'Apache', Config.ServicePorts.Apache);
    mi.WriteInteger('ServicePorts', 'ApacheSSL', Config.ServicePorts.ApacheSSL);
    mi.WriteInteger('ServicePorts', 'MySQL', Config.ServicePorts.MySQL);
    mi.WriteInteger('ServicePorts', 'FileZilla', Config.ServicePorts.FileZilla);
    mi.WriteInteger('ServicePorts', 'FileZillaAdmin', Config.ServicePorts.FileZillaAdmin);
    mi.WriteInteger('ServicePorts', 'Mercury1', Config.ServicePorts.Mercury1);
    mi.WriteInteger('ServicePorts', 'Mercury2', Config.ServicePorts.Mercury2);
    mi.WriteInteger('ServicePorts', 'Mercury3', Config.ServicePorts.Mercury3);
    mi.WriteInteger('ServicePorts', 'Mercury4', Config.ServicePorts.Mercury4);
    mi.WriteInteger('ServicePorts', 'Mercury5', Config.ServicePorts.Mercury5);
    mi.WriteInteger('ServicePorts', 'Mercury6', Config.ServicePorts.Mercury6);
    mi.WriteInteger('ServicePorts', 'Mercury7', Config.ServicePorts.Mercury7);
    mi.WriteInteger('ServicePorts', 'TomcatHTTP', Config.ServicePorts.TomcatHTTP);
    mi.WriteInteger('ServicePorts', 'TomcatAJP', Config.ServicePorts.TomcatAJP);
    mi.WriteInteger('ServicePorts', 'Tomcat', Config.ServicePorts.Tomcat);

    mi.WriteString('UserConfigs', 'Apache', Config.UserConfig.Apache.DelimitedText);
    mi.WriteString('UserConfigs', 'MySQL', Config.UserConfig.MySQL.DelimitedText);
    mi.WriteString('UserConfigs', 'FileZilla', Config.UserConfig.FileZilla.DelimitedText);
    mi.WriteString('UserConfigs', 'Mercury', Config.UserConfig.Mercury.DelimitedText);
    mi.WriteString('UserConfigs', 'Tomcat', Config.UserConfig.Tomcat.DelimitedText);

    mi.WriteString('UserLogs', 'Apache', Config.UserLogs.Apache.DelimitedText);
    mi.WriteString('UserLogs', 'MySQL', Config.UserLogs.MySQL.DelimitedText);
    mi.WriteString('UserLogs', 'FileZilla', Config.UserLogs.FileZilla.DelimitedText);
    mi.WriteString('UserLogs', 'Mercury', Config.UserLogs.Mercury.DelimitedText);
    mi.WriteString('UserLogs', 'Tomcat', Config.UserLogs.Tomcat.DelimitedText);

    mi.UpdateFile;
  except
    on e: exception do
    begin
      MessageDlg(_('Error') + ': ' + e.Message, mtError, [mbOK], 0);
    end;
  end;
  mi.Free;
end;

function TerminateProcessByID(ProcessID: Cardinal): Boolean;
var
  hProcess : THandle;
begin
  Result := False;
  hProcess := OpenProcess(PROCESS_TERMINATE,False,ProcessID);
  if hProcess > 0 then
  try
    Result := Windows.TerminateProcess(hProcess,0);
  finally
    CloseHandle(hProcess);
  end;
end;

function FindMatchText(Strings: TStrings; const SubStr: string): Integer;
begin
  for Result := 0 to Strings.Count-1 do
    if ContainsText(Strings[Result], SubStr) then
      exit;
  Result := -1;
end;

function GetWinDir: string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
   GetWindowsDirectory(Buffer, MAX_PATH - 1);
   SetLength(Result, StrLen(Buffer));
   Result := Buffer;
end;

procedure GetSubDirectories(const directory : string; list : TStrings);
var
  sr : TSearchRec;
begin
  try
    if FindFirst(IncludeTrailingPathDelimiter(directory) + '*.*', faDirectory, sr) < 0 then
      Exit
    else
    repeat
      if ((sr.Attr and faDirectory <> 0) AND (sr.Name <> '.') AND (sr.Name <> '..')) then
        List.Add(IncludeTrailingPathDelimiter(directory) + sr.Name) ;
    until FindNext(sr) <> 0;
  finally
    SysUtils.FindClose(sr) ;
  end;
end;

// Taken from: http://stackoverflow.com/questions/5078895/how-to-remove-space-tabs-or-any-whitespace-from-stringlist
function RemoveWhiteSpace(const s: string): string;
var
  i, j: integer;
begin
  SetLength(Result, Length(s));
  j := 0;
  for i := 1 to Length(s) do
  begin
    if not TCharacter.IsWhiteSpace(s[i]) then
    begin
      inc(j);
      Result[j] := s[i];
    end;
  end;
  SetLength(Result, j);
end;

function RemoveDuplicatePorts(s: string): string;
var
  StringList: TStringList;
begin
  if (pos(',',s)<>0) then
  begin
    StringList := TStringList.Create();
    StringList.Duplicates := dupIgnore;
    StringList.Delimiter := ',';
    StringList.Sorted := True;
    StringList.DelimitedText := s;
    StringList.Sorted := False;
    StringList.CustomSort(CompareStrings);
    Result := Trim(StringReplace(StringList.CommaText,',',', ',[rfReplaceAll]));
    StringList.Free();
  end
  else
    Result := s;
end;

function CompareStrings(List: TStringList; Index1, Index2: Integer): Integer;
var
  XInt1, XInt2: integer;
begin
  try
    XInt1 := strToInt(List[Index1]);
    XInt2 := strToInt(List[Index2]);
  except
    XInt1 := 0;
    XInt2 := 0;
  end;
  if XInt1 > XInt2 then
    Result := 1
  else if XInt1 < XInt2 then
    Result := -1
  else
    Result := 0;
end;

function IsWindowsAdmin: boolean;
//type
//  TIsUserAnAdminFunc = function(): BOOL; stdcall;
//var
//  Shell32DLL: THandle;
//  IsUserAnAdminFunc: TIsUserAnAdminFunc;
begin
  Result := IsAdministrator()
//  Result := true;
//  if WinVersion.Major < 6 then
//    exit; // older than vista? just return TRUE
//
//  Shell32DLL := LoadLibrary('shell32.dll');
//  try
//    if Shell32DLL <> 0 then
//    begin
//      @IsUserAnAdminFunc := GetProcAddress(Shell32DLL, 'IsUserAnAdmin');
//      if Assigned(@IsUserAnAdminFunc) then
//        Result := IsUserAnAdminFunc();
//    end;
//  except
//  end;
//  FreeLibrary(Shell32DLL);
end;

function IntToServiceApp(b: boolean): string;
begin
  if b then
    Result := _('Service')
  else
    Result := _('Application')
end;

function SystemErrorMessage(WinErrorCode: Cardinal): string;
var
  P: PChar;
begin
  if FormatMessage(Format_Message_Allocate_Buffer + Format_Message_From_System, nil, WinErrorCode, 0, @P, 0, nil) <> 0 then
  begin
    Result := trim(P);
    LocalFree(integer(P));
  end
  else
  begin
    Result := '';
  end;
end;

function GetCurrentUserName: string;
const
  cnMaxUserNameLen = 254;
var
  sUserName: string;
  dwUserNameLen: DWORD;
begin
  dwUserNameLen := cnMaxUserNameLen - 1;
  SetLength(sUserName, cnMaxUserNameLen);
  GetUserName(PChar(sUserName), dwUserNameLen);
  SetLength(sUserName, dwUserNameLen);
  Result := sUserName;
end;

function GetWinVersion: TWinVersion;
var
  osVerInfo: TOSVersionInfo;
  s: string;
begin
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(osVerInfo) then
  begin
    Result.WinPlatForm := osVerInfo.dwPlatformId;
    Result.Major := osVerInfo.dwMajorVersion;
    Result.Minor := osVerInfo.dwMinorVersion;
    s := osVerInfo.szCSDVersion;
    if s <> '' then
      s := ' - ' + s;

    Result.WinVersion := Format('%d.%d (build %d)%s', [osVerInfo.dwMajorVersion, osVerInfo.dwMinorVersion, osVerInfo.dwBuildNumber, s]);
  end;
end;

function RunProcess(FileName: string; ShowCmd: DWORD; wait: boolean; ProcID: PCardinal = nil): Longword;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  //dwI: DWORD;
begin
  Result := 0;
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
  StartupInfo.wShowWindow := ShowCmd;
  if not CreateProcess(nil, @FileName[1], nil, nil, false, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then
    //Result := WAIT_FAILED
    GetExitCodeProcess(ProcessInfo.hProcess, Result)
    //Result := GetLastError
  else
  begin
    if wait = false then
    begin
      if ProcID <> nil then
        ProcID^ := ProcessInfo.dwProcessId;
      GetExitCodeProcess(ProcessInfo.hProcess, Result);
      if Result = 259 then // No Information Return Code
        Result := 0;
      exit;
    end;
    //dwI :=
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, Result);

  //  if (dwI = WAIT_OBJECT_0) then
  //    if (GetExitCodeProcess(ProcessInfo.hProcess, dwI)) then Result := dwI;

  end;
  if ProcessInfo.hProcess <> 0 then
    CloseHandle(ProcessInfo.hProcess);
  if ProcessInfo.hThread <> 0 then
    CloseHandle(ProcessInfo.hThread);
  if Result = 259 then // No Information Return Code
    Result := 0;
end;

function ExecuteFile(FileName, Params, DefaultDir: string; ShowCmd: integer): THandle;
var
  zFileName, zParams, zDir: array [0 .. 255] of Char;
begin
  if DefaultDir = '' then
    DefaultDir := BaseDir;
  Result := ShellExecute(Application.MainForm.Handle, 'open', StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
    StrPCopy(zDir, DefaultDir), ShowCmd);
end;

function ShellExecute_AndWait(Operation, FileName, Parameter, Directory: string; Show: Word; bWait: Boolean): Longint;
var
  bOK: Boolean;
  Info: TShellExecuteInfo;
  Ret: Cardinal;
{
  ****** Parameters ******
  Operation:

  edit  Launches an editor and opens the document for editing.
  explore Explores the folder specified by lpFile.
  find Initiates a search starting from the specified directory.
  open Opens the file, folder specified by the lpFile parameter.
  print Prints the document file specified by lpFile.
  properties Displays the file or folder's properties.

  FileName:

  Specifies the name of the file or object on which
  ShellExecuteEx will perform the action specified by the lpVerb parameter.

  Parameter:

  String that contains the application parameters.
  The parameters must be separated by spaces.

  Directory:

  specifies the name of the working directory.
  If this member is not specified, the current directory is used as the working directory.

  Show:

  Flags that specify how an application is to be shown when it is opened.
  It can be one of the SW_ values

  bWait:

  If true, the function waits for the process to terminate
}
begin
  FillChar(Info, SizeOf(Info), Chr(0));
  Info.cbSize := SizeOf(Info);
  Info.fMask := SEE_MASK_NOCLOSEPROCESS;
  Info.lpVerb := PChar(Operation);
  Info.lpFile := PChar(FileName);
  Info.lpParameters := PChar(Parameter);
  Info.lpDirectory := PChar(Directory);
  Info.nShow := Show;
  bOK := Boolean(ShellExecuteEx(@Info));
  if bOK then
  begin
    if bWait then
    begin
//      while
//        WaitForSingleObject(Info.hProcess, 100) = WAIT_TIMEOUT
//        do Application.ProcessMessages;
      repeat
        Ret := WaitForSingleObject(Info.hProcess, 500);
        Application.ProcessMessages;
      until ((Ret <> WAIT_TIMEOUT) or (Closing = True));
      bOK := GetExitCodeProcess(Info.hProcess, DWORD(Result));
    end
    else
      //Result := 0;
      GetExitCodeProcess(Info.hProcess, DWORD(Result));
  end;
  if not bOK then Result := -1;
  if (Closing = True) then
    Result := 0;
end;

function RunAsAdmin(FileName, parameters: string; ShowCmd: integer): Cardinal;
var
  Info: TShellExecuteInfo;
  pInfo: PShellExecuteInfo;
begin
  pInfo := @Info;
  with Info do
  begin
    cbSize := SizeOf(Info);
    fMask := SEE_MASK_NOCLOSEPROCESS;
    wnd := Application.Handle;

    // 6 = Vista or Higher
    if (WinVersion.Major<6) and IsWindowsAdmin then begin
      lpVerb := nil;
    end else begin
      lpVerb := PChar('runas');
    end;

    lpFile := PChar(FileName);
    lpParameters := PChar(parameters + #0);
    lpDirectory := NIL;
    nShow := ShowCmd;
    hInstApp := 0;
  end;
  if not ShellExecuteEx(pInfo) then
  begin
    Result := GetLastError;
    exit;
  end;
  { Wait to finish }
  repeat
    Result := WaitForSingleObject(Info.hProcess, 500);
    Application.ProcessMessages;
  until ((Result <> WAIT_TIMEOUT) or (Closing = True));
  //GetExitCodeProcess(Info.hProcess, Result);
  if (Closing = True) then
    Result := 0;
  CloseHandle(Info.hProcess);
end;

function Cardinal2IP(C: Cardinal): string;
begin
  Result := inttostr((C and $000000FF)) + '.' + inttostr((C and $0000FF00) shr 08) + '.' + inttostr((C and $00FF0000) shr 16) + '.' +
    inttostr((C and $FF000000) shr 24);
end;

function GetComputerName: string;
const
  MAX_COMPUTERNAME_LENGTH = 100;
var
  ComputerName: array [0 .. MAX_COMPUTERNAME_LENGTH + 1] of Char;
  // var ComputerName: array[0..50 + 1] of Char;
  size: Cardinal;
  LE: Cardinal;
begin
  try
    if CachedComputerName = '' then
    begin
      size := MAX_COMPUTERNAME_LENGTH;
      if Windows.GetComputerName(ComputerName, size) then
      begin
        Result := ComputerName;
        CachedComputerName := ComputerName;
      end
      else
      begin
        LE := GetLastError;
        MessageDlg(Format('GetComputerName failed, Code: %d - %s', [LE, SystemErrorMessage(LE)]), mtError, [mbOK], 0);
        Result := '';
      end;
    end
    else
    begin
      Result := CachedComputerName;
    end;
  except
    Result := '';
  end;
end;

function GetSystemLangShort: string;
var
  bla: array [0 .. 1023] of Char;
  s: string;

begin
  GetLocaleInfo(GetSystemDefaultLCID, LOCALE_SENGLANGUAGE, @bla, SizeOf(bla));
  s := uppercase(bla);
  if s = 'GERMAN' then
    Result := 'de'
  else if s = 'ENGLISH' then
    Result := 'en'
  else if s = 'FRENCH' then
    Result := 'fr'
  else if s = 'ITALIAN' then
    Result := 'it'
  else
    Result := 'en';
end;

{ tConfig }

constructor tConfig.Create;
begin
  UserLogs.Apache := tStringList.Create;
  UserLogs.MySQL := tStringList.Create;
  UserLogs.FileZilla := tStringList.Create;
  UserLogs.Mercury := tStringList.Create;
  UserLogs.Tomcat := tStringList.Create;

  UserConfig.Apache := tStringList.Create;
  UserConfig.MySQL := tStringList.Create;
  UserConfig.FileZilla := tStringList.Create;
  UserConfig.Mercury := tStringList.Create;
  UserConfig.Tomcat := tStringList.Create;

  UserLogs.Apache.Delimiter := '|';
  UserLogs.MySQL.Delimiter := '|';
  UserLogs.FileZilla.Delimiter := '|';
  UserLogs.Mercury.Delimiter := '|';
  UserLogs.Tomcat.Delimiter := '|';

  UserConfig.Apache.Delimiter := '|';
  UserConfig.MySQL.Delimiter := '|';
  UserConfig.FileZilla.Delimiter := '|';
  UserConfig.Mercury.Delimiter := '|';
  UserConfig.Tomcat.Delimiter := '|';
end;

destructor tConfig.Destroy;
begin
  FreeAndNil(UserLogs.Apache);
  FreeAndNil(UserLogs.MySQL);
  FreeAndNil(UserLogs.FileZilla);
  FreeAndNil(UserLogs.Mercury);
  FreeAndNil(UserLogs.Tomcat);

  FreeAndNil(UserConfig.Apache);
  FreeAndNil(UserConfig.MySQL);
  FreeAndNil(UserConfig.FileZilla);
  FreeAndNil(UserConfig.Mercury);
  FreeAndNil(UserConfig.Tomcat);
  inherited;
end;

initialization

Config := tConfig.Create;
CachedComputerName := '';
Closing := False;
dfsVersionInfoResource1 := TdfsVersionInfoResource.Create();
dfsVersionInfoResource1.FileName := Application.ExeName;
with dfsVersionInfoResource1.FileVersion do
  GlobalProgramversion := inttostr(Major) + '.' + inttostr(Minor) + '.' + inttostr(Release);
pflags := dfsVersionInfoResource1.FixedInfo.Flags;
if TFixedFileInfoFlag.ffPreRelease in pflags then
  GlobalProgramversion := GlobalProgramversion; // + ' ' + cEdition;
dfsVersionInfoResource1.Free;

finalization

Config.Free;

end.
