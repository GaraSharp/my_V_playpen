/* 
 * title : golden-vort.v - golden ratio vortext rotation 
 * begin : 2024-10-01 20:33:01  
 * base  : stardust.v
 * build : v run golden-vort.v
 * 
 */

// Copyright (c) 2019-2024 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// need ? DK ...
// module main

import gx
import gg
import time
import math

//  
const  window_width  = 640
const  window_height = 640
const  frame_rate    = 17      //
const  radius        = 1.5     //
const  lines         = 5000    //  座標配列の確保数

//  graphix, turtle structreii ...

struct Graph {
mut:
    gg       &gg.Context
    //  
    a        f64
    b        f64 
    r        f64
	he       int
    n        int
    th       f64
    xp       f64
    yp       f64
    d        f64
    m        f64
    ph       f64
	depth    int
    height   int
    width    int
    lin_x    []f32
    lin_y    []f32
}

//  
fn  main() {

	mut graph := &Graph{
		gg:       unsafe { 0  }  // place holdre for graphix context
		height:   window_height
		width:    window_width
	}
	graph.gg = gg.new_context(
		width:  window_width
		height: window_height
		// use_ortho: true
		user_data:     graph
		window_title:  'Golden-vort.v - Graphix app example'
		create_window: true
		frame_fn:      frame
		init_fn:       init
//		event_fn:      event_handler
		keydown_fn:    on_keydown
		bg_color:      gx.white
    )

    //  黄金比の定数など
    graph.a = 1.0
    graph.b = (1.0+math.sqrt(5))/2.0 
    graph.r = graph.b-graph.a

    //  黄金比長方形の縦の長さ
    //  これを指定すると、描く黄金比螺旋の大きさが決まる
    graph.he = 300

    //  1/4円の描図回数指定 (default ; 10)
    graph.depth = 10

    //  描き初めの 1/4 円の分割数 (n 角形)
    //  he を半径として、1/4 円の円周 (弧長)は、he*2*pi/4 = he*pi/2 の程度
    //  これを隙間なく埋めるには、この程度の分割数が欲しい所
    graph.n = int(f64(graph.he)*math.pi/2)
    println('n = ${graph.n}')

    //  n 角形 (1/4 円) の中心角
    graph.th = math.pi / 2.0 / f64(graph.n)

    //  turtle graphics info

    //  initial direction ; 
    //  idealには上向きも、正確には n 角形なので y 軸方向から少しずれる
    graph.d = math.pi/2*(1-1/(2*f64(graph.n)))
    //  initial movements ; n 分割された、二等辺三角形の底辺の長さ (ほぼ、1 )
    graph.m = 2*graph.he*math.sin(graph.th/2)

    //  アニメーションの回転量 ; 3 degree/frame
    graph.ph = -math.pi/180*3
	println('ph = ${graph.ph}')

    //  make lines coordinations array
	for _ in 0..lines {
        graph.lin_x << 0.0
        graph.lin_y << 0.0 
    }

    //  長方形の左下を原点とした場合の、螺旋の収束座標を計算
    //  (原理的には級数計算できそう。ここでは数値計算によって求めている)
    graph.xp = 0.0
    graph.yp = 0.0
    mut rr := f64(1)
    r  := graph.r

    for _ in 0..graph.depth {
        graph.xp += rr * (1 + r - r*r - r*r*r)
        graph.yp += rr * (1 - r - r*r + r*r*r)
        rr = rr*r*r*r*r
    }

    //  螺旋収束座標を原点とした場合の、1/4 円 (n 角形) の描き出しの座標 (長方形左下の「原点」)
    graph.xp = -graph.xp * graph.he
    graph.yp = -graph.yp * graph.he

    //  graphix loop
	println('Starting the graph loop...')
	// main graphix obj placing thread .
	go graph.run()
	//  follow graph.gg.run() calls frame_fn (and maybe calls event_fn )
	graph.gg.run()

}

//  this func is called from go graph.run() .
fn (mut graph Graph) run() {
	for {
		graph.update_model()
		graph.xp, graph.yp = rotat(graph.xp, graph.yp, graph.ph)
		graph.d = graph.d-graph.ph
		time.sleep(frame_rate * time.millisecond)
	}
}

//  Graphix initialize ( no need ... )
fn init(mut graph Graph)  {
    //
}

//  Graphix placing
//  vortex の座標を計算し、配列に収蔵する
fn (mut graph Graph) update_model()  {

    graph.make_vort(graph.xp, graph.yp, graph.m, graph.d)
}

//  Graphix placing ; 配列から座標を取り出し、線で表示する
fn frame (mut graph Graph) {
    graph.gg.begin()

    //  座標配列から座標を取り出し、線で結んで表示
    for idx in 0..lines-1 {
        graph.gg.draw_line( window_width/2+graph.lin_x[idx], window_height/2-graph.lin_y[idx], window_width/2+graph.lin_x[idx+1], window_height/2-graph.lin_y[idx+1], gx.black )
    }
    //  fps 表示
	graph.gg.show_fps()

    graph.gg.end()
}

//  座標回転変換
fn  rotat(x f64, y f64, ph f64) ( f64, f64 ) {
    xx := x * math.cos(ph)  + y * math.sin(ph)
    yy := -x * math.sin(ph) + y * math.cos(ph)
    return xx, yy
}

//  螺旋「作図」
//  タートルの初期座標、1/4円の初期半径, タートル移動step量を与える
fn (mut g Graph) make_vort(xx f64, yy f64, mm f64, dd f64) {
    //  関数内で変更するので、別変数に保存し直し
    mut xp  := xx   //  coordinate turtle x
	mut yp  := yy   //  coordinate turtle y
	mut m   := mm   //  radius of quarter circle
	mut d   := dd   //  turtle direction 
	mut idx := 0    //  座標配列の index

	//  1/4 円を描く処理を複数回繰り返す
    for _ in 0..g.depth {
        //print('m = ', m)
        // 1/4 円 (n 角形の底辺部分)を描く処理
        for _ in 0..g.n {
			//  座標配列が残っている間は、座標を保存しておく
			if idx < lines {
				g.lin_x[idx] = f32(xp)
				g.lin_y[idx] = f32(yp)
				idx += 1
			}
            //  n 角形の次の座標として turtle 移動処理
            xp += m*math.cos(d)
            yp += m*math.sin(d)
            d -= g.th
        }
        //  1/4円の半径を幾何級数的に収縮
        m = m * g.r
    }
}

//  key branching
fn on_keydown(key gg.KeyCode, mod gg.Modifier, mut graph Graph) {
	// global keys
	match key {
		.escape {
			exit(0)
		}
		.q {
			println('q pressed ... quit')
			exit(0)
		}
		.space {
			println('space pressed ... vortex rotation toggled')
            graph.ph = -graph.ph
		}
		.up {
			println('up key  pressed ... vortex rotation decrease')
            graph.ph = graph.ph - math.pi/180
		}
		.down {
			println('down key pressed ... vortex rotation increase')
            graph.ph = graph.ph + math.pi/180
		}
		else {}
	}
}

