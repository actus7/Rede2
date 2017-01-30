unit uThrPing;

interface

uses
  System.Classes, System.SysUtils, Winapi.ActiveX, System.Win.ComObj, System.Variants,
  System.Types, System.TypInfo, System.StrUtils, Winapi.Windows, Winapi.WinSock;

type
  TThrPing = class(TThread)
  protected
    _Inicio, _Fim: Integer;
    procedure Execute; override;
  public
    _Posicao: Integer;
    lstIPs: TStringList;
    constructor Create(AInicio, AFim: Integer);
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

procedure PingStatusInfo(TempIP: String);
const
  WbemUser = '';
  WbemPassword = '';
  WbemComputer = 'localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM Win32_PingStatus where Address=' + QuotedStr(TempIP) + ' AND BufferSize=1 and Timeout=102', 'WQL',
    wbemFlagForwardOnly);
  FWbemObjectSet := Unassigned;
end;

procedure TThrPing.Execute;
Type
  PTA = array [0 .. 0] of Pointer;
  PTS = ^PTA;
Var
  phe: Thostent;
  pphe: PhostEnt;
  ac: String[255];
  i: Integer;
  wsaData: TWSAData;
  addr: TInaddr;

  ParcialIP: string;
begin
  _Posicao := _Inicio;

  FillChar(phe, sizeof(phe), 0);
  if WSAStartUp(MAKEWORD(1, 1), wsaData) <> 0 Then
  begin
    // Memo2.Lines.Add(' Failed to Start a socket');
    exit;
  end;
  if GetHostName(@ac[1], 254) = SOCKET_ERROR Then
  begin
    // Memo2.Lines.Add(IntTOStr(WSAGetLastError) + ': Error when getting local Host ');
    WSACleanup;
    exit;
  end;
  i := 1;
  while (ac[1] <> #0) and (i < 255) do
    Inc(i);
  ac[0] := AnsiChar(i - 1);
  // Memo2.Lines.Add('Host Name :' + ac);
  pphe := GetHostByName(@ac[1]);
  phe := pphe^;
  i := 0;
  while PTS(phe.h_addr_list)^[i] <> nil do
  begin
    copymemory(@addr, PTS(phe.h_addr_list)^[i], sizeof(TInaddr));
    // Memo2.Lines.Add('Address: ' + inet_ntoa(addr));
    lstIPs.Add(inet_ntoa(addr));
    Inc(i);
  end;
  WSACleanup;

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
          for i := lstIPs.Count - 1 downto 0 do
          begin
            ParcialIP := Explode(lstIPs[i], '.')[0] + '.' + Explode(lstIPs[i], '.')[1] + '.' + Explode(lstIPs[i], '.')[2] + '.' + IntToStr(_Posicao);
            PingStatusInfo(ParcialIP);
          end;
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
