program Test_JSONObjectHelper_Demo;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {Form1},
  uJsonValueHelper in 'uJsonValueHelper.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
