program rede2;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form2},
  uThrPing in 'uThrPing.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.