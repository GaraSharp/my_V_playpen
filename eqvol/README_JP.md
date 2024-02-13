# eqvol.v

V で動く、気象庁のXMLを取得して表示するプログラムですだよ。

元日以来、石川県の地震が続いております。
地震の情報をいち早く取得する方法を探しておりましたら、気象庁にPull型情報提供というのがあるとの事。

ref.　気象庁防災情報XMLフォーマット形式電文の公開（PULL型）
https://xml.kishou.go.jp/xmlpull.html

ここから、xmlファイルを取得すると、地震や火山噴火などの情報が得られるらしい。
今回は、V で `https://www.data.jma.go.jp/developer/xml/feed/eqvol.xml` を読む作業を行いました。

## usage and dosage

`v eqvol.v` でコンパイルすると、eqvol というバイナリを生成します。
あとは、eqvol を実行するだけ。

```
$ ./eqvol
```


## inside code

Vでは、encoding.xml module で XML を解釈するそうですが、python3 では、xml.dom.minidom で、基礎的なXMLの処理が出来るらしく、色々とやってでっち上げた, python3 のコードを挙げておきます。

いじょ


## Revision historica

- 2024-02-14
  first appearance

