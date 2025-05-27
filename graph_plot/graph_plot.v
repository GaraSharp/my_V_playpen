/*
 * title : graph_plot.v - PIXEL graphix code example
 * begin : 2025-05-26 21:10:35 
 * base  : hopalong.v
 * run   : v -live run graph_exam.v
 * 
 * 
 */

// Copyright (c) 2019-2025 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// need ? DK ...
module main

import gx
import gg
import time
import math

//
const win_width    = 650
const win_height   = 650
const pbytes       = 4 // RGBA (32 bit = 4 bytes) colour data ?

const timer_period = 1

const x_lo = -10 //  screen coords
const x_hi =  10
const y_lo = -10
const y_hi =  10
const zoom_factor  = 1.25  //  zooming factor ratio with wheel steppin

const eps = 0.05

//  colour constants
const colour_white = u32(0xFF_FF_FF_FF)
const colour_black = u32(0xFF_00_00_00)

//  font contexts
const text_cfg = gx.TextCfg{
	align: gx.align_left
	size:  14
	color: gx.rgb(0, 0, 0)
}

struct Graph {
mut:
	// graphics pic-cell array
	cells       [win_height][win_width]u32
	istream_idx int

	gg     &gg.Context
	height int
	width  int
	x_lo   f64
	x_hi   f64
	y_lo   f64
	y_hi   f64
    eps    f64
}

//  live fonction ; 陰関数表示の関数記述部分
@[live]
fn (mut g Graph) f1(x f64, y f64) f64 {
    a := 1.02
	b := 1.00
    g.eps = 0.02
//    以前、描き出そうと作業していた線  #1
//    return x + 3 * math.log(math.abs(x)) - y * y
//    以前、描き出そうと作業していた線  #2
//    return 2*x*x-x*y-5*x+1
//    デカルトの正葉線
//    return x*x*x-3*x*y-y*y*y
//    レムニスケート
//    return (x*x+y*y)*(x*x+y*y)-2*(x*x-y*y)
//    カッシーニの卵形線
//    return (x*x+y*y)*(x*x+y*y)-2.0*b*(y*y-x*x)-(a*a*a*a-b*b*b*b)
//    return (x*x+y*y)*(x*x+y*y)-2.0*b*(x*x-y*y)-(a*a*a*a-b*b*b*b)
//    & 型曲線
    return 6*x*x*x*x -21*x*x*x +6*x*x*y*y +19*x*x -11*x*y*y +4*y*y*y*y -3*y*y
}

//
fn main() {
	mut graph := &Graph{
		gg:     unsafe { 0 } // place holdre for graphix context
		width:  win_width
		height: win_height
		x_lo:   x_lo
		x_hi:   x_hi
		y_lo:   y_lo
		y_hi:   y_hi
        eps:    eps
	}
	graph.gg = gg.new_context(
		width:         win_width
		height:        win_height
		user_data:     graph
		window_title:  'f(x, y) < eps plotting with V.'
		create_window: true
		init_fn:       graphics_init
		frame_fn:      frame
		keydown_fn:    on_keydown
		scroll_fn:     graphics_scroll
		bg_color:      gx.white
	)

	println('Starting the graph loop...')
	// main graphix obj placing thread .
	go graph.run()
	//  gg.run() calls frame_fn (and maybe calls event_fn )
	graph.gg.run()
}

//
fn frame(mut graph Graph) {
	//  follow line need for text drawin'
	graph.gg.begin()
	graph.gg.end()

	graph.map_graphix()
	graph.gg.draw_line(0, win_height / 2, win_width, win_height / 2, gx.blue)
	graph.gg.draw_line(win_width / 2, 0, win_width / 2, win_height, gx.blue)
	graph.draw_texts()
	graph.gg.show_fps()
}

//
fn (mut graph Graph) run() {
	for {
		graph.attractor()
		//  uncomment follow line causes running this as 'Baku-soku'
		time.sleep(time.nanosecond)
	}
}

//  map graphix array generated
fn (mut g Graph) map_graphix() {
	mut istream_image := g.gg.get_cached_image_by_idx(g.istream_idx)
	istream_image.update_pixel_data(unsafe { &u8(&g.cells) })
	size := gg.window_size()
	g.gg.draw_image(0, 0, size.width, size.height, istream_image)
}

//  Caption text
fn (mut g Graph) draw_texts() {
	g.gg.draw_text(20, 30, 'x,y : ${g.x_lo} ... ${g.x_hi}', text_cfg)
}

//  place pic-cell on graphix array buffre
fn (mut g Graph) plot_piccell(i int, j int, colour u32) {
	if i >= 0 && i < win_width && j >= 0 && j < win_height {
		g.cells[j][i] = colour
	}
}

//  ant movements
fn (mut g Graph) attractor() {
	mut xp := f64(0)
	mut yp := f64(0)

	for j in 0 .. win_height {
		for i in 0 .. win_width {
			//
			xp = g.x_lo + f64(i) / win_width *  (g.x_hi - g.x_lo)
			yp = g.y_hi - f64(j) / win_height * (g.y_hi - g.y_lo)
			if math.abs(g.f1(xp, yp)) < g.eps {
				g.plot_piccell(i, j, u32(gx.black.abgr8()))
			} else {
				g.plot_piccell(i, j, u32(gx.white.abgr8()))
			}
		}
	}
	//	println('attr()')
}

//  graphix rendering callback for graphix initiate
fn graphics_init(mut g Graph) {
	g.istream_idx = g.gg.new_streaming_image(win_width, win_height, pbytes, pixel_format: .rgba8)
}

//  key events handler
fn on_keydown(key gg.KeyCode, mod gg.Modifier, mut graph Graph) {
	// global keys
	match key {
		.escape {
			println('ESC key pressed ... quit')
			exit(0)
		}
		.q {
			println("'q' pressed for ... quit")
			exit(0)
		}
		else {}
	}
}

fn graphics_scroll(e &gg.Event, mut graph Graph) {
	graph.zoom(if e.scroll_y < 0 { zoom_factor } else { 1 / zoom_factor })
    //	println('... ${e.modifiers}')
}

fn (mut g Graph) zoom(factor f64) {
    g.x_hi = factor * g.x_hi
    g.x_lo = factor * g.x_lo
    g.y_hi = factor * g.y_hi
    g.y_lo = factor * g.y_lo
    //
}

