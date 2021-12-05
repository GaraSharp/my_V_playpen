/* 
 * title : langton.v - PIXEL graphix code example
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
import rand
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
    dir      int   //  direction ; North=0, West=1, South=2, East=3

    // frame/time counters for showfps()
    frame int
    frame_old int
    frame_sw  time.StopWatch = time.new_stopwatch()
    second_sw time.StopWatch = time.new_stopwatch()

}

//  
fn main() {

    mut graph := &Graph {
        gg: 0  // place holdre for graphix context
        width:  win_width
        height: win_height
        xp:     win_width/2  // Ant position ; centre of window
        yp:     win_height/2
        dir:    0            // first, Ant is directed to North
    }
    graph.gg = gg.new_context(
        width:  win_width
        height: win_height
        use_ortho: true
        user_data: graph
        window_title: 'Langtons Ant graphics with V.'
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
    //graph.ft.flush()
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
	istream_image.update_pixel_data(&g.cells)
	size := gg.window_size()
	g.gg.draw_image(0, 0, size.width, size.height, istream_image)
}

//  Caption text
fn (mut g Graph) draw_texts() {
    g.gg.draw_text(20, 30, 'Langtons\' Ant', text_cfg)
}

//  place pic-cell on graphix array buffre
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

//  place pic-cell on graphix array buffre
fn (mut g Graph) plot_piccell_(i int, j int, colour u32) {
    g.cells[j][i] = colour
}



// function draw array generates
fn (mut g Graph) generate() {

    mut  c := 0

    for j := 0; j < win_height; j++ {
        for i := 0; i < win_width; i++ {
            // set piccell on condition
            g.plot_piccell(i, j, if rand.intn(2) == 0 { u32(gx.black.abgr8()) } else { u32(gx.white.abgr8()) })
//            g.cells[j][i] = if rand.intn(2) == 0 { colour_black } else { colour_white }
            c = 1-c
        }
    }
//    println('generated ')
}


//  ant movements
fn (mut g Graph) ant_move() {

    if g.cells[g.yp][g.xp] == u32(gx.white.abgr8()) {
        g.cells[g.yp][g.xp] = u32(gx.black.abgr8())
        g.dir = (g.dir+1) % 4
    } else {
        g.cells[g.yp][g.xp] = u32(gx.white.abgr8())
        g.dir = (g.dir+3) % 4
    }
    
    match g.dir {
        0 {
          g.yp = (g.yp-1+win_height) % win_height
        }
        1 {
          g.xp = (g.xp-1+win_width) % win_width
        }
        2 {
          g.yp = (g.yp+1+win_height) % win_height
        }
        3 {
          g.xp = (g.xp+1+win_width) % win_width
        }
        else { }
    }

//    println('(${g.xp}, ${g.yp}), $g.dir ')
//    time.sleep(10*time.millisecond)
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

