# simple_liner_regression_2.v

Vのexamplesにある、simple_liner_regression.v を改変してみました。

データファイル「data.dat」を読み込むようにしております。

データの読み込みの練習として作成しました。

いずれは、グラフを描く機能を付け足したいものです。

## usage and dosage

データファイル「data.dat」を同じディレクトリに置いて、

```
v run simple_liner_regression.v
```

もしくは、

```
v simple_liner_regression.v ; ./simple_liner_regression
```

として頂戴 !

修正履歴

2021-02-07  メッセージを一部修正

2021-08-01 split_by_whitespace() メソッドが使えなくなっていたので、苦し紛れの変更

