/*
 * title : stardust.v - new graphix code template
 * begin : 2020-09-24 13:27:40
 * base  : mandala.v
 * build : v run stardust.v
 *       :   or
 *       : VUI_FONT=... v run stardust.v
 *
 *
 */

// Copyright (c) 2019-2024 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// need ? DK ...
// module main
import os
import os.font
import gx
import gg
import time
import sokol.sapp // for mouse cursor handling
import rand

//  
const window_width  = 960 //  set screen pixel for fullscreen
const window_height = 540 //  set screen pixel for fullscreen

const window_depth  = 400 //  (as you like)
const space_width   = 20000 //
const space_height  = 20000
const space_depth   = 10000
const frame_rate    = 17 //
const stars         = 1000 //  allocate stars

//  font contexts
const text_cfg = gx.TextCfg{
	align: gx.align_left
	size:  16
	color: gx.white
}

struct Graph {
mut:
	gg     &gg.Context
	x      []f32 //  stars coords
	y      []f32
	z      []f32
	height int
	width  int

	mouse_vu bool

	draw_fn voidptr

	font_loaded bool
	vui_font_p  bool //  VUI_FONT used ? for Japanese string using

	// frame/time counters for showfps()
	frame     int
	frame_old int
	frame_sw  time.StopWatch = time.new_stopwatch()
	second_sw time.StopWatch = time.new_stopwatch()
}

//
fn main() {
	// get font file path
	font_name  := font.default()
	mut width  := 0
	mut height := 0

	mut graph := &Graph{
		gg:       unsafe { 0 } // place holdre for graphix context
		height:   window_height
		width:    window_width
		draw_fn:  0
		mouse_vu: true
	}

	println('screen : ${gg.screen_size()}')

	match os.user_os() {
		'macos' { // Mac OS case
			width  = gg.screen_size().width
			height = gg.screen_size().height
		}
		else {
			width  = window_width
			height = window_height
		}
	}

	graph.gg = gg.new_context(
		width:  width
		height: height
		//  use_ortho: true
		user_data:     graph
		window_title:  'Stardust.v - Graphix app example'
		create_window: true
		frame_fn:      frame
		init_fn:       init
		event_fn:      event_handler
		keydown_fn:    on_keydown
		font_path:     font_name
		bg_color:      gx.black
		//  fullscreen: true  //  to activate full screen, toggle_fillscreen()
	)

	//  is VUI_FONT set ? for message selecting
	graph.vui_font_p = if os.getenv('VUI_FONT') != '' {
		true
	} else {
		false
	}

	//
	for _ in 0 .. stars {
		graph.x << rand.f32_in_range(-space_width / 2, space_width / 2)!
		graph.y << rand.f32_in_range(-space_height / 2, space_height / 2)!
		graph.z << rand.f32_in_range(window_depth, space_depth)!
	}

	println('Starting the graph loop...')

	// main graphix obj placing thread .
	go graph.run()
	//  gg.run() calls frame_fn (and maybe calls event_fn )
	graph.gg.run()
}

//  graphix environment initialize handler
fn init(mut graph Graph) {
	// mouse cursor set another type (currently inactive)
	sapp.set_mouse_cursor(.not_allowed)
	//  hide mouse cursor
	sapp.show_mouse(graph.mouse_vu)
	//  switch to fullscreen
	gg.toggle_fullscreen()
}

// drawing star
fn (mut graph Graph) draw_star(x f32, y f32, r f32) {
	graph.gg.draw_circle_filled(x, y, r, gx.white)
}

// Graphix placing
fn frame(mut graph Graph) {
	graph.gg.begin()

	for c in 0 .. stars {
		mut r := f32(window_depth) / graph.z[c] * 3
		if r < 1.05 {
			r = 1.05
		}
		graph.draw_star(graph.x[c] * window_depth / graph.z[c] + graph.gg.mouse_pos_x, //          window_width /2 + graph.x[c]*window_depth/graph.z[c] ,
		 graph.y[c] * window_depth / graph.z[c] + graph.gg.mouse_pos_y, //          window_height/2 - graph.y[c]*window_depth/graph.z[c] ,
		 r)
	}

	graph.draw_texts()
	graph.gg.show_fps()

	graph.gg.end()
}

//
fn (mut graph Graph) update_model() {
	for c in 0 .. stars {
		graph.z[c] = graph.z[c] - 20
		if graph.z[c] <= 1 {
			graph.x[c] = rand.f32_in_range(-space_width / 2, space_width / 2) or { 0.0 }
			graph.y[c] = rand.f32_in_range(-space_height / 2, space_height / 2) or { 0.0 }
			graph.z[c] = space_depth
		}
	}
}

//
fn (mut graph Graph) run() {
	for {
		graph.update_model()
		time.sleep(frame_rate * time.millisecond)
	}
}

//
fn (mut g Graph) draw_texts() {
	if g.vui_font_p == true {
		//  g.gg.draw_text(30, 28, '宇宙 ... それは人類に残された最後の開拓地である', text_cfg)
		g.gg.draw_text(30, 28, '人類の冒険は、始まったばかりである',
			text_cfg)
	} else {
		//  g.gg.draw_text(30, 28, 'Space ... The final frontier', text_cfg)
		g.gg.draw_text(30, 28, "The human ad'V'enture is just beginning", text_cfg)
	}
}

//  event handler ?
fn event_handler(mut ev gg.Event, mut app Graph) {
	//  toggle mouse cursor show/hide with mouse button #1
	if ev.typ == .mouse_up {
		//  println('chuu ; $app.mouse_x, $app.mouse_y')
		if app.mouse_vu == true {
			app.mouse_vu = false
		} else {
			app.mouse_vu = true
		}
		sapp.show_mouse(app.mouse_vu)
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
			println('space pressed ... ')
			// println('mouse : $graph.mouse_x, $graph.mouse_y')
			println('mouse : ${graph.gg.mouse_pos_x}, ${graph.gg.mouse_pos_y}')
		}
		else {}
	}
}
