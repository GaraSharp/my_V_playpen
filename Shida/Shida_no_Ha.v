/* 
 * title : Shida_no_Ha.v - PIXEL graphix code example
 * begin : 2024-04-17 17:14:42 
 * base  : 
 * 
 */

// Copyright (c) 2019-2024 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// need ? DK ...
// module main

import os
import gx
import gg
import rand
import time


//  
const (
    // Window coords
    x_min = -3.0
    x_max =  3.0
    y_min = -0.5
    y_max = 11.0

    win_width  = 1150
    win_height = 600
    pbytes       =    4      // RGBA (32 bit = 4 bytes) colour data ?
    timer_period =   10
)

//  colour constants
const (
    colour_white = u32(0xFF_FF_FF_FF)
    colour_black = u32(0xFF_00_00_00)
    colour_green = u32(0xFF_00_FF_00)
)

//  font contexts
const (
    text_cfg = gx.TextCfg {
        align:gx.align_left
        size:20
        color:gx.rgb(0, 0, 0)
    }
)


struct Graph {
mut:
    // graphics pic-cell array
    cells       [win_height][win_width]u32
    istream_idx int

    gg       &gg.Context
    height   int
    width    int
   //  fern piccel coord translations
    xx        f64
    yy        f64
    px        f64
    py        f64
    vui_font_p bool

}

//  
fn main() {

    mut graph := &Graph {
        gg:  unsafe {  0  }  // place holdre for graphix context
        width:  win_width
        height: win_height
        xx:  0.0
        yy:  0.0
        px:  0.0
        py:  0.0
        vui_font_p: false
    }
    graph.gg = gg.new_context(
        width:  win_width
        height: win_height
        user_data: graph
        window_title: 'Iterative fern graphix with V.'
        create_window: true
        init_fn: graphics_init
        frame_fn: frame
        keydown_fn: on_keydown
        bg_color: gx.white
    )

    if os.getenv('VUI_FONT') != '' {
        graph.vui_font_p = true
    }

    println('Starting the graph loop...')
    // main graphix obj placing thread .
    go graph.run()
    //  gg.run() calls frame_fn (and maybe calls event_fn )
    graph.gg.run()
}

//  
fn frame (mut graph Graph) {
    graph.gg.begin()
      graph.map_graphix()
      graph.draw_texts()
      graph.gg.show_fps()
    graph.gg.end()
}

//  
fn (mut graph Graph) run() {
    for {
        graph.ant_move()
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
    if g.vui_font_p == true {
        g.gg.draw_text(20, 30, 'Графика листьев папоротника', text_cfg)
   } else {
        g.gg.draw_text(20, 30, 'Iterative fern graphix', text_cfg)
    }
}


//  place pic-cell on graphix array buffre
fn (mut g Graph) ant_move() {

        r := rand.f64()
        if r < 0.01 {
            g.xx = 0.0
            g.yy = 0.16 * g.py
        }
        if r >= 0.01 && r < 0.07 {
            g.xx = 0.2  * g.px - 0.26 * g.py
            g.yy = 0.23 * g.px + 0.22 * g.py + 1.6
        }
        if r >= 0.07 && r < 0.15 {
            g.xx = -0.15 * g.px + 0.28 * g.py
            g.yy =  0.26 * g.px + 0.24 * g.py + 0.44
        }
        if r >= 0.15 {
            g.xx =  0.85 * g.px + 0.04 * g.py
            g.yy = -0.04 * g.px + 0.85 * g.py + 1.6
        }
        g.px, g.py = g.xx, g.yy

        /*  set pic-cell colour on  */
        ii := win_height - int((x_max - g.px) / (x_max - x_min) * win_height)
        jj := int((g.py - y_min) / (y_max - y_min) * win_width)
        g.cells[ii][jj] = colour_green   //u32(gx.black.abgr8())
}

//  graphix rendering callback for graphix initiate
fn graphics_init(mut g Graph) {
	g.istream_idx = g.gg.new_streaming_image(win_width, win_height, pbytes, pixel_format: .rgba8)
}


//  キーイベント捕捉 
// events
fn on_keydown(key gg.KeyCode, mod gg.Modifier, mut graph Graph) {
    // global keys
    match key {
        .escape {
            println('ESC key pressed ... quit')
            exit(0)
        }
        .q {
           println('\'q\' pressed for ... quit')
           exit(0)
        }
        else {}
    }
}

