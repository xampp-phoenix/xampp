unit uServices;

interface

uses
  GnuGettext, WinSvc, Windows, uTools, JclSvcCtrl, SysUtils;

type
  TServiceStatus = (ssError, ssNotFound, ssUnknown, ssRunning, ssStopped);
  TStartStopService = (ssStart, ssStop);

function GetServiceStatus(name: string): TServiceStatus;
function GetServicePath(name: string): string;
function StartService(name: string): Integer;
function StopService(name: string): Integer;
// function StartStopService(name: string; StartStopService: TStartStopService):boolean;

implementation

uses uMain;

function StartService(name: string): Integer;
var
  Manager: TJclSCManager;
  Service: TJclNTService;
begin
  fMain.AddLog('service', Format(_('Searching for service %s'), [name]), ltDebug);
  Manager := TJclSCManager.Create;
  Manager.Refresh(True);
  if Manager.FindService(name, Service) then
  begin
    fMain.AddLog('service', _('Found service, attempting to start'), ltDebug);
    Service.Start;
    Result := Service.Win32ExitCode;
  end
  else
    Result := -1;
  fMain.AddLog('service', Format(_('Return Code %d'), [Result]), ltDebug);
  Manager.Free;
end;

function StopService(name: string): Integer;
var
  Manager: TJclSCManager;
  Service: TJclNTService;
begin
  fMain.AddLog('service', Format(_('Searching for service %s'), [name]), ltDebug);
  Manager := TJclSCManager.Create;
  Manager.Refresh(True);
  if Manager.FindService(name, Service) then
  begin
    fMain.AddLog('service', _('Found service, attempting to stop'), ltDebug);
    Service.Stop;
    Result := Service.Win32ExitCode;
  end
  else
    Result := -1;
  fMain.AddLog('service', Format(_('Return Code %d'), [Result]), ltDebug);
  Manager.Free;
end;

function GetServicePath(name: string): string;
var
  hSCM: SC_Handle;
  hService: SC_Handle;
  ServiceConfig: WinSvc.LPQUERY_SERVICE_CONFIG;
  bytesneeded: DWord;
begin
   hSCM := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if (hSCM = 0) then
  begin
    result := 'ERROR: Not Able To Open Service Manager';
    exit;
  end;

  hService := OpenService(hSCM, PWideChar(name), SERVICE_QUERY_CONFIG);
  if (hService = 0) then
  begin
    CloseServiceHandle(hSCM);
    result := 'ERROR: Service Not Found';
    exit;
  end;

  if (QueryServiceConfig(hService, nil, 0, bytesneeded)=False) then
  begin
    GetMem(ServiceConfig, bytesneeded);
    if (QueryServiceConfig(hService, ServiceConfig, bytesneeded, bytesneeded)=False) then
    begin
      CloseServiceHandle(hService);
      CloseServiceHandle(hSCM);
      result:='ERROR: Could Not Get Service Config';
      FreeMem(ServiceConfig);
    end
    else
    begin
      CloseServiceHandle(hService);
      CloseServiceHandle(hSCM);
      result:=ServiceConfig.lpBinaryPathName;
      FreeMem(ServiceConfig);
    end;
  end;

  CloseServiceHandle(hService);
  CloseServiceHandle(hSCM);
end;

function GetServiceStatus(name: string): TServiceStatus;
var
  hSCM: THandle;
  hService: THandle;
  ServiceStatus: _SERVICE_STATUS;
begin
  hSCM := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if (hSCM = 0) then
  begin
    result := ssError;
    exit;
  end;

  hService := OpenService(hSCM, @name[1], SERVICE_QUERY_STATUS);;
  if (hService = 0) then
  begin
    CloseServiceHandle(hSCM);
    result := ssNotFound;
    exit;
  end;

  // The SERVICE exists and we have access

  if (QueryServiceStatus(hService, ServiceStatus)) then
  begin
    result := ssUnknown;
    if (ServiceStatus.dwCurrentState = SERVICE_RUNNING) then
      result := ssRunning;
    if (ServiceStatus.dwCurrentState = SERVICE_STOPPED) then
      result := ssStopped;
  end
  else
  begin
    result := ssError;
  end;

  CloseServiceHandle(hService);
  CloseServiceHandle(hSCM);
end;

function ServiceDelete(name: string): boolean;
var
  hSCM: THandle;
  hService: THandle;
begin
  result := false;
  hSCM := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if (hSCM = 0) then
    exit;

  hService := OpenService(hSCM, @name[1], SERVICE_QUERY_STATUS);;
  if (hService = 0) then
  begin
    CloseServiceHandle(hSCM);
    exit;
  end;
  // The SERVICE exists and we have access

  result := (DeleteService(hService));

  CloseServiceHandle(hService);
  CloseServiceHandle(hSCM);
end;

end.
