object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Rede Local'
  ClientHeight = 551
  ClientWidth = 749
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 248
    Top = 24
    Width = 243
    Height = 25
    Caption = 'Retorna todos os IPs e MACs'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 16
    Top = 63
    Width = 713
    Height = 266
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Memo2: TMemo
    Left = 16
    Top = 400
    Width = 713
    Height = 137
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
  object Button3: TButton
    Left = 248
    Top = 369
    Width = 243
    Height = 25
    Caption = 'Retorna Conex'#245'es Locais'
    TabOrder = 3
    OnClick = Button3Click
  end
end
