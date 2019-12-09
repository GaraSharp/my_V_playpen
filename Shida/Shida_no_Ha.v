// title : Shida_no_Ha.v 
// begin : 2019-09-06 21:38:31  
// note  : draw シダの葉 in V
// base  : biomorph.v 

// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.  

import rand
import time
import gx 
import gl
import gg
import glfw
import freetype


const (
  //  Window coords
  X_min     = -3.0
  X_max     =  3.0
  Y_min     = -0.5
  Y_max     = 11.0

  BlockSize = 2
  WinWidth  = 1150   // window size
  WinHeight = 600
  TimerPeriod = 2500 // ms

  BakColour = 240
  IterCount = 500000
)

//  addition on 2019-09-17 03:12:04 
const (
  TextSize = 12
)

const (
  text_cfg = gx.TextCfg{
    align:gx.ALIGN_LEFT
    size:TextSize
    color:gx.rgb(0, 0, 0)
  }
)

//  Fern graphics canvas
struct Graph {
  mut:
  // graphics pic-cell array
  cells  [][]int

  // gg context for drawing
  gg     &gg.GG

    // ft context for font drawing
  ft          &freetype.FreeType
  font_loaded bool
}


fn main() {
  glfw.init_glfw()  //  change on 2019-10-12 19:49:38 
  mut graph := &Graph {
    gg: gg.new_context(gg.Cfg {  //  graphix contexts
      width:  WinWidth
      height: WinHeight
      use_ortho: true   // This is needed for 2D drawing
      create_window: true
      window_title: 'Recursive Fern graphics with V'
      window_user_ptr: graph 
    })
    ft: 0  //  evasive warning : pointer field `Graph*.ft` must be initialized
  } 

  println('window size : $WinWidth x $WinHeight')

  graph.gg.window.set_user_ptr(graph) // TODO remove this when `window_user_ptr:` works 
  graph.gg.window.onkeydown(key_down)  // MEMO : key event set

  // Try to load font
  graph.ft = freetype.new_context(gg.Cfg{
      width:  WinWidth
      height: WinHeight
      use_ortho: true
      font_size: 30
      scale: 2
      window_user_ptr: graph //  evasive warning : pointer field `gg.Cfg.window_user_ptr` must be initialized


  })
  graph.font_loaded = (graph.ft != 0 )

  graph.generate()

  go graph.run() // Run the graph loop in a new thread

  gl.clear_color(BakColour, BakColour, BakColour,  255)
  gl.clear()
  graph.gg.render() 

  // MEMO : main loop ; Window Realize, Map, and Quit
  for {
    gl.clear()
    gl.clear_color(BakColour, BakColour, BakColour,  255)

    //  clear and draw graph
    graph.draw_scene()
    //  render() で画像表示とイベント待ち。らしい ?
    graph.gg.render() 

    if graph.gg.window.should_close() {
      graph.gg.window.destroy()
      return 
    }

    time.sleep_ms(TimerPeriod)
//        println('Sleep !')
  }
}

//  no used ...
fn (g &Graph) init_graph() {

  rand.seed(time.now().uni)
}

//  cell array generates
fn (g mut Graph) generate() {

  print('generate, ')

  //  initialize cell space
  for i:=0; i < WinWidth; i++ {
    g.cells << [0].repeat(WinHeight)
  }

  mut x  := f64(0)
  mut y  := f64(0)
  mut px := f64(0)
  mut py := f64(0) 

  mut cnt := 0

  for cnt < IterCount {
    cnt ++
    // C.RAND_MAX means RAND_MAX in C
    r := f64(rand.next(C.RAND_MAX))/C.RAND_MAX
    if r < 0.01 {
      x = 0.0
      y = 0.16*py
    }
    if r >= 0.01 && r < 0.07 {
      x = 0.2*px  - 0.26*py
      y = 0.23*px + 0.22*py + 1.6
    }
    if r >= 0.07 && r < 0.15 {
      x = -0.15*px + 0.28*py
      y =  0.26*px + 0.24*py + 0.44
    }
    if r >= 0.15 {
      x =   0.85*px + 0.04*py
      y =  -0.04*px + 0.85*py + 1.6
    }
    px = x
    py = y

    /*  set pic-cell colour on  */
    i := int((py-Y_min)/(Y_max-Y_min)*WinWidth)
    j := WinHeight-int((X_max-px)/(X_max-X_min)*WinHeight)
    mut tmp := g.cells[i]
    tmp[j] = 1
  }
  println('generated ')
}


//  MEMO : main graph loop thread
fn (g &Graph) run() {
  for {
    glfw.post_empty_event() // force window redraw
    time.sleep_ms(TimerPeriod)
  }
}


fn (g &Graph) draw_curve() {
  for j := 0; j < WinHeight; j++ {
    for i := 0; i < WinWidth; i++ {
      tmp := g.cells[i]
      if tmp[j] == 1 {
        g.gg.draw_rect(i, j,
          BlockSize-1, BlockSize-1, gx.rgb(10, 100, 10))
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

//  以下のkey_down() では、キー入力で、ESCキーの場合に
//  glfw.set_shoulkd_close を true にする、らしい

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
  // Fetch the graph object stored in the user pointer
  match key {
    glfw.KEY_ESCAPE {
      glfw.set_should_close(wnd, true)
      println('key detections')
    }
    else { }
  }
}

