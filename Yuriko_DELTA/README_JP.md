Yuriko_DELTA.v
==============

東京都のコロナウィルス感染集計情報からデータを取得するプログラムです。

東京都のコロナウィルス感染集計情報は、以下のgithub にあります。

ref. https://github.com/tokyo-metropolitan-gov/covid19/tree/development/data

ここから、一部データを取得して、データファイルにするプログラムと、

このデータファイルを最小二乗法によってロジスティック回帰分析するプログラムの2本立てです。

## usage and dosage

+  Yuriko_DELTA.v 

東京都の変異株集計情報から、週ごとの変異株の割合をデータ出力するプログラムです。

```
v run Yuriko_DELTA.v 
```

と実行すると、variant.dat というデータファイルを作ります。

+ logistic_regression.v 

データファイル variant.dat を読み込み、最小二乗法によってロジスティック回帰分析を行うプロイラムです。
ベースとなっているのは、Vのサンプルにある simple_liner_regression.v です。

```
v run logistic_regression.v
```

とやって実行すると、gnuplot 用のスクリプトファイル script.gp を作り出します。
gnuplot を実行して、 load "script.gp" と入力すると、スクリプトファイルが実行され、グラフを描きます。

