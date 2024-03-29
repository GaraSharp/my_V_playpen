/* 
 * title : Shida_no_Ha.v - new graphix code template
 * begin : 2020-06-08 14:08:59 
 * build : v run Shida_no_Ha.v
 * 
 */

// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// need ? DK ...
// module main

import os
import os.font
import gx
import gg
import rand
import time


struct Graph {
mut:
    // graphics pic-cell array
    cells       [][]int

    gg       &gg.Context
    x        int
    y        int
    dy       int
    dx       int
    height   int
    width    int
    draw_fn  voidptr

    // frame/time counters for showfps()
    frame int
    frame_old int
    frame_sw  time.StopWatch = time.new_stopwatch()
    second_sw time.StopWatch = time.new_stopwatch()
    
    //  extended text flag
    vui_font_p  bool

}

const (
// Window coords
    x_min = -3.0
    x_max =  3.0
    y_min = -0.5
    y_max = 11.0
    block_size    = 3
    window_width  = 1150
    window_height = 600
    width = 50
    leaf_colour  = gx.rgb(10, 100, 10)
    //  this case's maximum count
    //  I don't know why, but sokol lib allocates graphix obj numbers
    //  may fixed, I think ... 
    //  any idea ? thanks !
    iter_count   = 12000
)

//  font contexts
const (
    text_cfg = gx.TextCfg {
        align:gx.align_left
        size:16
        color:gx.black
    }
)

//  
fn main() {
    // get font file path
    // 'cause font allocates when gg context generates.
    font_p := font.default()

    mut graph := &Graph {
        gg: 0  // place holdre for graphix context
        dx: 2
        dy: 2
        height: window_height
        width:  window_width
        draw_fn: 0
        vui_font_p: false
    }
    graph.gg = gg.new_context(
        width: window_width
        height: window_height
        use_ortho: true
        user_data: graph
        window_title: 'Iterative Fern graphics with V new graphix handling.'
        create_window: true
        frame_fn: frame
        keydown_fn: on_keydown
        font_path: font_p
        bg_color: gx.white
    )

    if os.getenv('VUI_FONT') != '' {
        graph.vui_font_p = true
    }

    graph.generate()

    println('Starting the graph loop...')
    // main graphix obj placing thread .
    go graph.run()
    //  gg.run() calls frame_fn (and maybe calls event_fn )
    graph.gg.run()
}

//  frame rate (fps) and some info reports
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
    graph.gg.begin()
      graph.draw_piccells()
      graph.draw_texts()
    graph.gg.end()
}

//  
fn (mut graph Graph) run() {
    for {
//  to activate showfps feature, use -d option like as '-d showfps'
$if showfps ? {
        graph.showfps()
}
        time.sleep(34*time.millisecond) // 30fps
    }
}

//  
fn (g &Graph) draw_piccells() {
    for j in 0..window_height {
        for i  in 0..window_width {
            if g.cells[i][j] == 1 {
                g.gg.draw_rect_filled(f32(i), f32(j), block_size-1, block_size-1, leaf_colour)
            }
        }
    }
}

//
fn (mut g Graph) draw_texts() {

    if g.vui_font_p {
//        g.gg.draw_text(20, 30, 'シダの葉グラフィクス (V new Graphix handling)', text_cfg)
        g.gg.draw_text(20, 30, 'Графика листьев папоротника (V new Graphix handling)', text_cfg)
    } else {
    g.gg.draw_text(20, 30, 'Iterative fern graphix (V new Graphix handling)', text_cfg)
    }
}

// cell array generates
fn (mut g Graph) generate() {
    mut x  := f64(0)
    mut y  := f64(0)
    mut px := f64(0)
    mut py := f64(0)
    mut cnt := 0
    print('generate, ')
    // initialize cell space
    for _ in 0..window_width {
        g.cells << [0].repeat(window_height)
    }

    for cnt < iter_count {
        cnt++
        r := rand.f64()
        if r < 0.01 {
            x = 0.0
            y = 0.16 * py
        }
        if r >= 0.01 && r < 0.07 {
            x = 0.2  * px - 0.26 * py
            y = 0.23 * px + 0.22 * py + 1.6
        }
        if r >= 0.07 && r < 0.15 {
            x = -0.15 * px + 0.28 * py
            y =  0.26 * px + 0.24 * py + 0.44
        }
        if r >= 0.15 {
            x =  0.85 * px + 0.04 * py
            y = -0.04 * px + 0.85 * py + 1.6
        }
        px, py = x, y
        /*  set pic-cell colour on  */
        i := int((py - y_min) / (y_max - y_min) * window_width)
        j := window_height - int((x_max - px) / (x_max - x_min) * window_height)
        g.cells[i][j] = 1
    }
    println('generated ')
}

//  key events
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
