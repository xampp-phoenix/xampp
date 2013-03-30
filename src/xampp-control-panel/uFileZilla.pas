unit uFileZilla;

interface

uses GnuGettext, uBaseModule, SysUtils, Classes, Windows, ExtCtrls, StdCtrls, Buttons, uNetstatTable, uTools, uProcesses, uServices;

type
  tFileZilla = class(tBaseModule)
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

const // cServiceName = 'FileZilla Server';
  cModuleName = 'FileZilla';

  { tFileZilla }

procedure tFileZilla.AddLog(Log: string; LogType: tLogType);
begin
  inherited AddLog('filezilla', Log, LogType);
end;

procedure tFileZilla.Admin;
var
  App: string;
begin
  App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZillaAdmin;
  AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
  ExecuteFile(App, '', '', SW_SHOW);
end;

procedure tFileZilla.CheckIsService;
var
  s: string;
  path: string;
begin
  inherited CheckIsService(RemoveWhiteSpace(Config.ServiceNames.FileZilla));
  if isService then
  begin
    s := _('Service installed');
    path:=GetServicePath(RemoveWhiteSpace(Config.ServiceNames.FileZilla));
  end
  else
    s := _('Service not installed');
  AddLog(Format(_('Checking for service (name="%s"): %s'), [RemoveWhiteSpace(Config.ServiceNames.FileZilla), s]), ltDebug);
  if (path<>'') then
  begin
    if(Pos(LowerCase(BaseDir + 'FileZillaFTP\' + Config.BinaryNames.FileZilla), LowerCase(path))<>0) then
      AddLog(Format(_('Service Path: %s'), [path]), ltDebug)
    else
    begin
      pStatus.Color := cErrorColor;
      AddLog(_('FileZilla Service detected with wrong path'), ltError);
      AddLog(_('Change XAMPP FileZilla settings or'), ltError);
      AddLog(_('Uninstall/disable the other service manually first'), ltError);
      AddLog(Format(_('Found Path: %s'), [Path]), ltError);
      AddLog(Format(_('Expected Path: "%sFileZillaFTP\%s"'), [basedir, Config.BinaryNames.FileZilla]), ltError);
    end
  end
  else
    AddLog(_('Service Path: Service Not Installed'), ltDebug);
end;

constructor tFileZilla.Create;
var
  PortBlocker: string;
  ServerApp, ServerAppBackup: string;
  Ports: array [0 .. 1] of integer;
  p: integer;
  path: string;
begin
  inherited;
  ModuleName := cModuleName;
  isService := false;
  GlobalStatus := 'starting';
  AddLog(_('Initializing module...'), ltDebug);
  ServerApp := BaseDir + 'FileZillaFTP\' + Config.BinaryNames.FileZilla;
  ServerAppBackup := BaseDir + 'FileZillaFTP\FileZilla server.exe';
  Ports[0] := Config.ServicePorts.FileZilla;
  Ports[1] := Config.ServicePorts.FileZillaAdmin;
  AddLog(_('Checking for module existence...'), ltDebug);
  if not FileExists(ServerApp) then
  begin
    AddLog(_('Checking for alternate module existence...'), ltDebug);
    if not FileExists(ServerAppBackup) then
    begin
      pStatus.Color := cErrorColor;
      AddLog(_('Problem detected: FileZilla Not Found!'), ltError);
      AddLog(_('Disabling FileZilla buttons'), ltError);
      AddLog(_('Run this program from your XAMPP root directory!'), ltError);
      bAdmin.Enabled := False;
      bbService.Enabled := False;
      bStartStop.Enabled := False;
    end
    else
      ServerApp := ServerAppBackup;
  end;

  if not Config.EnableServices.FileZilla then
  begin
    AddLog(_('Apache Service is disabled.'), ltDebug);
    fmain.bFileZillaService.Enabled := false;
  end;

  AddLog(_('Checking for required tools...'), ltDebug);

  CheckIsService;
  path:=GetServicePath(RemoveWhiteSpace(Config.ServiceNames.FileZilla));

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
          AddLog(Format(_('XAMPP FileZilla FTP Server is already running on port %d'), [Ports[p]]), ltInfo);
        end
        else if (pos(LowerCase(PortBlocker), LowerCase(path))<>0) and (isService = True) then
        begin
          AddLog(Format(_('XAMPP FileZilla FTP Server Service is already running on port %d'), [Ports[p]]), ltInfo);
        end
        else
        begin
          pStatus.Color := cErrorColor;
          AddLog(_('Problem detected!'), ltError);
          AddLog(Format(_('Port %d in use by "%s"!'), [Ports[p], PortBlocker]), ltError);
          AddLog(_('FileZilla WILL NOT start without the configured ports free!'), ltError);
          AddLog(_('You need to uninstall/disable/reconfigure the blocking application'), ltError);
          AddLog(_('or reconfigure FileZilla to listen on a different port'), ltError);
        end;
      end;
    end;
  end;
end;

destructor tFileZilla.Destroy;
begin
  inherited;
end;

procedure tFileZilla.ServiceInstall;
var
  App, Param1, Param2, Param3: string;
  RC: integer;
begin
  App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZilla;
  Param1 := '-install auto';
  Param2 := '-servicename ' + RemoveWhiteSpace(Config.ServiceNames.FileZilla);
  Param3 := '-servicedisplayname ' + Config.ServiceNames.FileZilla;
  AddLog(_('Setting Service Name...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param2]), ltDebug);
  ExecuteFile(App, Param2, basedir, SW_HIDE);
  //RunAsAdmin(App, Param2, SW_HIDE);
  AddLog(_('Setting Service Display Name...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param3]), ltDebug);
  ExecuteFile(App, Param3, basedir, SW_HIDE);
  //RunAsAdmin(App, Param3, SW_HIDE);
  AddLog(_('Installing service...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param1]), ltDebug);
  RC := RunAsAdmin(App, Param1, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tFileZilla.ServiceUnInstall;
var
  App, Param: string;
  RC: Cardinal;
begin
  App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZilla;
  Param := '-uninstall';
  AddLog('Uninstalling service...');
  AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tFileZilla.Start;
var
  App: string; //, Param: string;
  RC: Cardinal;
begin
  GlobalStatus := 'starting';
  if isService then
  begin
    AddLog(Format(_('Attempting to start %s service...'), [cModuleName]));
    App := Format('start "%s"', [RemoveWhiteSpace(Config.ServiceNames.FileZilla)]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
  end
  else
  begin
    //App := BaseDir + 'filezillaftp\filezillaserver.exe';
    //Param := '-compat -start';
    App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZilla + ' -compat -start';
    AddLog(Format(_('Attempting to start %s app...'), [cModuleName]));
    //AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
    AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
    //RC := RunAsAdmin(App, Param, SW_HIDE);
    RC := RunProcess(App, SW_HIDE, false);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
  end;
end;

procedure tFileZilla.Stop;
var
  App: string; //, Param: string;
  RC: Cardinal;
begin
  GlobalStatus := 'stopping';
  if isService then
  begin
    AddLog(Format(_('Attempting to stop %s service...'), [cModuleName]));
    App := Format('stop "%s"', [RemoveWhiteSpace(Config.ServiceNames.FileZilla)]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
  end
  else
  begin
    //App := BaseDir + 'filezillaftp\filezillaserver.exe';
    //Param := '-compat -stop';
    App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZilla + ' -compat -stop';
    AddLog(Format(_('Attempting to stop %s app...'), [cModuleName]));
    //AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
    AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
    //RC := RunAsAdmin(App, Param, SW_HIDE);
    RC := RunProcess(App, SW_HIDE, false);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
  end;
end;

procedure tFileZilla.UpdateStatus;
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
    if (pos(Config.BinaryNames.FileZilla, ProcInfo.Module) = 1) then
    begin
      if (pos(IntToStr(Config.ServicePorts.FileZilla),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
      (pos(IntToStr(Config.ServicePorts.FileZillaAdmin),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
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
   // begin
   //   if s = '' then
        s := RemoveDuplicatePorts(Ports);
   //   else
   //     s := s + ', ' + Ports;
   // end;
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
        AddLog(_('Error: FileZilla shutdown unexpectedly.'), ltError);
        AddLog(_('This may be due to a blocked port, missing dependencies, '), ltError);
        AddLog(_('improper privileges, a crash, or a shutdown by another method.'), ltError)
      end;
    end;

    oldIsRunningByte := byte(isRunning);
    if isRunning then
    begin
      pStatus.Color := cRunningColor;
      bStartStop.Caption := _('Stop');
      bAdmin.Enabled := true;
      fMain.FileZillaTray.ImageIndex := 15;
      fMain.FileZillaTrayControl.Caption := _('Stop');
    end
    else
    begin
      pStatus.Color := cStoppedColor;
      bStartStop.Caption := _('Start');
      bAdmin.Enabled := false;
      fMain.FileZillaTray.ImageIndex := 16;
      fMain.FileZillaTrayControl.Caption := _('Start');
    end;
  end;

  if AutoStart then
  begin
    AutoStart := false;
    if isRunning then
    begin
      AddLog(_('Autostart aborted: FileZilla is already running'), ltInfo);
    end
    else
    begin
      AddLog(_('Autostart active: starting...'));
      Start;
    end;
  end;
end;

end.
