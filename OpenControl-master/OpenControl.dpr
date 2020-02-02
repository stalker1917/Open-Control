program OpenControl;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  OKCANCL2 in 'OKCANCL2.pas' {OKRightDlg},
  Finance in 'Finance.pas',
  ControlConsts in 'ControlConsts.pas',
  TimeManager in 'TimeManager.pas',
  AIManager in 'AIManager.pas',
  AreaManager in 'AreaManager.pas',
  OCGraph in 'OCGraph.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  //Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TOKRightDlg, OKRightDlg);
  Application.Run;
end.
