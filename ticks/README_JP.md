# ticks.v

日時文字列とUNIX epoch secondを相互変換する簡易ツールですだよ。

### usage and dosage

`v ticks.v` でコンパイル。

引数に、以下のどちらかを書いておくと、変換した結果などを出力します。

- 日時文字列
   '2023-09-01 11:59:00' の様に書きます
- UNIX epoch second
   1693569540  の様に書きます

例.
```
$ ./ticks '2023-09-01 11:59:00'
[1] : 2023-09-01 11:59:00 ... 1693569540
```


いじょう。

### Revision historica

- 2023-09-03
  first appearance

