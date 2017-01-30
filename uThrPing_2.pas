unit uThrPing;

interface

uses
  System.TypInfo, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms;

type
  TThrPing = class(TThread)
  protected
    _Form: TForm;
    _Inicio, _Fim: Integer;
    procedure Execute; override;
    procedure AtualizaTela;
  public
    _Posicao: Integer;
    constructor Create(CreateSuspended: Boolean; AForm: TForm; AInicio, AFim: Integer);
  end;

implementation

uses
  uMain;

constructor TThrPing.Create(CreateSuspended: Boolean; AForm: TForm; AInicio, AFim: Integer);
var
  TD: PTypeData;
begin
  inherited Create(True);
  // CTRL + ALT + T pra verificar a thread na lista
  TD := GetTypeData(Self.ClassInfo);
  if TD <> nil then
    Self.NameThreadForDebugging(Format('%s%d', [TD^.UnitName, Self.Handle]));

  inherited Create(CreateSuspended);
  _Form := AForm;
  _Inicio := AInicio;
  _Fim := AFim;
  FreeOnTerminate := True;
end;

procedure TThrPing.Execute;
var
  si: TStartupInfo;
  pi: TProcessInformation;
  dw1: dword;
begin
  _Posicao := _Inicio;
  ZeroMemory(@si, sizeOf(si));
  si.cb := sizeOf(si);
  while (not Terminated) do
  begin
    if (_Posicao >= _Fim) then
    begin
      Terminate;
    end
    else
    begin
      si.wShowWindow := SW_HIDE;
      si.dwFlags := STARTF_USESHOWWINDOW;
      if CreateProcess(nil, PChar('cmd.exe /C ping -n 1 -w 101 10.1.1.' + IntToStr(_Posicao)), nil, nil, True, 0, nil, nil, si, pi) then
      begin
        GetExitCodeProcess(pi.hProcess, dw1);
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess); // Never forget to close handles...
      end;
      Inc(_Posicao);
      // Synchronize(AtualizaTela);
    end;
    Sleep(102);
  end;
end;

function GetDosOutput(CommandLine: string; Work: string = 'C:\'): string;
var
  SA: TSecurityAttributes;
  si: TStartupInfo;
  pi: TProcessInformation;
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
    nLength := sizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with si do
    begin
      FillChar(si, sizeOf(si), 0);
      cb := sizeOf(si);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine), nil, nil, True, 0, nil, PChar(WorkDir), si, pi);
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
        WaitForSingleObject(pi.hProcess, INFINITE);
      finally
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
end;

procedure TThrPing.AtualizaTela;
var
  lForm1: TForm2;
begin
  lForm1 := _Form as TForm2;
  lForm1.Memo1.Lines.Add(GetDosOutput('ping -n 1 -w 100 10.1.1.' + IntToStr(_Posicao)));
end;

end.
