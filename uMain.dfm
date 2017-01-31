object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Rede Local'
  ClientHeight = 467
  ClientWidth = 432
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
  object aiARP: TActivityIndicator
    Left = 184
    Top = 159
    IndicatorSize = aisXLarge
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 432
    Height = 467
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 745
    ExplicitHeight = 481
    object Label1: TLabel
      Left = 375
      Top = 431
      Width = 44
      Height = 13
      Alignment = taRightJustify
      Caption = '00:00:00'
    end
    object Label2: TLabel
      Left = 16
      Top = 64
      Width = 87
      Height = 13
      Caption = 'Filtrar por Coluna:'
    end
    object StringGrid2: TStringGrid
      Left = 17
      Top = 87
      Width = 402
      Height = 338
      ColCount = 4
      DefaultColWidth = 110
      FixedCols = 0
      RowCount = 2
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
      TabOrder = 5
      Visible = False
      OnClick = StringGrid1Click
      OnDrawCell = StringGrid1DrawCell
      RowHeights = (
        24
        24)
    end
    object Memo1: TMemo
      Left = 40
      Top = 87
      Width = 318
      Height = 266
      TabOrder = 0
      Visible = False
    end
    object Button1: TButton
      Left = 121
      Top = 24
      Width = 194
      Height = 25
      Caption = 'Retorna todos os IPs e MACs'
      TabOrder = 1
      OnClick = Button1Click
    end
    object stat1: TStatusBar
      Left = 1
      Top = 447
      Width = 430
      Height = 19
      Panels = <
        item
          Width = 340
        end>
      ExplicitLeft = 112
      ExplicitTop = 344
      ExplicitWidth = 0
    end
    object StringGrid1: TStringGrid
      Left = 17
      Top = 87
      Width = 402
      Height = 338
      ColCount = 4
      DefaultColWidth = 110
      FixedCols = 0
      RowCount = 2
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
      TabOrder = 3
      OnClick = StringGrid1Click
      OnDrawCell = StringGrid1DrawCell
      RowHeights = (
        24
        24)
    end
    object SearchBox1: TSearchBox
      Left = 109
      Top = 60
      Width = 310
      Height = 21
      TabOrder = 4
      OnInvokeSearch = SearchBox1InvokeSearch
    end
  end
  object tmrARP: TTimer
    Enabled = False
    Interval = 6000
    OnTimer = tmrARPTimer
    Left = 272
    Top = 256
  end
  object tmrCron: TTimer
    Enabled = False
    OnTimer = tmrCronTimer
    Left = 272
    Top = 328
  end
end
