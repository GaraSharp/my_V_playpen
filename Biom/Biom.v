// title : Biom.v 
// begin : 2019-09-06 21:38:31  
// note  : draw Pickovers' Biomorph with V
// base  : examples/gg/random.v 

// Copyright (c) 2019 - 2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.  


import time
import gx 
import gg
import math
import math.complex as cmplx


// It seems ; A_B_G_R (reverse order ) ?
const (
  colour_red   = u32(0xFF_00_00_FF)
  colour_green = u32(0xFF_00_FF_00)
  colour_blue  = u32(0xFF_FF_00_00)
  colour_white = u32(0xFF_FF_FF_FF)
  colour_black = u32(0xFF_00_00_00)
)

const (
  //  Window coords
  x_min     = -3.2
  x_max     =  3.2
  y_min     = -2.4
  y_max     =  2.4

  block_size   = 2
  win_width    = 960   // window size
  win_height   = 720
  pic_colour   = gx.rgb(0, 0, 240)
  bak_colour   = gx.rgb(240, 240, 240)
  pbytes       = 4
  timer_period = 20 // ms
)


struct AppState {
mut:
	gg          &gg.Context = 0
	istream_idx int
	pixels      [win_height][win_width]u32
}


[live]
fn (mut state AppState) biom() {
  mut x := f64(0)
  mut y := f64(0)
  mut z := cmplx.complex(x, y)
  //  constant - changing makes graphics changed
  c := cmplx.complex(-0.25, -0.5)

  for j := 0; j < win_height; j++ {
    for i := 0; i < win_width; i++ {
      x = f64(i)*(x_max-x_min)/win_width +x_min
      y = f64(j)*(y_min-y_max)/win_height+y_max
      z = cmplx.complex(x, y)
      //  iteration part
      mut k := 0
      for {
        // iteration forms
        // modify these lines as you like ...
        z = z*z*z*z*z + z*z*z + c
        z = z.sin()+z*z - c
//        z = z.cos().cos() + c
//        z = (z*z*z*z+z*z+c)/z
        k++
        if k > 10 || z.abs() >= 10 { break }
      }

      // set piccell on condition
      state.pixels[j][i] = if math.abs(z.re) < 10 || math.abs(z.im) < 10 { colour_black } else { colour_white }
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
	istream_image.update_pixel_data(&state.pixels)
	size := gg.window_size()
	state.gg.draw_image(0, 0, size.width, size.height, istream_image)
}

// gg callbacks:

fn graphics_init(mut state AppState) {
	state.istream_idx = state.gg.new_streaming_image(win_width, win_height, pbytes)
}

fn graphics_frame(mut state AppState) {
	state.gg.begin()
      state.draw()
	state.gg.end()
}

fn main() {
	mut state := &AppState{}
	state.gg = gg.new_context(
		width: win_width
		height: win_height
		create_window: true
		window_title: 'Pickovers\' Biomorph'
		init_fn: graphics_init
		frame_fn: graphics_frame
		user_data: state
	)
	go state.update()
	state.gg.run()
}

