# graph_plot.v

V で動く、陰関数のグラフを表示するプログラムですだよ。


## usage and dosage

`v -live graph_plot.v` でコンパイルすると、graph_plot というバイナリを生成します。
あとは、`graph_plot` を実行するだけ。

```
$ ./graph_plot
```

V の機能である Hot code reloading を使い、binaryの実行中に、描く関数式の書き換えが出来ます。
また、マウスホイールで、グラフの拡大/縮小が出来ます。マウスホイールをクルクル回して試してみてネ。


## inside code

実行中に、陰関数の設定部分を書き換えると、その変更が即座に反映されます。

「陰関数のグラフを描く」としておりますが、実際には、`abs(f(x, y)) < eps` となる点を表示しているので、 正確なグラフより、線が太くなる箇所が多いです。
陰関数部分に `eps` の値も指定できるようになっているので、適宜、変更して様子を見て下さい。

ブラッシュアップしておりません、小汚いコードの一例として下さい。

いじょ


## Revision historica

- 2025-05-27
  first appearance

