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
    tmrCron: TTimer;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure tmrARPTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrCronTimer(Sender: TObject);
  private
    { Private declarations }
    ThrPing: TThrPing;
    ListaThreads: TList;
    fThreads: Integer;
    TimeOld: TDateTime;
    INICIO: TDateTime;
    procedure AdicionaThread(Item: TThread);
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

procedure TForm2.AdicionaThread(Item: TThread);
begin
  Inc(fThreads);
  ListaThreads.Add(Item);
  Item.Start;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  IJump: Integer;
  Limite: Integer;
begin
  INICIO := StrToDateTime(Label1.Caption);
  TimeOld := Now;
  tmrCron.Enabled := True;

  Panel1.Enabled := False;

  aiARP.Visible := True;
  aiARP.Animate := True;
  Memo1.Lines.Add('Limpando Cache ARP');
  Memo1.Lines.Add(GetDosOutput('arp -d'));
  Memo1.Lines.Add('Disparando Pings');

  IJump := 1;
  Limite := 254;
  repeat
    if (IJump + 21) > Limite then
    begin
      // Memo1.Lines.Add('TThrPing.Create = ' + IntToStr(IJump) + ' <-> ' + IntToStr(Limite));
      AdicionaThread(TThrPing.Create(IJump, Limite));
    end
    else
    begin
      // Memo1.Lines.Add('TThrPing.Create = ' + IntToStr(IJump) + ' <-> ' + IntToStr(IJump + 19));
      AdicionaThread(TThrPing.Create(IJump, IJump + 19));
    end;
    IJump := IJump + 20;
  until (IJump >= Limite);

  Memo1.Lines.Add('Adquirindo Lista de IPs e MACs');
  tmrARP.Enabled := True;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  while ListaThreads.Count > 0 do
  begin
    tmrARPTimer(Sender);
    Sleep(1000);
  end;
  ListaThreads.Free;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
  aiARP.Visible := False;
  ListaThreads := TList.Create;
end;

procedure TForm2.tmrARPTimer(Sender: TObject);
var
  I: Integer;
begin
  for I := ListaThreads.Count - 1 downto 0 do
  begin
    if TThrPing(ListaThreads[I]).FimThread then
    begin
      try
        TThrPing(ListaThreads[I]).Destroy;
      except
        TerminateThread(TThrPing(ListaThreads[I]).Handle, 0);
      end;
      ListaThreads.Delete(I);
      Dec(fThreads);
    end;
  end;
  if ListaThreads.Count = 0 then
  begin
    Memo1.Lines.Add(GetDosOutput('arp -a'));
    aiARP.Animate := False;
    aiARP.Visible := False;
    Panel1.Enabled := True;
    tmrCron.Enabled := False;
    tmrARP.Enabled := False;
  end;
end;

procedure TForm2.tmrCronTimer(Sender: TObject);
begin
  Label1.Caption := 'Tempo do Processo: ' + FormatDateTime('HH:MM:SS', INICIO + Now - TimeOld);
end;

end.
