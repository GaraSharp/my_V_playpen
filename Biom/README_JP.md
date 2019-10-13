# biomorph.v

Clifford Pickovers' Biomorph graphics

VでPickovers' biomorphグラフィクスを表示するコードを作成しました。

Vで複素数の計算をする例です。

2019-10-12 現在、複素数の構造体がpubではなく(pubic ? :-)、複素数の実部、虚部を読み出す方法がありませんから、仕方なしに次の様なカンスーを設けております。

`//  real/imag part of complex number`
`fn real_(c cmplx.Complex) f64 {`
  `return c.abs()*math.cos(c.angle())`
`}`

`fn imag_(c cmplx.Complex) f64 {`
  `return c.abs()*math.sin(c.angle())`
`}`

計算によって実部、虚部を求めているので、計算誤差が混入する事がります。

最新のvでは、関数名の冒頭にアンダースコアを使うな、という警告が出るので、こんな名前にしました。

v/vlib/math/complex/complex.v の中にメンバ関数で、実部、虚部を参照できるものがあるといいのですが。例えば、こんなの。

`// Complex real/imag part value`
`pub fn (c Complex) real() f64 {`
	`return c.re`
`}`

`pub fn (c Complex) imag() f64 {`
	`return c.im`
`}`

また、複素数の掛け算、割り算のin-fix記述は現在サポートされていないので、繰り返しの計算式の記述が少々メンドウな具合です。

v -live biomorph.v とやってコンパイルし、実行します。
hot code reloadingの機能を使っているので、実行中にソースをエディタで開いておき、メンバ関数generate() 内の

+ 定数 c
+ 繰り返し式部分

を変更すると、即時、画像の変化が確認できます。

