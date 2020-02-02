object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 154
  ClientWidth = 147
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 40
    Top = 16
    Width = 75
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 40
    Top = 47
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 40
    Top = 78
    Width = 75
    Height = 25
    Caption = #1053#1072#1079#1072#1076' '#1074' '#1080#1075#1088#1091
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 40
    Top = 109
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 3
    OnClick = Button4Click
  end
  object OpenDialog1: TOpenDialog
    Left = 8
    Top = 16
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'sav'
    Left = 8
    Top = 64
  end
end
