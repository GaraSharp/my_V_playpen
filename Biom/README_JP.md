# biomorph.v

Clifford Pickovers' Biomorph graphics

VでPickovers' biomorphグラフィクスを表示するコードを作成しました。

Vで複素数の計算をする例です。

複素数の掛け算、割り算のin-fix記述は現在サポートされていないので、繰り返しの計算式の記述が少々メンドウな具合です。

v -live biomorph.v とやってコンパイルし、実行します。
hot code reloadingの機能を使っているので、実行中にソースをエディタで開いておき、メンバ関数generate() 内の

+ 定数 c
+ 繰り返し式部分

を変更すると、即時、画像の変化が確認できます。

2019-10-15 19:42:48 
githubに愁訴したら、早速、複素数のメンバ、実部 (re)、虚部 (im)がpubになりましたので、コードに反映しました。

