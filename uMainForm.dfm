object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 554
  ClientWidth = 923
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
    Left = 480
    Top = 28
    Width = 105
    Height = 33
    Caption = 'Create JSON'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 720
    Top = 28
    Width = 105
    Height = 33
    Caption = #20869#23384#27844#38706#27979#35797
    TabOrder = 1
    OnClick = Button2Click
  end
  object SpinEdit1: TSpinEdit
    Left = 609
    Top = 32
    Width = 89
    Height = 27
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Courier New'
    Font.Style = []
    MaxValue = 0
    MinValue = 0
    ParentFont = False
    TabOrder = 2
    Value = 50000
  end
  object Panel1: TPanel
    Left = 0
    Top = 104
    Width = 923
    Height = 450
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 3
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 432
      Height = 448
      Align = alLeft
      Color = clCream
      Font.Charset = ANSI_CHARSET
      Font.Color = clTeal
      Font.Height = -15
      Font.Name = 'Courier New'
      Font.Style = []
      Lines.Strings = (
        '{'
        '  "name": "'#24352#22823#39034'",'
        '  "age": 40,'
        '  "married": true,'
        '  "books": '
        '  ['
        '    "'#12298'Web'#24320#21457#20154#21592#21442#32771#22823#20840#12299'",'
        '    "'#12298'delphi'#28145#24230#23398#20064#12299'"'
        '  ],'
        '  "organization":'
        '  {'
        '      "oname": "'#22823#20013#21326#31185#25216'",'
        '      "oyear": 20'
        '  }'
        '}')
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
    end
    object Memo2: TMemo
      Left = 433
      Top = 1
      Width = 489
      Height = 448
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Courier New'
      Font.Style = []
      Lines.Strings = (
        '{'
        #9'"name": "'#24352#22823#39034'",'
        #9'"age": 40,'
        #9'"address": "'#21335#23665#21306#31185#25216#22253'",'
        #9'"married": true,'
        #9'"books": ['
        #9#9'"'#12298'Web'#24320#21457#20154#21592#21442#32771#22823#20840#12299'",'
        #9#9'"'#12298#38646#22522#30784#23398#20064'Python'#12299'",'
        #9#9'"'#12298'delphi'#28145#24230#23398#20064#12299'"'
        #9'],'
        #9'"organization": {'
        #9#9'"oname": "'#22823#20013#21326#31185#25216'",'
        #9#9'"oadd": "'#21335#23665#26234#22253'",'
        #9#9'"oyear": 20,'
        #9#9'"oposition": "'#24635#24037#31243#24072#21161#29702'"'
        #9'}'
        '}')
      ParentFont = False
      TabOrder = 1
    end
  end
  object Button4: TButton
    Left = 16
    Top = 8
    Width = 105
    Height = 33
    Caption = 'Create JSON'#65288'1'#65289
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 16
    Top = 47
    Width = 105
    Height = 33
    Caption = 'Create JSON'#65288'2'#65289
    TabOrder = 5
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 152
    Top = 8
    Width = 105
    Height = 33
    Caption = 'Parse JSON'
    TabOrder = 6
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 152
    Top = 47
    Width = 105
    Height = 33
    Caption = 'Delete JSON item'
    TabOrder = 7
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 296
    Top = 8
    Width = 105
    Height = 33
    Caption = 'JSON Array'#65288'1'#65289
    TabOrder = 8
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 296
    Top = 47
    Width = 105
    Height = 33
    Caption = 'JSON Array'#65288'2'#65289
    TabOrder = 9
    OnClick = Button9Click
  end
end
