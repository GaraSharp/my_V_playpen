/* 
 * title : g_frame.v - new graphix code template
 * begin : 2020-06-08 14:08:59 
 * base  : bounce.v, tetris.v
 * build : v run g_frame.v
 *       : or (newer Xcode)
 *       : v -cflags ' -Xlinker -U -Xlinker _objc_loadClassref ' run g_frame.v 
 * cf.   : https://github.com/vlang/v/issues/5069
 * 
 */

// Copyright (c) 2019-2020 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// need ? DK ...
// module main

import os
import gx
import gg
//import gg.ft
import rand
import time
import sokol.sapp  // for key handlin'
import term


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

    // ft context for font drawing
//    ft          &ft.FT = voidptr(0)
//    font_loaded bool

    // frame/time counters for showfps()
    frame int
    frame_old int
    frame_sw  time.StopWatch = time.new_stopwatch({})
    second_sw time.StopWatch = time.new_stopwatch({})

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
    iter_count   = 12300
)

//  font file locations for several env ...
const (
   font_files = [
        '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc', 
        os.getenv('HOME')+'/.local/share/fonts/NotoSansCJKjp-Regular.otf' ,
        os.getenv('HOME')+'/Library/Fonts/NotoSansCJKjp-Regular.otf',
        '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc' ,
        'NotoSansCJKjp-Regular.otf' ,
        'DroidSerif-Regular.ttf',
    ]
)

//  font contexts
const (
    text_cfg = gx.TextCfg {
        align:gx.align_left
        size:16
//        color:gx.black
        color:gx.rgb(0, 0, 0)
    }

)

//  font file loading
fn alloc_font() string {
    //  font file locations for several env ...
    fpath := font_files

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
          else { }
        }
        println(' $f')
        
        if stat { 
            jp_font = f
            println('Get font file Nooooow !')
            break 
        }
    }

//    println('loadin fonts as ${graph.gg.config.font_path}')

    return jp_font
}

//  
fn main() {
    // get font file path
    // 'cause font allocates when gg context generates.
    font := alloc_font()

    mut graph := &Graph {
        gg: 0  // place holdre for graphix context
        dx: 2
        dy: 2
        height: window_height
        width:  window_width
        draw_fn: 0
    }
    graph.gg = gg.new_context({
        width: window_width
        height: window_height
//        font_size: 12
        use_ortho: true
        user_data: graph
        window_title: 'Iterative Fern graphics with V new graphix handling.'
        create_window: true
        frame_fn: frame
//        init_fn:  alloc_font
        event_fn: on_event
        font_path: font
        bg_color: gx.white
    })

    graph.generate()

    println('Starting the graph loop...')
    // main graphix obj placing thread .
    go graph.run()
    //  gg.run() calls frame_fn (and maybe calls event_fn )
    graph.gg.run()
}

//  frame rate (fps) and some info reports
//  this feature activate with commenting out follow line.
[if showfps]
fn (graph &Graph) showfps() {
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
        graph.showfps()
        //glfw.post_empty_event() // Refresh
        time.sleep_ms(17) // 60fps
    }
}

//  
fn (g &Graph) draw_piccells() {
    for j in 0..window_height {
        for i  in 0..window_width {
            if g.cells[i][j] == 1 {
                g.gg.draw_rect(f32(i), f32(j), block_size-1, block_size-1, leaf_colour)
            }
        }
    }
}

//
fn (mut g Graph) draw_texts() {
    g.gg.draw_text(20, 30, 'シダの葉グラフィクス (V new Graphix handling)', text_cfg)
//        println('drawin\' text')
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
        // C.RAND_MAX means RAND_MAX in C
        //r := f64(rand.next(C.RAND_MAX)) / C.RAND_MAX
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


//  キーイベント捕捉 ?
fn on_event(e &sapp.Event, mut graph Graph) {
    //println('code=$e.char_code')
    if e.typ == .key_down {
        graph.key_down(e.key_code)
    }
}


fn (mut graph Graph) key_down(key sapp.KeyCode) {
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
