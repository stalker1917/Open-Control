unit OKCANCL2;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TOKRightDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OKRightDlg: TOKRightDlg;
  OkResult : Boolean;

implementation

{$R *.dfm}

procedure TOKRightDlg.CancelBtnClick(Sender: TObject);
begin
  OkResult :=False;
  Close;
end;

procedure TOKRightDlg.OKBtnClick(Sender: TObject);
begin
  OkResult :=True;
  Close;
end;

end.
