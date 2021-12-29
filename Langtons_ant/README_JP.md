# Langtons' Ant with V

pixel グラフィクスの習作として、Langtons' Ant (ラングトンのアリ)のコードを作成しました。

ref. ラングトンのアリ - Wikipedia
https://ja.wikipedia.org/wiki/%E3%83%A9%E3%83%B3%E3%82%B0%E3%83%88%E3%83%B3%E3%81%AE%E3%82%A2%E3%83%AA

##  lista-manifesto

- langton.v
  フツーの Langtons'  Antですだよ。いずれ、別のファイルを追加したいなぁ。

## nota V code

+ 色の定数
  gx module にはいくつかの色定数が定義されておりますが、Color構造体による定義なので、このままではグラフィクスバッファ配列 (u32の配列)の値としては利用できません。
  そこで、u32(gx.black.abgr8()) の様にして変換するというオソマツな事をしているのですだよ
+ ウィンドウを最大化すると、面白い
  これは偶然知ったのですが、実行中にウィンドウを最大化すると、グラフィクスもウィンドウサイズに合わせて拡大表示されるのですネ。地味に便利 ?



Revision historica : 

- 2021-12-29
  first appearance

