unit uThrPing;

interface

uses
  System.Classes, System.SysUtils, Winapi.ActiveX, System.Win.ComObj, System.Variants,
  System.Types, System.TypInfo, System.StrUtils, Winapi.Windows, Winapi.WinSock,
  System.RegularExpressions;

type
  TThrPing = class(TThread)
  protected
    _Inicio, _Fim: Integer;
    procedure Execute; override;
  public
    _Posicao: Integer;
    lstIPs: TStringList;
    constructor Create(AInicio, AFim: Integer);
    procedure PingStatusInfo;
  end;

implementation

uses
  uMain;

constructor TThrPing.Create(AInicio, AFim: Integer);
var
  TD: PTypeData;
begin
  inherited Create(False);
  // CTRL + ALT + T pra verificar a thread na lista
  TD := GetTypeData(Self.ClassInfo);
  if TD <> nil then
    Self.NameThreadForDebugging(Format('%s%d', [TD^.UnitName, Self.Handle]));

  lstIPs := TStringList.Create;
  _Inicio := AInicio;
  _Fim := AFim;
  FreeOnTerminate := True;
end;

function Explode(Texto, Separador: string): TStringDynArray;
var
  Src, Dest: Integer;
begin
  Result := SplitString(Texto, Separador);
  if Length(Result) <> 0 then
  begin
    Dest := 0;
    for Src := 0 to High(Result) do
      if Result[Src] <> '' then
      begin
        if Src <> Dest then
          Result[Dest] := Result[Src];
        Inc(Dest);
      end;
    SetLength(Result, Dest);
  end;
end;

function IsWrongIP(ip: string): Boolean;
var
  ipRegExp: String;
begin
  Result := False;
  try
    ipRegExp := '\b(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\b';
    if TRegEx.IsMatch(ip, ipRegExp) then
      Result := True;
  except
  end;
end;

procedure TThrPing.PingStatusInfo;
const
  WbemUser = '';
  WbemPassword = '';
  WbemComputer = 'localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;

  FWbemObject: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;
  TempIP2: String;
  I: Integer;
  ParcialIP: string;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);

  FWbemObjectSet := FWMIService.ExecQuery('SELECT IPAddress FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = "True"', 'WQL', wbemFlagForwardOnly);
  oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumvariant;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if not VarIsClear(FWbemObject.IPAddress) and not VarIsNull(FWbemObject.IPAddress) then
      for I := VarArrayLowBound(FWbemObject.IPAddress, 1) to VarArrayHighBound(FWbemObject.IPAddress, 1) do
        if IsWrongIP(String(FWbemObject.IPAddress[I])) then
          lstIPs.Add(String(FWbemObject.IPAddress[I]));
  end;
  for I := lstIPs.Count - 1 downto 0 do
  begin
    ParcialIP := Explode(lstIPs[I], '.')[0] + '.' + Explode(lstIPs[I], '.')[1] + '.' + Explode(lstIPs[I], '.')[2] + '.' + IntToStr(_Posicao);
    FWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM Win32_PingStatus where Address=' + QuotedStr(ParcialIP) + ' AND BufferSize=1 and Timeout=102', 'WQL',
      wbemFlagForwardOnly);
  end;
  FWbemObjectSet := Unassigned;
end;

procedure TThrPing.Execute;
begin
  _Posicao := _Inicio;

  while (not Terminated) do
  begin
    if (_Posicao >= _Fim) then
    begin
      lstIPs.Free;
      Terminate;
    end
    else
    begin
      try
        CoInitialize(nil);
        try
          PingStatusInfo;
        finally
          CoUninitialize;
        end;
      except
      end;
      Inc(_Posicao);
    end;
    Sleep(50);
  end;
end;

end.
