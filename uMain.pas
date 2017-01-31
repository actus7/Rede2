unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uThrPing, Vcl.ExtCtrls, WinSock,
  Winapi.ShellApi, Vcl.WinXCtrls, Vcl.ComCtrls, Vcl.Grids, UxTheme, Math;

type
  TForm2 = class(TForm)
    tmrARP: TTimer;
    Panel1: TPanel;
    aiARP: TActivityIndicator;
    Memo1: TMemo;
    Button1: TButton;
    tmrCron: TTimer;
    Label1: TLabel;
    stat1: TStatusBar;
    StringGrid1: TStringGrid;
    SearchBox1: TSearchBox;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure tmrARPTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrCronTimer(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure StringGrid1Click(Sender: TObject);
    procedure SearchBox1InvokeSearch(Sender: TObject);
  private
    { Private declarations }
    ThrPing: TThrPing;
    ListaThreads: TList;
    fThreads: Integer;
    TimeOld: TDateTime;
    INICIO: TDateTime;
    procedure AdicionaThread(Item: TThread);
    procedure SetFilter(ACol: Integer; Exp: String);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  FilterList: TStringList;

implementation

{$R *.dfm}

function GetDosOutput(CommandLine: string; Work: string = 'C:\'): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: boolean;
  Buffer: array [0 .. 255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: boolean;
begin
  Result := '';
  with SA do
  begin
    nLength := SizeOf(SA);
    bInheritHandle := true;
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
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine), nil, nil, true, 0, nil, PChar(WorkDir), SI, PI);
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
  aiARP.Visible := true;
  aiARP.Animate := true;
  aiARP.BringToFront;
  Label1.Caption := '00:00:00';
  INICIO := StrToDateTime(Label1.Caption);
  TimeOld := Now;
  tmrCron.Enabled := true;

  Panel1.Enabled := false;
  ShellExecute(Handle, 'open', PChar('cmd.exe'), PWideChar('arp -d'), nil, SW_HIDE);

  stat1.Panels[0].Text := 'Disparando Pings';
  IJump := 1;
  Limite := 254;
  repeat
    if (IJump + 21) > Limite then
      AdicionaThread(TThrPing.Create(IJump, Limite))
    else
      AdicionaThread(TThrPing.Create(IJump, IJump + 19));
    IJump := IJump + 20;
  until (IJump >= Limite);

  stat1.Panels[0].Text := 'Adquirindo Lista de IPs e MACs';
  tmrARP.Enabled := true;
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
  ReportMemoryLeaksOnShutdown := true;
  aiARP.Visible := false;
  ListaThreads := TList.Create;

  StringGrid1.Cells[0, 0] := 'Endereço IP';
  StringGrid1.ColWidths[0] := 110;
  StringGrid1.Cells[1, 0] := 'Endereço MAC';
  StringGrid1.ColWidths[1] := 110;
  StringGrid1.Cells[2, 0] := 'Tipo';
  StringGrid1.ColWidths[2] := 80;
  StringGrid1.Cells[3, 0] := 'Ativar';
  StringGrid1.ColWidths[3] := 50;
end;

function IsCellSelected(StringGrid: TStringGrid; X, Y: Longint): boolean;
begin
  Result := false;
  try
    if (X >= StringGrid.Selection.Left) and (X <= StringGrid.Selection.Right) and (Y >= StringGrid.Selection.Top) and (Y <= StringGrid.Selection.Bottom) then
      Result := true;
  except
  end;
end;

procedure TForm2.SetFilter(ACol: Integer; Exp: String);
var
  I, Counter: Integer;
begin
  FilterList := TStringList.Create;
  With StringGrid1 do
  begin
    For I := FixedRows To RowCount - 1 Do
      FilterList.Add(Rows[I].Text);

    Counter := FixedRows;
    For I := FixedRows To RowCount - 1 Do
    Begin
      if not (pos(Exp, Cells[ACol, I]) > 0) then
      Begin
        Rows[I].Clear;
      end
      Else
      begin
        If Counter <> I Then
        Begin
          Rows[Counter].Assign(Rows[I]);
          Rows[I].Clear;
        End;
        Inc(Counter);
      End;
    End;
    RowCount := Counter;
  End;
end;

procedure TForm2.SearchBox1InvokeSearch(Sender: TObject);
begin
  SetFilter(StringGrid1.Col, SearchBox1.Text);
end;

procedure TForm2.StringGrid1Click(Sender: TObject);
begin
  if IsCellSelected(StringGrid1, 3, StringGrid1.Row) then
  begin
    if (StringGrid1.Cells[3, StringGrid1.Row] = '') then
      (StringGrid1.Cells[3, StringGrid1.Row] := 'OK')
    else
      (StringGrid1.Cells[3, StringGrid1.Row] := '');
  end;
end;

procedure TForm2.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
const
  PADDING = 4;
var
  h: HTHEME;
  s: TSize;
  r: TRect;
begin
  if (ACol = 3) and (ARow >= 1) then
  begin
    FillRect(StringGrid1.Canvas.Handle, Rect, GetStockObject(WHITE_BRUSH));
    s.cx := GetSystemMetrics(SM_CXMENUCHECK);
    s.cy := GetSystemMetrics(SM_CYMENUCHECK);
    if UseThemes then
    begin
      h := OpenThemeData(StringGrid1.Handle, 'BUTTON');
      if h <> 0 then
        try
          GetThemePartSize(h, StringGrid1.Canvas.Handle, BP_CHECKBOX, CBS_CHECKEDNORMAL, nil, TS_DRAW, s);
          r.Top := Rect.Top + (Rect.Bottom - Rect.Top - s.cy) div 2;
          r.Bottom := r.Top + s.cy;
          r.Left := Rect.Left + PADDING;
          r.Right := r.Left + s.cx;
          if (StringGrid1.Cells[ACol, ARow] = 'OK') then
            DrawThemeBackground(h, StringGrid1.Canvas.Handle, BP_CHECKBOX, CBS_CHECKEDNORMAL, r, nil)
          else
            DrawThemeBackground(h, StringGrid1.Canvas.Handle, BP_CHECKBOX, CBS_UNCHECKEDNORMAL, r, nil)
        finally
          CloseThemeData(h);
        end;
    end
    else
    begin
      r.Top := Rect.Top + (Rect.Bottom - Rect.Top - s.cy) div 2;
      r.Bottom := r.Top + s.cy;
      r.Left := Rect.Left + PADDING;
      r.Right := r.Left + s.cx;

      if (StringGrid1.Cells[ACol, ARow] = 'OK') then
        DrawFrameControl(StringGrid1.Canvas.Handle, r, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_CHECKED)
      else
        DrawFrameControl(StringGrid1.Canvas.Handle, r, DFC_BUTTON, DFCS_BUTTONCHECK);
    end;
    r := System.Classes.Rect(r.Right + PADDING, Rect.Top, Rect.Right, Rect.Bottom);
  end;
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
    aiARP.Animate := false;
    aiARP.Visible := false;
    Panel1.Enabled := true;
    tmrCron.Enabled := false;
    tmrARP.Enabled := false;

    stat1.Panels[0].Text := 'Operação Concluída.';

    StringGrid1.RowCount := Memo1.Lines.Count;
    Memo1.Lines.Delete(0);
    Memo1.Lines.Delete(0);

    Memo1.Text := StringReplace(Memo1.Text, '     ', '|', [rfReplaceAll, rfIgnoreCase]);
    Memo1.Text := StringReplace(Memo1.Text, '||', '|', [rfReplaceAll, rfIgnoreCase]);
    Memo1.Text := StringReplace(Memo1.Text, ' ', '', [rfReplaceAll, rfIgnoreCase]);
    Memo1.Text := StringReplace(Memo1.Text, 'ƒ', 'â', [rfReplaceAll, rfIgnoreCase]);

    for I := 1 to Memo1.Lines.Count - 1 do
      StringGrid1.Rows[I].Text := StringReplace(Memo1.Lines[I], '|', #10, [rfReplaceAll]);
  end;
end;

procedure TForm2.tmrCronTimer(Sender: TObject);
begin
  Label1.Caption := 'Tempo do Processo: ' + FormatDateTime('HH:MM:SS', INICIO + Now - TimeOld);
end;

end.
