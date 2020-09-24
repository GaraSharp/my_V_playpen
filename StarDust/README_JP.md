# stardust.v

宇宙飛行っぽい表示をするプログラムだよん。

Star Trek: The Motion Picture - Ilia's Theme - Jerry Goldsmith - Youtube
https://www.youtube.com/watch?v=ZDM1R7NYKC0

とか聴きながら見ていると、雰囲気が出そう ?

### usage and dosage

`v run stardust.v` で実行できます。終了はESCキーか Q を押下。

### code inside note

最近の V では、gg.system_font_path()　を使ってフォントを取得、表示に使うらしく、このプログラムでも、gg.system_font_path() を使ってみました。

gg.system_font_path() では、

1. 最初に環境変数 VUI_FONT をみて、フォントへのパスが設定されていれば、そのフォントを使用します
2. VUI_FONTがなければ、os毎にフォント検索を行い、適当なフォントを使用する模様

以前の V では、true type collection (ttc) フォントも使用できたらしいのですが、今は ttcフォントが利用できない様で、gg.system_font_path() が取得するフォントは、truetype (ttf), opentype (otf) になっております。しかも、英語のフォントらしい。

日本語のttfフォントを使う場合には、VUI_FONTにフォントへのパスを記述して、実行する必要があります。

- Ubuntuなど、最近の日本語環境はttcフォントを利用する場合が多く、truetypeフォントはユーザが各自導入する必要があるかも知れません。ユーザーサイドに導入したフォントは、/home/user/.local/share/fonts/ のようなところに収蔵されているので、

  ```
  VUI_FONT=~/.local/share/fonts/ipaexg.ttf v run stardust.v
  ```

  の様にして実行できます。

- Mac で、OsakaMono.ttfがある場合には、

  ```
  VUI_FONT=`find /System/Library/Assets/ -name "OsakaMono.ttf"` v run stardust.v 
  ```

  とすれば良さそうです。


また、日本語表示をするには、VUI_FONT にて日本語フォントを指定しないとならないため、これを逆手にとり、VUI_FONT が存在した場合に、日本語表示する風にしてみました。

いじょう。

