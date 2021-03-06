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

// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// need ? DK ...
// module main

import os
import gx
import gg
import time
//import sokol.sapp  // for key handlin'
import rand


struct Graph {
mut:
    gg       &gg.Context
    x        []f32    //  stars coords
    y        []f32
    z        []f32
    height   int
    width    int
    draw_fn  voidptr

    font_loaded bool
    vui_font_p  bool   //  VUI_FONT used ? for Japanese string using

    // frame/time counters for showfps()
    frame int
    frame_old int
    frame_sw  time.StopWatch = time.new_stopwatch({})
    second_sw time.StopWatch = time.new_stopwatch({})

}

//  window parameters
const (
    window_width  =  1920  //  set screen pixel for fullscreen
    window_height =  1280  //  set screen pixel for fullscreen
    window_depth  =   400  //  (as you like)
    space_width   = 20000  //  
    space_height  = 20000
    space_depth   = 10000
    
    stars  = 1000  //  allocate stars
)

//  font contexts
const (
    text_cfg = gx.TextCfg {
        align:gx.align_left
        size:16
        color:gx.white
    }
)

//  
fn main() {
    // get font file path
    // 'cause font allocates when gg context generates.
    font := gg.system_font_path()

    mut graph := &Graph {
        gg: 0  // place holdre for graphix context
        height: window_height
        width:  window_width
        draw_fn: 0
    }
    graph.gg = gg.new_context({
        width:  window_width
        height: window_height
        use_ortho: true
        user_data: graph
        window_title: 'Stardust.v - Graphix app example'
        create_window: true
        frame_fn: frame
        keydown_fn: on_keydown
        font_path: font
        bg_color: gx.black
        fullscreen: true  // set window_with, window_height as screen size
    })
    
    //  is VUI_FONT set ? for message selecting
    graph.vui_font_p = if os.getenv('VUI_FONT') != '' {
        true
      } else {
        false
      }

    //  
    for _ in 0..stars {
        graph.x << rand.f32_in_range(-space_width /2, space_width /2)
        graph.y << rand.f32_in_range(-space_height/2, space_height/2)
        graph.z << rand.f32_in_range(window_depth, space_depth)
    }

    println('Starting the graph loop...')
    // main graphix obj placing thread .
    go graph.run()
    //  gg.run() calls frame_fn (and maybe calls event_fn )
    graph.gg.run()
}

//  frame rate (fps) and some info reports
//[if showfps]
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

// Graphix placing
fn frame (mut graph Graph) {

    graph.frame_sw.restart()

    graph.gg.begin()

      for c in 0..stars {
        graph.gg.draw_rect(
          window_width /2 + graph.x[c]*window_depth/graph.z[c], 
          window_height/2 - graph.y[c]*window_depth/graph.z[c], 
          2, 2, gx.white)
      }
      graph.draw_texts()

    graph.gg.end()
}

// 
fn (mut graph Graph) update_model() {

    for c in 0..stars {
      graph.z[c] = graph.z[c] - 20
      if graph.z[c] <= 1 {
        graph.x[c] = rand.f32_in_range(-space_width /2, space_width /2)
        graph.y[c] = rand.f32_in_range(-space_height/2, space_height/2)
        graph.z[c] = space_depth
      }
    }

}

//  
fn (mut graph Graph) run() {
    for {
        graph.update_model()
        graph.showfps()
//        time.sleep_ms(34) // 30fps
        time.wait(34*time.millisecond) // 30fps
    }
}

//
fn (mut g Graph) draw_texts() {
    if g.vui_font_p == true {
        g.gg.draw_text(30, 8, '宇宙 ... それは人類に残された最後の開拓地である', text_cfg)
    } else {
        g.gg.draw_text(30, 8, 'Space ... The final frontier', text_cfg)
    }
}

//  event handler ?


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
        else {}
    }
}
