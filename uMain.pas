unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uThrPing, Vcl.ExtCtrls, WinSock;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    ThrPing: TThrPing;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

function GetDosOutput(CommandLine: string; Work: string = 'C:\'): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array [0 .. 255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;
begin
  Result := '';
  with SA do
  begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine), nil, nil, True, 0, nil, PChar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            Result := Result + Buffer;
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Add(GetDosOutput('arp -d'));
  TThrPing.Create(1, 20);
  TThrPing.Create(21, 40);
  TThrPing.Create(41, 60);
  TThrPing.Create(61, 80);
  TThrPing.Create(81, 100);
  TThrPing.Create(101, 120);
  TThrPing.Create(121, 140);
  TThrPing.Create(141, 160);
  TThrPing.Create(161, 180);
  TThrPing.Create(181, 200);
  TThrPing.Create(201, 220);
  TThrPing.Create(221, 240);
  TThrPing.Create(241, 254);
  Sleep(10000);
  Memo1.Lines.Add(GetDosOutput('arp -a'));
end;

procedure TForm2.Button3Click(Sender: TObject);
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
begin
  Memo2.Clear;
  FillChar(phe, SizeOf(phe), 0);
  if WSAStartUp(MAKEWORD(1, 1), wsaData) <> 0 Then
  begin
    Memo2.Lines.Add(' Failed to Start a socket');
    exit;
  end;
  if GetHostName(@ac[1], 254) = SOCKET_ERROR Then
  begin
    Memo2.Lines.Add(IntTOStr(WSAGetLastError) + ': Error when getting local Host ');
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
    copymemory(@addr, PTS(phe.h_addr_list)^[i], SizeOf(TInaddr));
    Memo2.Lines.Add('Address: ' + inet_ntoa(addr));
    Inc(i);
  end;
  WSACleanup;
end;

end.
