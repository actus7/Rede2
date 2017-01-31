object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Rede Local'
  ClientHeight = 358
  ClientWidth = 349
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 349
    Height = 358
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 745
    ExplicitHeight = 481
    object Label1: TLabel
      Left = 290
      Top = 335
      Width = 44
      Height = 13
      Alignment = taRightJustify
      Caption = '00:00:00'
    end
    object Memo1: TMemo
      Left = 16
      Top = 63
      Width = 318
      Height = 266
      TabOrder = 0
      Visible = False
    end
    object Button1: TButton
      Left = 52
      Top = 24
      Width = 243
      Height = 25
      Caption = 'Retorna todos os IPs e MACs'
      TabOrder = 1
      OnClick = Button1Click
    end
    object ListBox1: TListBox
      Left = 13
      Top = 63
      Width = 321
      Height = 266
      ItemHeight = 13
      TabOrder = 2
    end
  end
  object aiARP: TActivityIndicator
    Left = 141
    Top = 159
    IndicatorSize = aisXLarge
  end
  object tmrARP: TTimer
    Enabled = False
    Interval = 6000
    OnTimer = tmrARPTimer
    Left = 280
    Top = 80
  end
  object tmrCron: TTimer
    Enabled = False
    OnTimer = tmrCronTimer
    Left = 280
    Top = 136
  end
end
