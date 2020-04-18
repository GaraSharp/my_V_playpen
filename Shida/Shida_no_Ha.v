// title : Shida_no_Ha.v
// begin : 2019-09-06 21:38:31
// note  : draw シダの葉 in V
// base  : biomorph.v

// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

//module main

import rand
import time
import term
import strings
import gx
//import gl
import gg
import glfw
import freetype
import os

const (
// Window coords
    X_min = -3.0
    X_max =  3.0
    Y_min = -0.5
    Y_max = 11.0
    BlockSize = 2
    WinWidth  = 1150 // window size
    WinHeight = 600
    TimerPeriod = 2000 // ms
    TextColour = gx.rgb(3, 3, 3)
    LeafColour = gx.rgb(10, 100, 10)
    BakColour  = gx.rgb(240, 240, 240)
    IterCount  = 500000
)
// addition on 2019-09-17 03:12:04
const (
    FontSize = 30
)

const (
    text_cfg = gx.TextCfg{
//        align: gx.ALIGN_LEFT
		align: gx.align_left
        size:  FontSize
        color: TextColour
    }
)
// Fern graphics canvas
struct Graph {
mut:
    // graphics pic-cell array
    cells       [][]int
    // gg context for drawing
    gg          &gg.GG
    // ft context for font drawing
    ft          &freetype.FreeType
    font_loaded bool
}

fn main() {
    // search font places
    // Ubuntu (system wide), Arch (user side), etc ...  
    fils := [
        '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc', 
        os.getenv('HOME')+'/.local/share/fonts/NotoSansCJKjp-Regular.otf' ,
        os.getenv('HOME')+'/Library/Fonts/NotoSansCJKjp-Regular.otf',
        '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc' ,
        'NotoSansCJKjp-Regular.otf' ,
        'DroidSerif-Regular.ttf',
    ]

    //  font searching
    mut jp_font := ''
    for f in fils {
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
            println('Get font file Nooow !')
            break 
        }
    }

    glfw.init_glfw() // change on 2019-10-12 19:49:38

    // new way to set graphics structure on 0.1.26
	gconfig := gg.Cfg {
			width: WinWidth
			height: WinHeight
			use_ortho: true // This is needed for 2D drawing
			create_window: true
			window_title: 'Iterative Fern graphics with V'
	}

	fconfig := gg.Cfg{
			width: WinWidth
			height: WinHeight
			use_ortho: true
			font_path: jp_font
			font_size: 18
			scale: 2
			window_user_ptr: 0
	}

	mut graph := &Graph {
		gg: gg.new_context(gconfig)
		ft: freetype.new_context(fconfig)
	}

    println('window size : $WinWidth x $WinHeight')

    graph.gg.window.onkeydown(key_down) // MEMO : key event set
    // Try to load font
    graph.ft = freetype.new_context(gg.Cfg{
        font_path: jp_font
        width:  WinWidth
        height: WinHeight
        use_ortho: true
        font_size: FontSize
        scale: 2
    })

    graph.font_loaded = (graph.ft != 0)
    graph.generate()
    go graph.run() // Run the graph loop in a new thread

    gg.clear(BakColour)
    graph.gg.render()
    // MEMO : main loop ; Window Realize, Map, and Quit
    for {
        gg.clear(BakColour)
        // clear and draw graph
        graph.draw_scene()
        // render() で画像表示とイベント待ち。らしい ?
        graph.gg.render()
        if graph.gg.window.should_close() {
            graph.gg.window.destroy()
            return
        }
        time.sleep_ms(TimerPeriod)
        // println('Sleep !')
    }
}

// no used ...
fn (g &Graph) init_graph() {
    rand.seed(time.now().unix)
}

// cell array generates
fn (g mut Graph) generate() {
    mut x  := f64(0)
    mut y  := f64(0)
    mut px := f64(0)
    mut py := f64(0)
    mut cnt := 0
    print('generate, ')
    // initialize cell space
    for i in 0..WinWidth {
        g.cells << [0].repeat(WinHeight)
    }

    for cnt < IterCount {
        cnt++
        // C.RAND_MAX means RAND_MAX in C
        r := f64(rand.next(C.RAND_MAX)) / C.RAND_MAX
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
        px = x
        py = y
        /*  set pic-cell colour on  */
        i := int((py - Y_min) / (Y_max - Y_min) * WinWidth)
        j := WinHeight - int((X_max - px) / (X_max - X_min) * WinHeight)
        g.cells[i][j] = 1
    }
    println('generated ')
}

// MEMO : main graph loop thread
fn (g &Graph) run() {
    for {
        glfw.post_empty_event() // force window redraw
        time.sleep_ms(TimerPeriod)
    }
}

fn (g &Graph) draw_curve() {
    for j in 0..WinHeight {
        for i  in 0..WinWidth {
            if g.cells[i][j] == 1 {
                g.gg.draw_rect(i, j, BlockSize-1, BlockSize-1, LeafColour)
            }
        }
    }
}

fn (g mut Graph) draw_message() {
    if g.font_loaded {
        g.ft.draw_text(100, 50, 'シダの葉グラフィクス', text_cfg)
    }
}

fn (g mut Graph) draw_scene() {
    g.draw_curve()
    g.draw_message()
}

// 以下のkey_down() では、キー入力で、ESCキーの場合に
// glfw.set_should_close を true にする、らしい
// TODO: this exposes the unsafe C interface, clean up
fn key_down(wnd voidptr, key, code, action, mods int) {
    println('key_down()')
    // debug ; println('action = $action')
    // action : key-in=1, key-release=0, key-repeat=2
    // so, follow line is キーリピートでもなく、キー押下でもない、
    // キー・リリースの場合には[戻る]、ということらしい
    if action != 2 && action != 1 {
        return
    }

	// Fetch the game object stored in the user pointer
	mut graph := &Graph(glfw.get_window_user_pointer(wnd))

    // Fetch the graph object stored in the user pointer
    match key {
        (glfw.key_escape) {  // parsing problem ? need parenthesis to embed key code
            // case GLFW_KEY_ESCAPE:
            glfw.set_should_close(wnd, true)
            println('ESC key detections')
        }
        else {}
    }
}

