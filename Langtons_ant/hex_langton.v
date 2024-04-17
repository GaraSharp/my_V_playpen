/* 
 * title : hex_langton.v - PIXEL graphix code example
 * begin : 2021-11-30 23:41:28 
 * base  : 
 * 
 */

// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// need ? DK ...
// module main

import gx
import gg
import time


//  
const (
    win_width    = 1000
    win_height   =  600
    pbytes       =    4      // RGBA (32 bit = 4 bytes) colour data ?
    timer_period =   10
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
    
    //  Ant info
    xp       int   //  x coord
    yp       int   //  y coord
    dir      int   //  direction ; 0..5

    // frame/time counters for showfps()
    frame int
    frame_old int
    frame_sw  time.StopWatch = time.new_stopwatch()
    second_sw time.StopWatch = time.new_stopwatch()

}

//  
fn main() {

    mut graph := &Graph {
        gg: unsafe { 0 }   // place holdre for graphix context
        width:  win_width
        height: win_height
        xp:     win_width/2  // Ant position ; centre of window
        yp:     win_height/2
        dir:    0            // first, Ant is directed to North
    }
    graph.gg = gg.new_context(
        width:  win_width
        height: win_height
        user_data: graph
        window_title: 'Langtons\' Ant graphics on Hex board with V.'
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
@[if showfps ?]
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
      graph.draw_texts()
    graph.gg.end()
}

//  
fn (mut graph Graph) run() {
    for {
        graph.showfps()
        graph.ant_move()
        //  uncomment follow line causes running this as 'Baku-soku'
        time.sleep(time.nanosecond)
    }
}

//  map graphix array generated
fn (mut g Graph) map_graphix() {
	mut istream_image := g.gg.get_cached_image_by_idx(g.istream_idx)
	istream_image.update_pixel_data(unsafe {&u8(&g.cells)})
	size := gg.window_size()
	g.gg.draw_image(0, 0, size.width, size.height, istream_image)
}

//  Caption text
fn (mut g Graph) draw_texts() {
    g.gg.draw_text(20, 30, 'Langtons\' Ant on Hex Board', text_cfg)
}

//  place pic-cell on graphix array buffre
//  this func plots 2x2 piccells in one time
fn (mut g Graph) plot_piccell(i int, j int, colour u32) {
    g.cells[j][i] = colour
    if i < win_width-1 {
        g.cells[j][i+1] = colour
    }
    if j < win_height-1 {
        g.cells[j+1][i] = colour
    }
    if i < win_width-1 && j < win_height-1 {
        g.cells[j+1][i+1] = colour
    }
}

//  ant movements
fn (mut g Graph) ant_move() {

    //  left turn and plot if there is not plotted
    if g.cells[g.yp][g.xp] == u32(gx.white.abgr8()) {
        g.plot_piccell(g.xp, g.yp, u32(gx.black.abgr8()))
        g.dir = (g.dir+1) % 6
    //  right turn and unplot if there is plotted
    } else {
        g.plot_piccell(g.xp, g.yp, u32(gx.white.abgr8()))
        g.dir = (g.dir+5) % 6
    }
    
    //  move on direction
    match g.dir {
        0 {  //  0 is EAST
          g.xp = (g.xp+2+win_width) % win_width
        }
        1 {  //  1 is NORTH-EAST
          g.xp = (g.xp+1+win_width)  % win_width
          g.yp = (g.yp-2+win_height) % win_height
        }
        2 {  //  2 is NORTH-WEST
          g.xp = (g.xp-1+win_width)  % win_width
          g.yp = (g.yp-2+win_height) % win_height
        }
        3 {  //  3 is WEST
          g.xp = (g.xp-2+win_width) % win_width
        }
        4 {  //  4 is SOUTH-WEST
          g.xp = (g.xp-1+win_width)  % win_width
          g.yp = (g.yp+2+win_height) % win_height
        }
        5 {  //  5 is SOUTH-EAST
          g.xp = (g.xp+1+win_width)  % win_width
          g.yp = (g.yp+2+win_height) % win_height
        }
        else { }
    }
}

//  graphix rendering callback for initiate
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

