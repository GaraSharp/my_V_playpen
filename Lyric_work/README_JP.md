# get_lyric.v

V で動く、歌詞を取得するプログラムですだよ。
Uta-Net.com から、歌詞などを取得するもので、Uta-Net.com 専用であります。

## usage and dosage

1. コンパイル

`v get_lyric.v` でコンパイルすると、get_lyric というバイナリを生成します。

2. 目的とする曲の歌詞があるか Uta-Net.com で調べ、アドレスを取っておきます。

例 ; 「レントゲン」(12.ヒトエ)
https://www.uta-net.com/song/15685/

3. あとは、`get_lyric` を実行するのですが、コマンドの次に、上記のアドレスを付けて実行します。

```
$ ./get_lyric https://www.uta-net.com/song/15685/
```

端末上で実行すると、歌詞が取得、表示され、可能ならば ジャケも取り込める筈です。


## inside code

ジャケの取得部分は、以下の様になっております。

```
        //  downloads
        http.download_file(msg, file_name)  ! 
        //os.execute('wget -O $file_name \''+msg+'\'')
```

本来ならば、http.download_file() で取得できそうなものですが、うまく取得できない場面がありましたので、その場合に備えて、wget でダウンロードする手段を用意しております。
コメントアウトしてご利用ください。

ブラッシュアップしておりません、小汚いコードの一例として下さい。

いじょ


## Revision historica

- 2025-07-16
  first appearance

