object Form4: TForm4
  Left = 0
  Top = 0
  Caption = 'Form4'
  ClientHeight = 313
  ClientWidth = 504
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = Form4Create
  DesignSize = (
    504
    313)
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOpenIni: TButton
    Left = 24
    Top = 16
    Width = 168
    Height = 25
    Caption = 'Load Parameters from INI'
    TabOrder = 0
    OnClick = ButtonOpenIniClick
  end
  object StringGrid1: TStringGrid
    Left = 24
    Top = 56
    Width = 445
    Height = 194
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 3
    FixedCols = 0
    TabOrder = 1
    ColWidths = (
      108
      158
      154)
    RowHeights = (
      24
      24
      24
      24
      24)
  end
  object Button1: TButton
    Left = 24
    Top = 258
    Width = 192
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Add Parameters...'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 208
    Top = 16
    Width = 112
    Height = 25
    Caption = 'Edit Parameters'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 336
    Top = 16
    Width = 120
    Height = 25
    Caption = 'Reload parameters'
    TabOrder = 4
    OnClick = Button4Click
  end
  object RadioGroup1: TRadioGroup
    Left = 224
    Top = 256
    Width = 232
    Height = 49
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object RadioButtonSelectedComponents: TRadioButton
    Left = 232
    Top = 264
    Width = 216
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = '...to selected schematic components only'
    TabOrder = 6
  end
  object RadioButtonAllComponents: TRadioButton
    Left = 232
    Top = 288
    Width = 216
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = '...to all components in Project schematics'
    TabOrder = 7
  end
  object OpenIniDialog: TOpenDialog
    Left = 24
    Top = 8
  end
end
