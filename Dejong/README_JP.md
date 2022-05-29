# De Jong attractor 'Chicken Leg' with V

pixel グラフィクスの習作として、以下のサイトに紹介されているコードを作成しました。

ref.   Strange Attractors: The De Jong Attractors - algosome.com

https://www.algosome.com/articles/strange-attractors-de-jong.html

## lista-manifesto

- dejong.v
  プログラム本体ですだよ

## nota about V code

+ wait を削除すると、爆速に
  
  149行目の ```time.sleep(time.nanosecond)``` を削除すると、めっぽう早く動きます。
  「流石はV言語だ」


## nota about 'De jong attractor'

その昔、図書館で「日経サイエンス」(Scientific American 日本語版)の「コンピュータ・リクリエーション」 (A. K. Dewdney 著) バックナンバーを読み漁っており、当時は8 bit のMSXマシンでプログラムを作成するなどしておりました。

この連載の中に「Chicken Leg」という名を冠したattractor意匠が出ていて、手持ちのMSXマシンでうまく表示できた、数少ないものだったのですが、その時作成したBASICプログラムも散逸してしまい、果たしてどんなもんだったのか、と最近になって思い出して、調べたのでした。

原版の記事PDFが見つかり、件のattractor が Peter De Jong によるattractor だと知って、久しぶりにプログラムを作成してみた次第です。

http://paulbourke.net/fractals/peterdejong/peterdejong.pdf

冒頭で触れたblog様には、他のパラメタによる意匠も紹介されております。



Revision historica : 

- 2022-05-30
  first appearance
