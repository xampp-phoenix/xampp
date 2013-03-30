unit uTomcat;

interface

uses GnuGettext, uBaseModule, SysUtils, Classes, Windows, ExtCtrls, StdCtrls, Buttons, uNetstatTable, uTools, uProcesses, uServices;

type
  tTomcat = class(tBaseModule)
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

//var PID: integer;
uses uMain;

const cModuleName = 'Tomcat';

  { tTomcat }

procedure tTomcat.AddLog(Log: string; LogType: tLogType);
begin
  inherited AddLog(cModuleName, Log, LogType);
end;

procedure tTomcat.Admin;
var
  App, Param: string;
begin
  Param := 'http://localhost:' + IntToStr(Config.ServicePorts.TomcatHTTP) + '/';
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

procedure tTomcat.CheckIsService;
var
  s: string;
  path: string;
begin
  inherited CheckIsService(RemoveWhiteSpace(Config.ServiceNames.Tomcat));
  if isService then
  begin
    s := _('Service installed');
    path:=GetServicePath(RemoveWhiteSpace(Config.ServiceNames.Tomcat));
  end
  else
    s := _('Service not installed');
  AddLog(Format(_('Checking for service (name="%s"): %s'), [RemoveWhiteSpace(Config.ServiceNames.Tomcat), s]), ltDebug);
  if (path<>'') then
  begin
    if (Pos(LowerCase(basedir + 'tomcat\bin\' + Config.BinaryNames.Tomcat), LowerCase(path))<>0) then
      AddLog(Format(_('Service Path: %s'), [path]), ltDebug)
    else
    begin
      pStatus.Color := cErrorColor;
      AddLog(_('Tomcat Service detected with wrong path'), ltError);
      AddLog(_('Change XAMPP Tomcat settings or'), ltError);
      AddLog(_('Uninstall/disable the other service manually first'), ltError);
      AddLog(Format(_('Found Path: %s'), [Path]), ltError);
      AddLog(Format(_('Expected Path: %stomcat\bin\%s //RS//%s'), [basedir, Config.BinaryNames.Tomcat, Config.ServiceNames.Tomcat]), ltError);
    end
  end
  else
      AddLog(_('Service Path: Service Not Installed'), ltDebug);
end;

constructor tTomcat.Create(pbbService: TBitBtn; pStatusPanel: tPanel; pPIDLabel, pPortLabel: tLabel; pStartStopButton, pAdminButton: TBitBtn);
// const Ports:array[0..2] of integer=(1,2,3);
var
  PortBlocker: string;
  ServerApp: string;
  p: integer;
  ReqTools: array [0 .. 2] of string;
  Ports: array [0 .. 2] of integer;
  path: string;
begin
  inherited;
  ModuleName := cModuleName;
//  PID:=-1;
  GlobalStatus := 'running';
  Ports[0] := Config.ServicePorts.Tomcat;
  Ports[1] := Config.ServicePorts.TomcatHTTP;
  Ports[2] := Config.ServicePorts.TomcatAJP;
  AddLog(_('Initializing module...'), ltDebug);
  ServerApp := basedir + 'tomcat\bin\' + Config.BinaryNames.Tomcat;
  ReqTools[0] := basedir + 'catalina_start.bat';
  ReqTools[1] := basedir + 'catalina_stop.bat';
  ReqTools[2] := basedir + 'catalina_service.bat';
  AddLog(_('Checking for module existence...'), ltDebug);
  if (not FileExists(ServerApp)) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(_('Problem detected: Tomcat Not Found!'), ltError);
    AddLog(_('Disabling Tomcat buttons'), ltError);
    AddLog(_('Run this program from your XAMPP root directory!'), ltError);
    bAdmin.Enabled := False;
    bbService.Enabled := False;
    bStartStop.Enabled := False;
  end;

  if not Config.EnableServices.Tomcat then
  begin
    AddLog(_('Apache Service is disabled.'), ltDebug);
    fmain.bTomcatService.Enabled := false;
  end;

  AddLog(_('Checking for required tools...'), ltDebug);
  if not FileExists(ReqTools[0]) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(_('Problem detected: Required Tool catalina_start.bat Not Found!'), ltError);
  end;
  if not FileExists(ReqTools[1]) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(_('Problem detected: Required Tool catalina_stop.bat Not Found!'), ltError);
  end;
  if not FileExists(ReqTools[2]) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(_('Problem detected: Required Tool catalina_service.bat Not Found!'), ltError);
  end;

  CheckIsService;
  path:=GetServicePath(RemoveWhiteSpace(Config.ServiceNames.Tomcat));

  if Config.EnableChecks.CheckDefaultPorts then
  begin
    AddLog(_('Checking default ports...'), ltDebug);

    for p := Low(Ports) to High(Ports) do
    begin
      PortBlocker := NetStatTable.isPortInUse(Ports[p]);
      if (PortBlocker <> '') then
      begin
        //else if (LowerCase(PortBlocker) = LowerCase(ServerApp2)) then
        //if (LowerCase(PortBlocker) = LowerCase('java.exe')) or (LowerCase(PortBlocker) = LowerCase('javaw.exe')) then
        AddLog(Format(_('Portblocker Detected: %s'), [PortBlocker]), ltDebug);
        AddLog(Format(_('Checking for App: %s'), [ServerApp]), ltDebug);
        if isservice then
          AddLog(Format(_('Checking for Service: %s'), [path]), ltDebug);
        if (pos(LowerCase('java.exe'), LowerCase(PortBlocker))<>0) or (pos(LowerCase('javaw.exe'), LowerCase(PortBlocker))<>0) then
        begin
          AddLog(Format(_('Java is already running on port %d!'), [Ports[p]]), ltInfo);
          AddLog(_('Is Tomcat already running?'), ltInfo);
        end
        else if (pos(LowerCase(ServerApp), LowerCase(PortBlocker))<>0) then
        begin
          AddLog(Format(_('XAMPP Tomcat is already running on port %d'), [Ports[p]]), ltInfo);
        end
        else if (pos(LowerCase(PortBlocker), LowerCase(path))<>0) and (isService = True) then
        begin
          AddLog(Format(_('XAMPP Tomcat Service is already running on port %d'), [Ports[p]]), ltInfo);
        end
        else
        begin
          pStatus.Color := cErrorColor;
          AddLog(_('Problem detected!'), ltError);
          AddLog(Format(_('Port %d in use by "%s"!'), [Ports[p], PortBlocker]), ltError);
          AddLog(_('Tomcat WILL NOT start without the configured ports free!'), ltError);
          AddLog(_('You need to uninstall/disable/reconfigure the blocking application'), ltError);
          AddLog(_('or reconfigure Tomcat to listen on a different port'), ltError);
        end;
      end;
    end;
  end;
end;

destructor tTomcat.Destroy;
begin
  inherited;
end;

procedure tTomcat.ServiceInstall;
var
  App, Param: string;
  RC: integer;
begin
  Param := '/c "' + basedir + 'catalina_service.bat" install ' + Config.ServiceNames.Tomcat;
  if FileExists('c:\Windows\sysnative\cmd.exe') then
    App := 'c:\Windows\sysnative\cmd.exe'
  else
    App := 'cmd';
  AddLog(_('Installing service...'));
  AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
  //RC:=ShellExecute_AndWait('open', App, Param, '', SW_HIDE, true);
  RC:=RunAsAdmin(App, Param, SW_HIDE);
  AddLog(Format(_('Return code: %d'), [RC]), ltDebug);
  if(RC<>0) then
  begin
    AddLog(Format(_('Tomcat Service Install stopped with errors, return code: %d'), [RC]), ltError);
    AddLog(_('Make sure you have Java JDK or JRE installed and the required ports are free'), ltError);
    AddLog(_('Check the "/xampp/tomcat/logs" folder for more information'), ltError);
  end;
end;

procedure tTomcat.ServiceUnInstall;
var
  App, Param: string;
  RC: integer;
begin
  Param := '/c "' + basedir + 'catalina_service.bat" remove ' + Config.ServiceNames.Tomcat;
  if FileExists('c:\Windows\sysnative\cmd.exe') then
    App := 'c:\Windows\sysnative\cmd.exe'
  else
    App := 'cmd';
  AddLog(_('Uninstalling service...'));
  AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
  //RC:=ShellExecute_AndWait('open', App, Param, '', SW_HIDE, true);
  RC:=RunAsAdmin(App, Param, SW_HIDE);
  AddLog(Format(_('Return code: %d'), [RC]), ltDebug);
  if(RC<>0) then
  begin
    AddLog(Format(_('Tomcat Service Uninstall stopped with errors, return code: %d'), [RC]), ltError);
    AddLog(_('Make sure you have Java JDK or JRE installed and the required ports are free'), ltError);
    AddLog(_('Check the "/xampp/tomcat/logs" folder for more information'), ltError);
  end;
end;

procedure tTomcat.Start;
var
  App, Param: string;
  RC: integer;
begin
  GlobalStatus := 'starting';
  if isService then
  begin
    AddLog(Format(_('Attempting to start %s service...'), [cModuleName]));
    App := Format('start "%s"', [RemoveWhiteSpace(Config.ServiceNames.Tomcat)]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      //ErrMsg := SysUtils.SysErrorMessage(System.GetLastError);
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
    end;
  end
  else
  begin
    AddLog(Format(_('Attempting to start %s app...'), [cModuleName]));
    Param := '/c "' + basedir + 'catalina_start.bat"';
    if FileExists('c:\Windows\sysnative\cmd.exe') then
      App := 'c:\Windows\sysnative\cmd.exe' // 64 bit? dann DIESE shell starten!
    else
      App := 'cmd';
    AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
    if Config.TomcatVisible then
      RC:=ShellExecute_AndWait('open', App, Param, '', SW_MINIMIZE, true)
    else
      RC:=ShellExecute_AndWait('open', App, Param, '', SW_HIDE, true);
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug);
      if(RC<>0) then
      begin
        AddLog(Format(_('Tomcat Started/Stopped with errors, return code: %d'), [RC]), ltError);
        AddLog(_('Make sure you have Java JDK or JRE installed and the required ports are free'), ltError);
        AddLog(_('Check the "/xampp/tomcat/logs" folder for more information'), ltError);
      end;
  end;
end;

procedure tTomcat.Stop;
var
  App, Param: string;
  RC: Cardinal;
begin
  GlobalStatus := 'stopping';
  if isService then
  begin
    AddLog(Format(_('Attempting to stop %s service...'), [cModuleName]));
    App := Format('stop "%s"', [RemoveWhiteSpace(Config.ServiceNames.Tomcat)]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      //ErrMsg := SysUtils.SysErrorMessage(System.GetLastError);
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
    end;
  end
  else
  begin
    AddLog(Format(_('Attempting to stop %s'), [cModuleName]));
    Param := '/c "' + basedir + 'catalina_stop.bat"';
    if FileExists('c:\Windows\sysnative\cmd.exe') then
      App := 'c:\Windows\sysnative\cmd.exe' // 64 bit? dann DIESE shell starten!
    else
      App := 'cmd';
    AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
    ExecuteFile(App, Param, basedir, SW_HIDE);
  end;
end;

procedure tTomcat.UpdateStatus;
var
  p: integer;
  ProcInfo: TProcInfo;
  s: string;
  Ports: string;
  ErrorStatus: integer;
//  PIDFile: TextFile;
//  PIDtmp: string;
//  PIDtmp2: integer;
begin
  isRunning := false;
  PIDList.Clear;
  ErrorStatus := 0;
//  PIDtmp2:=-1;

  // Check PID File
//  if PID = -1 then
//  begin
//    if FileExists(basedir + 'tomcat\logs\catalina.pid') then
//    begin
//      AssignFile(PIDFile, basedir + 'tomcat\logs\catalina.pid');
//      Reset(PIDFile);
//      ReadLn(PIDFile, PIDtmp);
//      CloseFile(PIDFile);
//    end;
//    if PIDtmp <> '' then
//    begin
//      PIDtmp2:=StrToInt(Trim(PIDtmp));
//    end;
//  end;

  // Scan Process List
  for p := 0 to Processes.ProcessList.Count - 1 do
  begin
    ProcInfo := Processes.ProcessList[p];
    if (pos('java.exe', ProcInfo.Module) = 1) or (pos(Config.BinaryNames.Tomcat, ProcInfo.Module) = 1) then
    begin
      //if NetStatTable.GetPortCount4PID(ProcInfo.PID) = 3 then
//      AddLog(Format(_('Tomcat Port: %s'), [IntToStr(Config.ServicePorts.Tomcat)]), ltDebug);
//      AddLog(Format(_('PID Ports: %s'), [NetStatTable.GetPorts4PID(ProcInfo.PID)]), ltDebug);
      if (pos(IntToStr(Config.ServicePorts.TomcatHTTP), NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) then
      begin
        isRunning := true;
        PIDList.Add(Pointer(ProcInfo.PID));
      end;
    end;
//    if (ProcInfo.PID = PIDtmp2) or (ProcInfo.PID = PID) then
//    begin
//      isRunning := true;
//      PID:=ProcInfo.PID;
//      PIDList.Add(Pointer(ProcInfo.PID));
//    end;
  end;

  // Update GUI PID List
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

  // Update GUI Ports List
  s := '';
  for p := 0 to PIDList.Count - 1 do
  begin
    Ports := NetStatTable.GetPorts4PID(integer(PIDList[p]));
    if Ports <> '' then
   // begin
   //  if s = '' then
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

  // Change Status
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
        AddLog(_('Error: Tomcat shutdown unexpectedly.'), ltError);
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
      fMain.TomcatTray.ImageIndex := 15;
      fMain.TomcatTrayControl.Caption := _('Stop');
    end
    else
    begin
      pStatus.Color := cStoppedColor;
      bStartStop.Caption := _('Start');
      bAdmin.Enabled := false;
      fMain.TomcatTray.ImageIndex := 16;
      fMain.TomcatTrayControl.Caption := _('Start');
//      PID := -1;
    end;
  end;

  if AutoStart then
  begin
    AutoStart := false;
    if isRunning then
    begin
      AddLog(_('Autostart aborted: Tomcat is already running'), ltInfo);
    end
    else
    begin
      AddLog(_('Autostart active: starting...'));
      Start;
    end;
  end;
end;

end.
