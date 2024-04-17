/* 
 * title : Heart_Curve.v - new graphix code template
 * begin : 2021-02-21 02:15:35 
 * base  : Shida_no_Ha.v
 * build : v run Heart_Curve.v
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
import math
import math.complex as cmplx
import time
import term



const (
// Window coords
    x_min = -3.2
    x_max =  3.2
    y_min = -2.4
    y_max =  2.4
    block_size    = 3
    window_width  = 640
    window_height = 480
    width = 50
    heart_colour  = gx.rgb(200, 10, 10)
    //
    iter_count   = 5000
)

//  font file locations for several env ...
//  truetype collection font is not for use.
const (
   font_files = [
        os.getenv('HOME')+'/.local/share/fonts/NotoSansCJKjp-Regular.otf' ,
        os.getenv('HOME')+'/Library/Fonts/NotoSansCJKjp-Regular.otf',
        'NotoSansCJKjp-Regular.otf' ,
        'DroidSerif-Regular.ttf',
    ]
)

//  font contexts
const (
    text_cfg = gx.TextCfg {
        align:gx.align_left
        size:16
        color:gx.rgb(0, 0, 0)
    }
)

struct Graph {
mut:
    // graphics pic-cell array
    coord_x     []f32
    coord_y     []f32

    gg       &gg.Context
    loopie   int
    height   int
    width    int

    // frame/time counters for showfps()
    frame int
    frame_old int
    frame_sw  time.StopWatch = time.new_stopwatch()
    second_sw time.StopWatch = time.new_stopwatch()

}

//  font file loading
fn alloc_font() string {
    //  font file locations for several env ...
    fpath := font_files.clone()

    //  font searching
    mut jp_font := os.getenv('VUI_FONT')

    if jp_font != '' { 
        println('font file $jp_font from env VUI_FONT')
        return jp_font 
    }

    for f in fpath {
        stat := os.exists(f)
        match stat {
          true {
            print(term.ok_message  ('[ OK ]'))
          }
          false {
            print(term.fail_message('[FAIL]'))
          }
//          on 0.2.1, empty else caluse in match struct is not necessary.
//          else { }
        }
        println(' $f')
        
        if stat { 
            jp_font = f
            println('Get font file Nooooow !')
            break 
        }
    }

 //   println('loadin fonts as ${graph.gg.config.font_path}')
 println('$jp_font')
    return jp_font
}

//  
fn main() {
    // get font file path
    // 'cause font allocates when gg context generates.
    font := alloc_font()

    mut graph := &Graph {
        gg: unsafe { 0 }  // place holdre for graphix context
        height: window_height
        width:  window_width
    }
    graph.gg = gg.new_context(
        width: window_width
        height: window_height
        user_data: graph
        window_title: 'Heart function graphics with V.'
        create_window: true
        frame_fn: frame
		keydown_fn: on_keydown
        font_path: font
        bg_color: gx.white
    )
println('fooont::$font')
    graph.generate()

    println('Starting the graph loop...')
    // main graphix obj placing thread .
    go graph.run()
    //  gg.run() calls frame_fn (and maybe calls event_fn )
    graph.gg.run()
}

//  frame rate (fps) and some info reports
//  this feature activate with commenting out follow line.
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
    //graph.ft.flush()
    graph.frame_sw.restart()

    graph.gg.begin()
      graph.draw_piccells()
      graph.draw_texts()
    graph.gg.end()
}

//  
fn (mut graph Graph) run() {
    for {
$if showfps ? {
        graph.showfps()
}
        time.sleep(34*time.millisecond) // 30fps
    }
}

//  draw line array generated
fn (g &Graph) draw_piccells() {
    for i in 0..iter_count-1 {
        if g.coord_x[i] >= 0 && g.coord_x[i+1] >= 0 {
            g.gg.draw_line(g.coord_x[i], g.coord_y[i], g.coord_x[i+1], g.coord_y[i+1],  heart_colour)
            g.gg.draw_line(g.coord_x[i]+1, g.coord_y[i], g.coord_x[i+1]+1, g.coord_y[i+1],  heart_colour)
        }
    }
}

//  Caption text
fn (mut g Graph) draw_texts() {
    g.gg.draw_text(20, 30, 'Heart function graphics with LO\'V\'E', text_cfg)
}

// function draw array generates
fn (mut g Graph) generate() {
    g.loopie = 0
    mut x  := f64(0)
    mut y  := cmplx.complex(0, 0)

    mut cnt := 0
    print('generate, ')
    //  allocate array space
    g.coord_x << [f32(-1)].repeat(iter_count)
    g.coord_y << [f32(-1)].repeat(iter_count)
    
    for cnt < iter_count {
        cnt++
        i := cnt * f32(window_width) / iter_count
        x = x_min + f64(x_max - x_min) * i / window_width
        // y = (cmath.sqrt(cmath.cos(x))*cmath.cos(400*x)+cmath.sqrt(abs(x))-0.4) * pow((4-x*x), 0.1) 
        t := cmplx.complex(x, 0).cos().root(2) *  
             cmplx.complex(400*x, 0).cos() + 
             cmplx.complex(math.abs(x), 0).root(2) - 
             cmplx.complex(0.4, 0)
        y = t * cmplx.complex(4-x*x, 0).pow(0.1) 
        j := f32((y_max - y.re)*window_height/(y_max - y_min))
        if math.abs(y.im) <= 0.00001 {
            g.coord_x[cnt] = i
            g.coord_y[cnt] = j
        }

    }
    println('generated ')
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
