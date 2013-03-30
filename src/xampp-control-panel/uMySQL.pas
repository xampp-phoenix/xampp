unit uMySQL;

interface

uses GnuGettext, uBaseModule, SysUtils, Classes, Windows, ExtCtrls, StdCtrls, Buttons, uNetstatTable, uTools, uProcesses, uServices;

type
  tMySQL = class(tBaseModule)
    OldPIDs, OldPorts: string;
    GlobalStatus: string;
    procedure ServiceInstall; override;
    procedure ServiceUnInstall; override;
    procedure Start; override;
    procedure Stop; override;
    procedure Admin; override;
    procedure UpdateStatus; override;
    procedure CheckIsService; reintroduce;
    procedure AddLog(Log: string; LogType: tLogType = ltDefault); reintroduce;
    constructor Create(pbbService: TBitBtn; pStatusPanel: tPanel; pPIDLabel, pPortLabel: tLabel; pStartStopButton, pAdminButton: TBitBtn);
    destructor Destroy; override;
  end;

implementation

uses uMain;

const // cServiceName = 'mysql';
  cModuleName = 'MySQL';

  { tMySQL }

procedure tMySQL.AddLog(Log: string; LogType: tLogType);
begin
  inherited AddLog('mysql', Log, LogType);
end;

procedure tMySQL.Admin;
var
  App, Param: string;
begin
  if Config.ServicePorts.Apache = 80 then
    Param := 'http://localhost/phpmyadmin/'
  else
    Param := 'http://localhost:' + IntToStr(Config.ServicePorts.Apache) + '/phpmyadmin';
  if Config.BrowserApp <> '' then
  begin
    App := Config.BrowserApp;
    ExecuteFile(App, Param, '', SW_SHOW);
    AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
  end
  else
  begin
    ExecuteFile(Param, '', '', SW_SHOW);
    AddLog(Format(_('Executing "%s"'), [Param]), ltDebug);
  end;
end;

procedure tMySQL.CheckIsService;
var
  s: string;
  path: string;
begin
  inherited CheckIsService(Config.ServiceNames.MySQL);
  if isService then
  begin
    s := _('Service installed');
    path:=GetServicePath(Config.ServiceNames.MySQL);
  end
  else
    s := _('Service not installed');
  AddLog(Format(_('Checking for service (name="%s"): %s'), [Config.ServiceNames.MySQL, s]), ltDebug);
  if (path<>'') then
  begin
    if (Pos(LowerCase(basedir + 'mysql\bin\' + Config.BinaryNames.MySQL), LowerCase(path))<>0) then
      AddLog(Format(_('Service Path: %s'), [path]), ltDebug)
    else
    begin
      pStatus.Color := cErrorColor;
      AddLog(_('MySQL Service detected with wrong path'), ltError);
      AddLog(_('Change XAMPP MySQL settings or'), ltError);
      AddLog(_('Uninstall/disable the other service manually first'), ltError);
      AddLog(Format(_('Found Path: %s'), [Path]), ltError);
      AddLog(Format(_('Expected Path: %smysql\bin\%s --defaults-file=%smysql\bin\my.ini %s'), [basedir, Config.BinaryNames.MySQL, basedir, Config.ServiceNames.MySQL]), ltError);
    end
  end
  else
    AddLog(_('Service Path: Service Not Installed'), ltDebug);
end;

constructor tMySQL.Create;
var
  PortBlocker: string;
  ServerApp, ReqTool: string;
  ServerPort: Integer;
  path: string;
begin
  inherited;
  ModuleName := cModuleName;
  GlobalStatus := 'starting';
  AddLog(_('Initializing module...'), ltDebug);
  ServerApp := basedir + 'mysql\bin\' + Config.BinaryNames.MySQL;
  ReqTool := basedir + 'apache\bin\pv.exe';
  AddLog(_('Checking for module existence...'), ltDebug);
  if not FileExists(ServerApp) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(_('Problem detected: MySQL Not Found!'), ltError);
    AddLog(_('Disabling MySQL buttons'), ltError);
    AddLog(_('Run this program from your XAMPP root directory!'), ltError);
    bAdmin.Enabled := False;
    bbService.Enabled := False;
    bStartStop.Enabled := False;
  end;

  if not Config.EnableServices.MySQL then
  begin
    AddLog(_('Apache Service is disabled.'), ltDebug);
    fmain.bMySQLService.Enabled := false;
  end;

  AddLog(_('Checking for required tools...'), ltDebug);
//  if not FileExists(ReqTool) then
//  begin
//    AddLog(_('Possible problem detected: Required Tool pv.exe Not Found!'), ltError);
//  end;

  CheckIsService;
  path:=GetServicePath(Config.ServiceNames.MySQL);

  if Config.EnableChecks.CheckDefaultPorts then
  begin
    ServerPort := Config.ServicePorts.MySQL;
    AddLog(_('Checking default ports...'), ltDebug);
    PortBlocker := NetStatTable.isPortInUse(ServerPort);
    if (PortBlocker <> '') then
    begin
      //if (LowerCase(PortBlocker) = LowerCase(ServerApp)) then
      AddLog(Format(_('Portblocker Detected: %s'), [PortBlocker]), ltDebug);
      AddLog(Format(_('Checking for App: %s'), [ServerApp]), ltDebug);
      if isservice then
        AddLog(Format(_('Checking for Service: %s'), [path]), ltDebug);
      if (pos(LowerCase(ServerApp), LowerCase(PortBlocker))<>0) then
      begin
        AddLog(Format(_('XAMPP MySQL is already running on port %d'), [ServerPort]), ltInfo);
      end
      else if (pos(LowerCase(PortBlocker), LowerCase(path))<>0) and (isService = True) then
      begin
        AddLog(Format(_('XAMPP MySQL Service is already running on port %d'), [ServerPort]), ltInfo);
      end
      else
      begin
        pStatus.Color := cErrorColor;
        AddLog(_('Problem detected!'), ltError);
        AddLog(Format(_('Port %d in use by "%s"!'), [ServerPort, PortBlocker]), ltError);
        AddLog(_('MySQL WILL NOT start without the configured ports free!'), ltError);
        AddLog(_('You need to uninstall/disable/reconfigure the blocking application'), ltError);
        AddLog(_('or reconfigure MySQL to listen on a different port'), ltError);
      end;
    end;
  end;
end;

destructor tMySQL.Destroy;
begin
  inherited;
end;

procedure tMySQL.ServiceInstall;
var
  App, Param: string;
  RC: Integer;
begin
  App := '"' + basedir + 'mysql\bin\' + Config.BinaryNames.MySQL + '"';
  Param := '--install "' + Config.ServiceNames.MySQL + '" --defaults-file="' + basedir + 'mysql\bin\my.ini"';
  AddLog(_('Installing service...'));
  AddLog(Format(_('Executing %s %s'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tMySQL.ServiceUnInstall;
var
  App, Param: string;
  RC: Cardinal;
begin
  App := basedir + 'mysql\bin\' + Config.BinaryNames.MySQL;
  Param := '--remove "' + Config.ServiceNames.MySQL + '"';
  AddLog('Uninstalling service...');
  AddLog(Format(_('Executing %s %s'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tMySQL.Start;
var
  App: string;
  RC: Cardinal;
begin
  GlobalStatus := 'starting';
  if isService then
  begin
    AddLog(Format(_('Attempting to start %s service...'), [cModuleName]));
    App := Format('start "%s"', [Config.ServiceNames.MySQL]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
      //AddLog(Format(_('%s'), [SysUtils.SysErrorMessage(System.GetLastError)]), ltError);
    end;
  end
  else
  begin
    AddLog(Format(_('Attempting to start %s app...'), [cModuleName]));
    App := '"' + basedir + 'mysql\bin\' + Config.BinaryNames.MySQL + '" --defaults-file="' + basedir + 'mysql\bin\my.ini" --standalone';
    AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
    RC := RunProcess(App, SW_HIDE, false);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
      //AddLog(Format(_('%s'), [SysUtils.SysErrorMessage(System.GetLastError)]), ltError);
    end;
  end;
end;

procedure tMySQL.Stop;
var
  i, pPID: Integer;
  App: string;
  RC: Cardinal;
begin
  GlobalStatus := 'stopping';
  if isService then
  begin
    AddLog(Format(_('Attempting to stop %s service...'), [cModuleName]));
    App := Format('stop "%s"', [Config.ServiceNames.MySQL]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
      AddLog(Format(_('%s'), [SysUtils.SysErrorMessage(System.GetLastError)]), ltError);
    end;
  end
  else
  begin
    if PIDList.Count > 0 then
    begin
      for i := 0 to PIDList.Count - 1 do
      begin
        pPID := Integer(PIDList[i]);
        AddLog(_('Attempting to stop') + ' ' + cModuleName + ' ' + Format('(PID: %d)', [pPID]));
        if not TerminateProcessByID(pPID) then
        begin
          AddLog(Format(_('Problem killing PID %d'), [pPID]), ltError);
          AddLog(_('Check that you have the proper privileges'), ltError);
        end;
//        App := Format(basedir + 'apache\bin\pv.exe -f -k -q -i %d', [pPID]);
//        AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
//        RC := RunProcess(App, SW_HIDE, false);
//        if RC = 0 then
//          AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
//        else
//        begin
//          AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
//          AddLog(Format(_('%s'), [SysUtils.SysErrorMessage(System.GetLastError)]), ltError);
//        end;
      end;
    end
    else
    begin
      AddLog(_('No PIDs found?!'));
    end;
  end;
end;

procedure tMySQL.UpdateStatus;
var
  p: Integer;
  ProcInfo: TProcInfo;
  s: string;
  ports: string;
  ErrorStatus: integer;
begin
  isRunning := false;
  PIDList.Clear;
  ErrorStatus := 0;
  for p := 0 to Processes.ProcessList.Count - 1 do
  begin
    ProcInfo := Processes.ProcessList[p];
    if (pos(Config.BinaryNames.MySQL, ProcInfo.Module) = 1) then
    begin
      if (pos(IntToStr(Config.ServicePorts.MySQL),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
      (pos(BaseDir, ProcInfo.ExePath) <> 0) then
      begin
        isRunning := true;
        PIDList.Add(Pointer(ProcInfo.PID));
      end;
    end;
  end;

  // Checking processes
  s := '';
  for p := 0 to PIDList.Count - 1 do
  begin
    if p = 0 then
      s := IntToStr(Integer(PIDList[p]))
    else
      s := s + #13 + IntToStr(Integer(PIDList[p]));
  end;
  if s <> OldPIDs then
  begin
    lPID.Caption := s;
    OldPIDs := s;
  end;

  // Checking netstats
  s := '';
  for p := 0 to PIDList.Count - 1 do
  begin
    ports := NetStatTable.GetPorts4PID(Integer(PIDList[p]));
    if ports <> '' then
    //begin
    //  if s = '' then
        s := RemoveDuplicatePorts(ports);
    //  else
    //    s := s + ', ' + ports;
    //end;
  end;
  if s <> OldPorts then
  begin
    lPort.Caption := s;
    OldPorts := s;
  end;

  if byte(isRunning) <> oldIsRunningByte then
  begin
    if oldIsRunningByte <> 2 then
    begin
      if isRunning then
        s := _('running')
      else
      begin
        s := _('stopped');
        if GlobalStatus = 'starting' then
         ErrorStatus := 1;
      end;
      AddLog(_('Status change detected:') + ' ' + s);
      if ErrorStatus = 1 then
      begin
        pStatus.Color := cErrorColor;
        AddLog(_('Error: MySQL shutdown unexpectedly.'), ltError);
        AddLog(_('This may be due to a blocked port, missing dependencies, '), ltError);
        AddLog(_('improper privileges, a crash, or a shutdown by another method.'), ltError);
        AddLog(_('Check the "/xampp/mysql/data/mysql_error.log" file'), ltError);
        AddLog(_('and the Windows Event Viewer for more clues'), ltError);
      end;
    end;

    oldIsRunningByte := byte(isRunning);
    if isRunning then
    begin
      pStatus.Color := cRunningColor;
      bStartStop.Caption := _('Stop');
      bAdmin.Enabled := true;
      fMain.MySQLTray.ImageIndex := 15;
      fMain.MySQLTrayControl.Caption := _('Stop');
    end
    else
    begin
      pStatus.Color := cStoppedColor;
      bStartStop.Caption := _('Start');
      bAdmin.Enabled := false;
      fMain.MySQLTray.ImageIndex := 16;
      fMain.MySQLTrayControl.Caption := _('Start');
    end;
  end;

  if AutoStart then
  begin
    AutoStart := false;
    if isRunning then
    begin
      AddLog(_('Autostart aborted: MySQL is already running'), ltInfo);
    end
    else
    begin
      AddLog(_('Autostart active: starting...'));
      Start;
    end;
  end;
end;

end.
