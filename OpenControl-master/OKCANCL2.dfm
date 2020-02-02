object OKRightDlg: TOKRightDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Dialog'
  ClientHeight = 111
  ClientWidth = 233
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 217
    Height = 65
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 114
    Height = 19
    Caption = #1054#1089#1085#1086#1074#1072#1090#1100' '#1073#1072#1079#1091'?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object OKBtn: TButton
    Left = 8
    Top = 79
    Width = 75
    Height = 25
    Caption = #1044#1072
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 150
    Top = 79
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1053#1077#1090
    ModalResult = 2
    TabOrder = 1
    OnClick = CancelBtnClick
  end
end
