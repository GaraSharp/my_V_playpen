# Shida_no_Ha.v

シダの葉グラフィクスの表示

Vでシダの葉グラフィクスを表示するコードを作成しました。

参考 : 反復関数系 - Wikipedia

https://ja.wikipedia.org/wiki/%E5%8F%8D%E5%BE%A9%E9%96%A2%E6%95%B0%E7%B3%BB

glfwを使った、グラフィクス表示のお勉強の一環で作成しました。

september.plan によると、glfwの文字表示が国際対応になっているので、

- fix non-ascii rendering in gg (ä, å, etc)

ここでは、日本語で文字列を表示しています。

~~しかし、通常は同梱されている「RobotoMono-Regular.ttf」を利用するので、このままでは日本語は表示されません。~~
~~そこで、手元にダウンロードしておいた「源ノ角ゴシック (Source Han Sans JP Medium) フォント」をRobotoMono-Regular.ttfとリネームして使ってみました。~~
~~他の日本語フォントでも表示できると思います。​~~

Arch Linuxでは、標準の日本語フォントがないので、以下からダウンロードしたフォント「NotoSansCJKjp-Regular.otf」を利用しております。

noto-cjk/NotoSansCJKjp-Regular.otf 
https://github.com/googlefonts/noto-cjk/blob/master/NotoSansCJKjp-Regular.otf

ユーザーサイドにフォントを導入すると、~/.local/share/fonts/ に導入されるので、Archではここを参照しております。

Ubuntuでは、標準でNotoフォントが利用できるので、/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc として参照しております。

他のOSの場合、ソースコードと同じディレクトリにあろう、次のフォントを参照するようにしております。

+ 'NotoSansCJKjp-Regular.otf' ,
+ 'DroidSerif-Regular.ttf',

「DroidSerif-Regular.ttf」には日本語が入っていないので、何も表示されません。あしからず。

2019-10-18 20:10:51 
追記 : CのRAND_MAX が C.RAND_MAX として参照できるので、ソースを更新しました。

