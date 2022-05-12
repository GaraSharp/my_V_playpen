/* 
 * title : hopalong.v - PIXEL graphix code example
 * begin : 2022-05-12 15:00:14 
 * base  : langton.v
 * ref   : HOPALONG, from Dewdney’s Armchair Universe - brainwagon
 *       : https://brainwagon.org/2011/03/24/hopalong-from-dewdneys-armchair-universe/

 * 
 */

// Copyright (c) 2019-2022 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// need ? DK ...
module main

import gx
import gg
import time
import math

//  
const (
    win_width    =  650
    win_height   =  650
    pbytes       =    4      // RGBA (32 bit = 4 bytes) colour data ?
    timer_period =    1
    
    x_lo         = -50       //  screen coords
    x_hi         =  50
    y_lo         = -50
    y_hi         =  50

)

//  colour constants
const (
    colour_white = u32(0xFF_FF_FF_FF)
    colour_black = u32(0xFF_00_00_00)
)

//  font contexts
const (
    text_cfg = gx.TextCfg {
        align:gx.align_left
        size:32
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
    
    //  
    xp       int   //  x coord
    yp       int   //  y coord
    dir      int   //  direction ; North=0, West=1, South=2, East=3
    a        f64   //  attractor params
    b        f64
    c        f64
    x        f64   //
    y        f64

    // frame/time counters for showfps()
    frame int
    frame_old int
    frame_sw  time.StopWatch = time.new_stopwatch()
    second_sw time.StopWatch = time.new_stopwatch()

}

//  
fn main() {

// double a = -200, b = .1, c = -80 ;
// double a = 0.4, b = 1, c = 0 ;
// double a = -3.14, b = 0.3, c = 0.3 ;
//double   a = -1000, b = 0.1, c = -10;

    mut graph := &Graph {
        gg: 0  // place holdre for graphix context
        width:  win_width
        height: win_height
        xp:     win_width/2  // Ant position ; centre of window
        yp:     win_height/2
        dir:    0            // first, Ant is directed to North
        a:      -1000        // attractor params
        b:       0.1
        c:      -10
        x:       0.0         // 
        y:       0.0
    }
    graph.gg = gg.new_context(
        width:  win_width
        height: win_height
        use_ortho: true
        user_data: graph
        window_title: 'Dewdneys\' Hopalong graphics with V.'
        create_window: true
        init_fn: graphics_init
        frame_fn: frame
		keydown_fn: on_keydown
        bg_color: gx.white
    )

    println('Starting the graph loop...')
    // main graphix obj placing thread .
    go graph.run()
    //  gg.run() calls frame_fn (and maybe calls event_fn )
    graph.gg.run()
}

//  frame rate (fps) and some info reports
[if showfps ?]
fn (mut graph Graph) showfps() {
    graph.frame++
    last_frame_ms := f64(graph.frame_sw.elapsed().microseconds())/1000.0
    ticks := f64(graph.second_sw.elapsed().microseconds())/1000.0
    if ticks > 999.0 {
        fps := f64(graph.frame - graph.frame_old)*ticks/1000.0
        eprintln('fps: ${fps:5.1f} | last frame took: ${last_frame_ms:6.3f}ms | frame: ${graph.frame:6} ')
        graph.second_sw.restart()
        graph.frame_old = graph.frame
    }
}

//  
fn frame (mut graph Graph) {
    //  follow line need for text drawin'
    graph.frame_sw.restart()

    graph.gg.begin()
      graph.map_graphix()
//      graph.draw_texts()
    graph.gg.end()
}

//  
fn (mut graph Graph) run() {
    for {
        graph.showfps()
        graph.attractor()
        //  uncomment follow line causes running this as 'Baku-soku'
//        time.sleep(time.nanosecond)
    }
}

//  map graphix array generated
fn (mut g Graph) map_graphix() {
	mut istream_image := g.gg.get_cached_image_by_idx(g.istream_idx)
	istream_image.update_pixel_data(&g.cells)
	size := gg.window_size()
	g.gg.draw_image(0, 0, size.width, size.height, istream_image)
}

//  Caption text
fn (mut g Graph) draw_texts() {
    g.gg.draw_text(20, 30, 'Hopalong graphix', text_cfg)
}

//  place pic-cell on graphix array buffre
fn (mut g Graph) plot_piccell(i int, j int, colour u32) {
    if i>=0 && i<win_width && j>=0 && j<win_height {
        g.cells[j][i] = colour
    }
}

fn sgn(x f64) f64 {
    if x == 0.0 { return x }
    if x < 0.0  { return -1.0 }
    return 1.0 
}

//  ant movements
fn (mut g Graph) attractor() {

    mut  xp := 0
    mut  yp := 0
    mut  nx := f64(0)
    mut  ny := f64(0)
//    mut x := 0.0, y := 0.0

    
    xp = int(win_width *(g.x-x_lo)/(x_hi-x_lo))
    yp = int(win_height*(y_hi-g.y)/(y_hi-y_lo))

    g.plot_piccell(xp, yp, u32(gx.black.abgr8()))

    nx = g.y - sgn(g.x)*math.sqrt(math.abs(g.b*g.x-g.c))
    ny = g.a - g.x
    g.x = nx
    g.y = ny

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
           println('\'q\' pressed for ... quit')
           exit(0)
        }
        else {}
    }
}

