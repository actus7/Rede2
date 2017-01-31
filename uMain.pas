unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uThrPing, Vcl.ExtCtrls, WinSock,
  Vcl.WinXCtrls;

type
  TForm2 = class(TForm)
    tmrARP: TTimer;
    Panel1: TPanel;
    aiARP: TActivityIndicator;
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure tmrARPTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  Panel1.Enabled := False;
  aiARP.Visible := True;
  aiARP.Animate := True;
  Memo1.Lines.Add('Limpando Cache ARP');
  Memo1.Lines.Add(GetDosOutput('arp -d'));
  Memo1.Lines.Add('Disparando Pings');
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
  Memo1.Lines.Add('Adquerindo Lista de IPs e MACs');
  tmrARP.Enabled := True;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  aiARP.Visible := False;
end;

procedure TForm2.tmrARPTimer(Sender: TObject);
begin
  Memo1.Lines.Add(GetDosOutput('arp -a'));
  aiARP.Animate := False;
  aiARP.Visible := False;
  Panel1.Enabled := True;
  tmrARP.Enabled := False;
end;

end.
