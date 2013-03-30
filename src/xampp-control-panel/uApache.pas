unit uApache;

interface

uses GnuGettext, uBaseModule, SysUtils, Classes, Windows, ExtCtrls, StdCtrls, Buttons, uNetstatTable, uTools, uProcesses, Messages, uServices;

type
  tApacheLogType = (altAccess, altError);

  tApache = class(tBaseModule)
    OldPIDs, OldPorts: string;
    OldPIDCount: integer;
    GlobalStatus: string;
    procedure ServiceInstall; override;
    procedure ServiceUnInstall; override;
    procedure Start; override;
    procedure Stop; override;
    procedure Admin; override;
    procedure UpdateStatus; override;
    procedure CheckIsService; reintroduce;
    procedure EditConfig(ConfigFile: string); reintroduce;
    procedure ShowLogs(LogType: tApacheLogType); reintroduce;
    procedure AddLog(Log: string; LogType: tLogType = ltDefault); reintroduce;
    constructor Create(pbbService: TBitBtn; pStatusPanel: tPanel; pPIDLabel, pPortLabel: tLabel; pStartStopButton, pAdminButton: TBitBtn);
    destructor Destroy; override;
  end;

implementation

uses uMain;

const
  // cServiceName = 'Apache2.2';
  cModuleName = 'Apache';

  { tApache }

procedure tApache.AddLog(Log: string; LogType: tLogType = ltDefault);
begin
  inherited AddLog(cModuleName, Log, LogType);
end;

procedure tApache.Admin;
var
  App, Param: string;
begin
  inherited;
  if Config.ServicePorts.Apache = 80 then
    Param := 'http://localhost/'
  else
    Param := 'http://localhost:' + IntToStr(Config.ServicePorts.Apache) + '/';
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

procedure tApache.CheckIsService;
var
  s: string;
  path: string;
begin
  inherited CheckIsService(RemoveWhiteSpace(Config.ServiceNames.Apache));
  if isService then
  begin
    s := _('Service installed');
    path:=GetServicePath(RemoveWhiteSpace(Config.ServiceNames.Apache));
  end
  else
    s := _('Service not installed');
  AddLog(Format(_('Checking for service (name="%s"): %s'), [RemoveWhiteSpace(Config.ServiceNames.Apache), s]), ltDebug);
  if (path<>'') then
  begin
    if (Pos(LowerCase(basedir + 'apache\bin\' + Config.BinaryNames.Apache), LowerCase(path))<>0) then
      AddLog(Format(_('Service Path: %s'), [path]), ltDebug)
    else
    begin
      pStatus.Color := cErrorColor;
      AddLog(_('Apache Service detected with wrong path'), ltError);
      AddLog(_('Change XAMPP Apache settings or'), ltError);
      AddLog(_('Uninstall/disable the other service manually first'), ltError);
      AddLog(Format(_('Found Path: %s'), [Path]), ltError);
      AddLog(Format(_('Expected Path: "%sapache\bin\%s" -k runservice'), [basedir, Config.BinaryNames.Apache]), ltError);
    end
  end
  else
      AddLog(_('Service Path: Service Not Installed'), ltDebug);
end;

constructor tApache.Create;
var
  PortBlocker: string;
  ServerApp, ReqTool: string;
  p: integer;
  Ports: array [0 .. 1] of integer;
  path: string;
  // =(Config.ServicePorts.Apache,Config.ServicePorts.ApacheSSL);
begin
  inherited;
  Ports[0] := Config.ServicePorts.Apache;
  Ports[1] := Config.ServicePorts.ApacheSSL;
  ModuleName := cModuleName;
  OldPIDCount := 0;
  GlobalStatus := 'starting';
  AddLog(_('Initializing module...'), ltDebug);
  ServerApp := basedir + 'apache\bin\' + Config.BinaryNames.Apache;
  ReqTool := basedir + 'apache\bin\pv.exe';
  AddLog(_('Checking for module existence...'), ltDebug);
  if not FileExists(ServerApp) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(_('Problem detected: Apache Not Found!'), ltError);
    AddLog(_('Disabling Apache buttons'), ltError);
    AddLog(_('Run this program from your XAMPP root directory!'), ltError);
    bAdmin.Enabled := False;
    bbService.Enabled := False;
    bStartStop.Enabled := False;
  end;

  if not Config.EnableServices.Apache then
  begin
    AddLog(_('Apache Service is disabled.'), ltDebug);
    fmain.bApacheService.Enabled := false;
  end;

  AddLog(_('Checking for required tools...'), ltDebug);
//  if not FileExists(ReqTool) then
//  begin
//    AddLog(_('Possible problem detected: Required Tool pv.exe Not Found!'), ltError);
//  end;

  CheckIsService;
  path:=GetServicePath(RemoveWhiteSpace(Config.ServiceNames.Apache));

  if Config.EnableChecks.CheckDefaultPorts then
  begin
    AddLog(_('Checking default ports...'), ltDebug);

    for p := Low(Ports) to High(Ports) do
    begin
      PortBlocker := NetStatTable.isPortInUse(Ports[p]);
      if (PortBlocker <> '') then
      begin
        //if (LowerCase(PortBlocker) = LowerCase(ServerApp)) then
        AddLog(Format(_('Portblocker Detected: %s'), [PortBlocker]), ltDebug);
        AddLog(Format(_('Checking for App: %s'), [ServerApp]), ltDebug);
        if isservice then
          AddLog(Format(_('Checking for Service: %s'), [path]), ltDebug);
        if (pos(LowerCase(ServerApp), LowerCase(PortBlocker))<>0) then
        begin
          // AddLog(Format(_('"%s" seems to be running on port %d?'),[ServerApp,Ports[p]]),ltError);
          AddLog(Format(_('XAMPP Apache is already running on port %d'), [Ports[p]]), ltInfo);
        end
        else if (pos(LowerCase(PortBlocker), LowerCase(path))<>0) and (isService = True) then
        begin
          AddLog(Format(_('XAMPP Apache Service is already running on port %d'), [Ports[p]]), ltInfo);
        end
        else
        begin
          pStatus.Color := cErrorColor;
          AddLog(_('Problem detected!'), ltError);
          AddLog(Format(_('Port %d in use by "%s"!'), [Ports[p], PortBlocker]), ltError);
          AddLog(_('Apache WILL NOT start without the configured ports free!'), ltError);
          AddLog(_('You need to uninstall/disable/reconfigure the blocking application'), ltError);
          AddLog(_('or reconfigure Apache to listen on a different port'), ltError);
        end;
      end;
    end;
  end;
end;

destructor tApache.Destroy;
begin
  inherited;
end;

procedure tApache.EditConfig(ConfigFile: string);
var
  App, Param: string;
begin
  App := Config.EditorApp;
  Param := basedir + ConfigFile;
  AddLog(Format(_('Executing %s %s'), [App, Param]), ltDebug);
  ExecuteFile(App, Param, '', SW_SHOW);
end;

procedure tApache.ServiceInstall;
var
  App, Param: string;
  RC: integer;
begin
  App := basedir + 'apache\bin\' + Config.BinaryNames.Apache;
  Param := '-k install -n "' + RemoveWhiteSpace(Config.ServiceNames.Apache) + '"';
  AddLog(_('Installing service...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tApache.ServiceUnInstall;
var
  App, Param: string;
  RC: Cardinal;
begin
  App := basedir + 'apache\bin\' + Config.BinaryNames.Apache;
  Param := '-k uninstall -n "' + RemoveWhiteSpace(Config.ServiceNames.Apache) + '"';
  AddLog(_('Uninstalling service...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tApache.ShowLogs(LogType: tApacheLogType);
var
  App, Param: string;
begin
  App := Config.EditorApp;
  if LogType = altAccess then
    Param := basedir + 'apache\logs\access.log';
  if LogType = altError then
    Param := basedir + 'apache\logs\error.log';
  AddLog(Format(_('Executing "%s %s"'), [App, Param]), ltDebug);
  ExecuteFile(App, Param, '', SW_SHOW);
end;

procedure tApache.Start;
var
  App, ErrMsg: string;
  RC: Cardinal;
begin
  GlobalStatus := 'starting';
  if isService then
  begin
    AddLog(Format(_('Attempting to start %s service...'), [cModuleName]));
    //App := Format('start "%s"', [RemoveWhiteSpace(Config.ServiceNames.Apache)]);
    //AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    //RC := RunAsAdmin('net', App, SW_HIDE);
    RC := StartService(RemoveWhiteSpace(Config.ServiceNames.Apache));
    if (RC = 0) or (RC = 1077) then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      ErrMsg := SysUtils.SysErrorMessage(System.GetLastError);
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
      //AddLog(Format(_('%s'), [ErrMsg]), ltError);
      if (Pos('SideBySide', SystemErrorMessage(RC)) <> 0)
        or (Pos('VC9', SystemErrorMessage(RC)) <> 0)
        or (Pos('VC9', ErrMsg) <> 0 )
        or (Pos('SideBySide', ErrMsg) <> 0) then
      begin
        AddLog(_('You appear to be missing the VC9 Runtime Files'), ltError);
        AddLog(_('You need to download and install the Microsoft Visual C++ 2008 SP1 (x86) Runtimes'), ltError);
        AddLog(_('http://www.microsoft.com/download/en/details.aspx?id=5582'), ltError);
      end;
    end;
  end
  else
  begin
    AddLog(Format(_('Attempting to start %s app...'), [cModuleName]));
    App := basedir + 'apache\bin\' + Config.BinaryNames.Apache;
    AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
    RC := RunProcess(App, SW_HIDE, false);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      ErrMsg := SysUtils.SysErrorMessage(System.GetLastError);
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
      //AddLog(Format(_('%s'), [ErrMsg]), ltError);
      if (Pos('SideBySide', SystemErrorMessage(RC)) <> 0)
        or (Pos('VC9', SystemErrorMessage(RC)) <> 0)
        or (Pos('VC9', ErrMsg) <> 0 )
        or (Pos('SideBySide', ErrMsg) <> 0) then
      begin
        AddLog(_('You appear to be missing the VC9 Runtime Files'), ltError);
        AddLog(_('You need to download and install the Microsoft Visual C++ 2008 SP1 (x86) Runtimes'), ltError);
        AddLog(_('http://www.microsoft.com/download/en/details.aspx?id=5582'), ltError);
      end;
    end;
  end;
end;

procedure tApache.Stop;
var
  i, pPID: integer;
  //App, ErrMsg: string;
  ErrMsg: string;
  RC: Cardinal;
begin
  GlobalStatus := 'stopping';
  if isService then
  begin
    AddLog(Format(_('Attempting to stop %s service...'), [cModuleName]));
    //App := Format('stop "%s"', [RemoveWhiteSpace(Config.ServiceNames.Apache)]);
    //AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    //RC := RunAsAdmin('net', App, SW_HIDE);
    RC := StopService(RemoveWhiteSpace(Config.ServiceNames.Apache));
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      ErrMsg := SysUtils.SysErrorMessage(System.GetLastError);
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
      //AddLog(Format(_('%s'), [ErrMsg]), ltError);
      if (Pos('SideBySide', SystemErrorMessage(RC)) <> 0)
        or (Pos('VC9', SystemErrorMessage(RC)) <> 0)
        or (Pos('VC9', ErrMsg) <> 0 )
        or (Pos('SideBySide', ErrMsg) <> 0) then
      begin
        AddLog(_('You appear to be missing the VC9 Runtime Files'), ltError);
        AddLog(_('You need to download and install the Microsoft Visual C++ 2008 SP1 (x86) Runtimes'), ltError);
        AddLog(_('http://www.microsoft.com/download/en/details.aspx?id=5582'), ltError);
      end;
    end;
  end
  else
  begin
    if PIDList.Count > 0 then
    begin
      for i := 0 to PIDList.Count - 1 do
      begin
        pPID := integer(PIDList[i]);
        AddLog(_('Attempting to stop') + ' ' + cModuleName + ' ' + Format('(PID: %d)', [pPID]));
        //App := Format(basedir + 'apache\bin\pv.exe -f -k -q -i %d', [pPID]);
        //AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
        //RC := RunProcess(App, SW_HIDE, false);
        if not TerminateProcessByID(pPID) then
        begin
          AddLog(Format(_('Problem killing PID %d'), [pPID]), ltError);
          AddLog(_('Check that you have the proper privileges'), ltError);
        end;
//        RC := 0;
//        if RC = 0 then
//          AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
//        else
//        begin
//          ErrMsg := SysUtils.SysErrorMessage(System.GetLastError);
//          AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
//          //AddLog(Format(_('%s'), [ErrMsg]), ltError);
//          if (Pos('SideBySide', SystemErrorMessage(RC)) <> 0)
//            or (Pos('VC9', SystemErrorMessage(RC)) <> 0)
//            or (Pos('VC9', ErrMsg) <> 0 )
//            or (Pos('SideBySide', ErrMsg) <> 0) then
//          begin
//            AddLog(_('You appear to be missing the VC9 Runtime Files'), ltError);
//            AddLog(_('You need to download and install the Microsoft Visual C++ 2008 SP1 (x86) Runtimes'), ltError);
//            AddLog(_('http://www.microsoft.com/download/en/details.aspx?id=5582'), ltError);
//          end;
//        end;
      end;
    end
    else
    begin
      AddLog(_('No PIDs found?!'));
    end;
  end;
end;

procedure tApache.UpdateStatus;
var
  p: integer;
  ProcInfo: TProcInfo;
  s: string;
  Ports: string;
  ErrorStatus: integer;
begin
  isRunning := false;
  PIDList.Clear;
  ErrorStatus := 0;
  for p := 0 to Processes.ProcessList.Count - 1 do
  begin
    ProcInfo := Processes.ProcessList[p];
    if (pos(Config.BinaryNames.Apache, ProcInfo.Module) = 1) then
    begin
      //AddLog(Format(_('Process Path: %s'), [ProcInfo.ExePath]), ltDebug);
      if (pos(IntToStr(Config.ServicePorts.Apache),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
      (pos(IntToStr(Config.ServicePorts.ApacheSSL),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
      (pos(LowerCase(BaseDir), LowerCase(ProcInfo.ExePath)) <> 0) then
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
      s := IntToStr(integer(PIDList[p]))
    else
      s := s + #13 + IntToStr(integer(PIDList[p]));
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
    Ports := NetStatTable.GetPorts4PID(integer(PIDList[p]));
    if Ports <> '' then
    //begin
    //  if s = '' then
        s := RemoveDuplicatePorts(Ports);
    //  else
    //    s := s + ', ' + Ports;
    //end;
  end;
  if s <> OldPorts then
  begin
    lPort.Caption := s;
    OldPorts := s;
  end;

  if (byte(isRunning) <> oldIsRunningByte) or (OldPIDCount <> PIDList.Count) then
  begin
    if (oldIsRunningByte <> 2) and (byte(isRunning) <> oldIsRunningByte) then
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
        AddLog(_('Error: Apache shutdown unexpectedly.'), ltError);
        AddLog(_('This may be due to a blocked port, missing dependencies, '), ltError);
        AddLog(_('improper privileges, a crash, or a shutdown by another method.'), ltError);
        AddLog(_('Check the "/xampp/apache/logs/error.log" file'), ltError);
        AddLog(_('and the Windows Event Viewer for more clues'), ltError);
      end;
    end;

    oldIsRunningByte := byte(isRunning);
    if isRunning then
    begin
      if (PIDList.Count = 2) or ((PIDList.Count = 1) and (isService)) then
      begin
        pStatus.Color := cRunningColor;
        bStartStop.Caption := _('Stop');
        bAdmin.Enabled := true;
        fMain.ApacheTray.ImageIndex := 15;
        fMain.ApacheTrayControl.Caption := _('Stop');
      end
      else
      begin
        pStatus.Color := cPartialColor;
        bStartStop.Caption := _('Stop');
        bAdmin.Enabled := true;
      end;
    end
    else
    begin
      pStatus.Color := cStoppedColor;
      bStartStop.Caption := _('Start');
      bAdmin.Enabled := false;
      fMain.ApacheTray.ImageIndex := 16;
      fMain.ApacheTrayControl.Caption := _('Start');
    end;
  end;

  OldPIDCount := PIDList.Count;

  if AutoStart then
  begin
    AutoStart := false;
    if isRunning then
    begin
      AddLog(_('Autostart aborted: Apache is already running'), ltInfo);
    end
    else
    begin
      AddLog(_('Autostart active: starting...'));
      Start;
    end;
  end;

end;

end.
