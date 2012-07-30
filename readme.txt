■これは何？
  IEEE-754フォーマットの16進表記と浮動小数点表記の相互変換スクリプト

■使い方
  ・浮動小数点→IEEE-754フォーマット
    '.'を含んだ数値を入力。

    例)
      IEEE-754 format or Real number or 'q' : 2.3 [Enter]
      2.3 =>
      single:4013 3333           : 1000 4631 463
      double:4002 6666 6666 6666 : 1000 0463 146 _ 1463 1463 146

  ・IEEE-754フォーマット→浮動小数点
    16進表記の8桁 or 16桁の文字列を入力。

    例)
      IEEE-754 format or Real number or 'q' : 3fc00000 [Enter]
      1.5
      1.500000
      1.500000e+000

      IEEE-754 format or Real number or 'q' : 3ff8000000000000 [Enter]
      1.5
      1.500000
      1.500000e+000

      *)適当に空白を入れても可

      IEEE-754 format or Real number or 'q' : 3fc0 0000 [Enter]
      1.5
      1.500000
      1.500000e+000

  ・簡易計算機機能
    Perlの識別可能な数式を入力、末尾に'?'を付記。

      IEEE-754 format or Real number or 'q' : 1+3? [Enter]
      Dec_4  Hex_4  Oct_4
      4 =>
      single:4080 0000           : 1004 0000 000
      double:4010 0000 0000 0000 : 1000 4000 000 _ 0000 0000 000

      IEEE-754 format or Real number or 'q' : 0x3000+20? [Enter]
      Dec_12308  Hex_3014  Oct_30024
      12308 =>
      single:4640 5000           : 1062 0050 000
      double:40c8 0a00 0000 0000 : 1006 2005 000 _ 0000 0000 000

[EOF]
