// title : biomorph.v 
// begin : 2019-09-06 21:38:31  
// note  : draw Pickovers' Biomorph in V
// base  : graphix_1.v

// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.  

import rand
import time
import gx 
import gl
import gg
import glfw
import math
import math.complex as cmplx


const (
  //  Window coords
  X_min     = -3.2
  X_max     =  3.2
  Y_min     = -2.4
  Y_max     =  2.4

  BlockSize = 2
  WinWidth  = 640   // window size
  WinHeight = 480
  TimerPeriod = 250 // ms

  BakColour = 240
)

//  'biomorph' canvas
struct Graph {
  mut:
  // pic-cell array
  cells   [][]int

  // gg context for drawing
  gg      &gg.GG
}

fn main() {
  glfw.init_glfw()
  mut graph := &Graph {
    gg: gg.new_context(gg.Cfg {  //  graphix contexts
      width:  WinWidth
      height: WinHeight
      use_ortho: true   // This is needed for 2D drawing
      create_window: true
      window_title: 'Pickovers\' Biomorph with V'
      window_user_ptr: graph 
    })
  } 
  println('Window size : $WinWidth x $WinHeight')

  graph.gg.window.set_user_ptr(graph) // TODO remove this when `window_user_ptr:` works 
  graph.gg.window.onkeydown(key_down)  // MEMO : key event set

  graph.init_cell()

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
    //  render and event wait (?)
    graph.gg.render() 

    if graph.gg.window.should_close() {
      graph.gg.window.destroy()
      return 
    }
    time.sleep_ms(20)
  }
}

//  no used ...
fn (g  Graph) init_graph() {

  rand.seed(time.now().unix)
}

//  initialize cell space
fn (g mut Graph) init_cell() {

  for i := 0; i < WinWidth; i++ {
    g.cells << [0].repeat(WinHeight)
  }
}

//  Hot code reloading 
//  for change constant and iteration form dynamicaly
[live]
fn (g mut Graph) generate() {

  print('generate, ')

  mut x := f64(0)
  mut y := f64(0)
  mut z := cmplx.complex(x, y)
  //  constant - changing makes graphics changed
  c := cmplx.complex(-0.25, -0.5)

  for j := 0; j < WinHeight; j++ {
    for i := 0; i < WinWidth; i++ {
      x = f64(i)*(X_max-X_min)/WinWidth +X_min
      y = f64(j)*(Y_min-Y_max)/WinHeight+Y_max
      z = cmplx.complex(x, y)
      //  iteration part
      mut k := 0
      for {
        // iteration forms
        // modify these lines as you like ...
        z = z*z*z*z + c
//        z = z.sin()+z*z - c
//        z = z.sin().sin() + c
//        z = (z*z*z*z*z+c)/z
        k++
        if k > 10 { break }
        if z.abs() >= 10 { break }
      }

      // set piccell on condition
//      mut tmp := g.cells[i]
//      tmp[j] = if math.abs(z.re) < 10 || math.abs(z.im) < 10 { 1 } else { 0 }
      g.cells[i][j] = if math.abs(z.re) < 10 || math.abs(z.im) < 10 { 1 } else { 0 }
    }
  }
  println('generated ')

}

//  MEMO : main graph loop thread
fn (g mut Graph) run() {
  for {
    g.generate()
    glfw.post_empty_event() // force window redraw
    time.sleep_ms(TimerPeriod)
    println('run()')
  }
}


//  place piccell on screen
fn (g &Graph) draw_piccell(x, y f64, color_idx int) {
  i := (x - X_min)/(X_max - X_min)*WinWidth
  j := (Y_max - y)/(Y_max - Y_min)*WinHeight
  g.gg.draw_rect(i, j,
    BlockSize-1, BlockSize-1, gx.rgb(240, 0, 0))
}

fn (g mut Graph) draw_curve() {

  for j := 0; j < WinHeight; j++ {
    for i := 0; i < WinWidth; i++ {
      // TODO: if g.cells[y][x] != 0
//      tmp := g.cells[i]
//      if tmp[j] == 1 {
      if g.cells[i][j] == 1 {
          g.gg.draw_rect(i, j,
          BlockSize-1, BlockSize-1, gx.rgb(0, 0, 240))
      }
    }
  }
}


fn (g mut Graph) draw_scene() {

  g.draw_curve()
}

//  以下のkey_down() では、キー入力で、ESCキーの場合に
//  glfw.set_shoulkd_close を true にする、らしい

// TODO: this exposes the unsafe C interface, clean up
fn key_down(wnd voidptr, key, code, action, mods int) {
println('key_down()')
// debug ; println('action = $action')
//  action : key-in=1, key-release=0, key-repeat=2
//  so, follow line is キーリピートでもなく、キー押下でもない、
//  キー・リリースの場合には、戻る、ということらしい
  if action != 2 && action != 1 {
    return
  }
  // Fetch the graph object stored in the user pointer
//  mut graph := &Graph(glfw.get_window_user_pointer(wnd))
  match key {
    glfw.KEY_ESCAPE {
//  case GLFW_KEY_ESCAPE:
      glfw.set_should_close(wnd, true)
    }
    else { }
  }
}

