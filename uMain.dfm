object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Rede Local'
  ClientHeight = 418
  ClientWidth = 746
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 746
    Height = 418
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 745
    ExplicitHeight = 481
    object aiARP: TActivityIndicator
      Left = 340
      Top = 335
      IndicatorSize = aisXLarge
    end
    object Memo1: TMemo
      Left = 16
      Top = 63
      Width = 713
      Height = 266
      TabOrder = 1
    end
    object Button1: TButton
      Left = 251
      Top = 24
      Width = 243
      Height = 25
      Caption = 'Retorna todos os IPs e MACs'
      TabOrder = 2
      OnClick = Button1Click
    end
  end
  object tmrARP: TTimer
    Enabled = False
    Interval = 20000
    OnTimer = tmrARPTimer
    Left = 608
    Top = 88
  end
end
