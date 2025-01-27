# Shida_no_Ha.v

シダの葉グラフィクスの表示

Vでシダの葉グラフィクスを表示するコードを作成しました。

参考 : 反復関数系 - Wikipedia

https://ja.wikipedia.org/wiki/%E5%8F%8D%E5%BE%A9%E9%96%A2%E6%95%B0%E7%B3%BB

~~glfwを使った、~~新しいグラフィクス表示のお勉強の一環で作成しました。

~~september.plan によると、glfwの文字表示が国際対応になっているので、~~

- fix non-ascii rendering in gg (ä, å, etc)

ここでは、日本語で文字列を表示しています。

~~しかし、通常は同梱されている「RobotoMono-Regular.ttf」を利用するので、このままでは日本語は表示されません。~~
~~そこで、手元にダウンロードしておいた「源ノ角ゴシック (Source Han Sans JP Medium) フォント」をRobotoMono-Regular.ttfとリネームして使ってみました。~~
~~他の日本語フォントでも表示できると思います。​~~

~~Arch Linuxでは、標準の日本語フォントがないので、以下からダウンロードしたフォント「NotoSansCJKjp-Regular.otf」を利用しております。~~

~~noto-cjk/NotoSansCJKjp-Regular.otf~~ 
~~https://github.com/googlefonts/noto-cjk/blob/master/NotoSansCJKjp-Regular.otf~~

~~ユーザーサイドにフォントを導入すると、~/.local/share/fonts/ に導入されるので、Archではここを参照しております。~~

~~Ubuntuでは、標準でNotoフォントが利用できるので、/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc として参照しております。~~

~~他のOSの場合、ソースコードと同じディレクトリにあろう、次のフォントを参照するようにしております。~~

+ ~~'NotoSansCJKjp-Regular.otf' ,~~
+ ~~'DroidSerif-Regular.ttf',~~

~~「DroidSerif-Regular.ttf」には日本語が入っていないので、何も表示されません。あしからず。~~

これまでは、決め打ちでフォントpathを書いておりましたが、環境変数 VUI_FONT にフォントpathを設定しておくと、そのフォントファイルを使用する風に書き加えました。

revision histrica : 

2024-04-17 18:00:13 
どうにも居心地が悪いので、グラフィクスの方法を大幅に変更いたしました。

2023-09-21 03:05:42 
gg.draw_rect() が別のAPIとなっていたので、gg.draw_rect_filled() に置き換え。

2022-08-21 04:50:53 
os.font() が十分に良くなっているので、VUI_FONTを参照するだけに変更しました。

2021-04-25
フォントファイル指定方式を変更しています。まだ、着地点に至らず。

2021-01-06 03:13:01
v 0.2.1で、match文の中のelse節が空白にの場合には、else節が不要になったという変更があったので、軽微な修正を。

2020-07-11 04:25:08 
環境変数 VUI_FONT を調べ、空で無ければ、そのpathにあるフォントファイルを使用する風にしてみますた。

2020-06-09 18:59:25 
追記 : Vのグラフィクスの扱いが変更された事により、コードを大幅に変更しますた。

2020-05-16 03:56:20 
追記 : 静的グラフィクス表示にして、メモリ消費を抑える様にしました。

2019-10-18 20:10:51 
追記 : CのRAND_MAX が C.RAND_MAX として参照できるので、ソースを更新しました。

