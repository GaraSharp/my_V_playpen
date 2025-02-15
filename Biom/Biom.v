// title : Biom.v
// begin : 2019-09-06 21:38:31
// note  : draw Pickovers' Biomorph with V
// base  : examples/gg/random.v

// Copyright (c) 2019 - 2024 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

import time
import gx
import gg
import math
import math.complex as cmplx

// It seems ; A_B_G_R (reverse order ) ?
const colour_red   = u32(0xFF_00_00_FF)
const colour_green = u32(0xFF_00_FF_00)
const colour_blue  = u32(0xFF_FF_00_00)
const colour_white = u32(0xFF_FF_FF_FF)
const colour_black = u32(0xFF_00_00_00)

//  Window coords
const x_min = -3.2
const x_max = 3.2
const y_min = -2.4
const y_max = 2.4

const block_size = 2
const win_width  = 960 // window size
const win_height = 720
const pic_colour = gx.rgb(0, 0, 240)
const bak_colour = gx.rgb(240, 240, 240)
const pbytes     = 4
const timer_period = 2000 // ms

struct AppState {
mut:
	gg          &gg.Context = unsafe { nil }
	istream_idx int
	pixels      [win_height][win_width]u32
}

@[live]
fn (mut state AppState) biom() {
	mut x := f64(0)
	mut y := f64(0)
	mut z := cmplx.complex(x, y)
	//  constant - changing makes graphics changed
	c := cmplx.complex(-0.25, -0.5)

	for j := 0; j < win_height; j++ {
		for i := 0; i < win_width; i++ {
			x = f64(i) * (x_max - x_min) / win_width + x_min
			y = f64(j) * (y_min - y_max) / win_height + y_max
			z = cmplx.complex(x, y)
			//  iteration part
			mut k := 0
			for {
				// iteration forms
				// modify these lines as you like ...
				//        z = z*z*z*z*z + z*z*z + c
				z = z.sin() + z * z - c
				//        z = z.cos().cos() + c
				z = (z * z * z * z + z * z + c) / z
				k++
				if k > 10 || z.abs() >= 10 {
					break
				}
			}

			// set piccell on condition
			state.pixels[j][i] = if math.abs(z.re) < 10 || math.abs(z.im) < 10 {
				u32(gx.black.abgr8())
			} else {
				u32(gx.white.abgr8())
			}
			//      state.pixels[j][i] = if math.abs(z.re) < 10 || math.abs(z.im) < 10 { colour_black } else { colour_white }
		}
	}
}

fn (mut state AppState) update() {
	for {
		state.biom()
		time.sleep(timer_period * time.millisecond)
	}
}

fn (mut state AppState) draw() {
	mut istream_image := state.gg.get_cached_image_by_idx(state.istream_idx)
	istream_image.update_pixel_data(unsafe { &u8(&state.pixels) })
	size := gg.window_size()
	state.gg.draw_image(0, 0, size.width, size.height, istream_image)
}

// gg callbacks:

fn graphics_init(mut state AppState) {
	state.istream_idx = state.gg.new_streaming_image(win_width, win_height, pbytes,
		pixel_format: .rgba8
	)
}

fn graphics_frame(mut state AppState) {
	state.gg.begin()
	state.draw()
	state.gg.end()
}

//  キーイベント捕捉
// events
fn on_keydown(key gg.KeyCode, mod gg.Modifier, mut state AppState) {
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

fn main() {
	mut state := &AppState{}
	state.gg = gg.new_context(
		width:         win_width
		height:        win_height
		create_window: true
		window_title:  "Pickovers' Biomorph"
		init_fn:       graphics_init
		frame_fn:      graphics_frame
		user_data:     state
		keydown_fn:    on_keydown
	)
	go state.update()
	state.gg.run()
}
