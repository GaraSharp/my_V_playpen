// title : Biom.v 
// begin : 2019-09-06 21:38:31  
// note  : draw Pickovers' Biomorph with V
// base  : graphix_1.v

// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.  

import rand
import time
import gx 
//import gl
import oldgg as gg
import glfw
import math
import math.complex as cmplx


const (
  //  Window coords
  x_min     = -3.2
  x_max     =  3.2
  y_min     = -2.4
  y_max     =  2.4

  block_size   = 2
  win_width    = 960   // window size
  win_height   = 720
  pic_colour   = gx.rgb(0, 0, 240)
  bak_colour   = gx.rgb(240, 240, 240)
  timer_period = 250 // ms
)

//  running status 
enum Staten {
  newparam display
}

//  'biomorph' canvas
struct Graph {
  mut:
  // pic-cell array
  cells   [][]int

  // gg context for drawing
  gg      &gg.GG
  state   Staten
}

fn main() {
  glfw.init_glfw()

  gconfig := gg.Cfg {  //  graphix contexts
      width:  win_width
      height: win_height
      use_ortho: true   // This is needed for 2D drawing
      create_window: true
      window_title: 'Pickovers\' Biomorph with V'
  }

  mut graph := &Graph {
    gg: gg.new_context(gconfig)
    state: .display
  }

  println('Window size : $win_width x $win_height')

  graph.gg.window.set_user_ptr(graph) // TODO remove this when `window_user_ptr:` works 
  graph.gg.window.onkeydown(key_down)  // MEMO : key event set

  graph.init_cell()

  go graph.run() // Run the graph loop in a new thread

  graph.generate()
  //  draw graphix twice for double buffer like behaviour ...
  for _ in 0..2 {
    gg.clear(bak_colour)
    graph.draw_scene()
    graph.gg.render() 
  }

  // MEMO : main loop ; Window Realize, Map, and Quit
  for {
    //  render and event wait (?)
    graph.gg.render() 

    if graph.gg.window.should_close() {
      graph.gg.window.destroy()
      return 
    }
    
    if graph.state == .newparam {
        println('... redraw()')
        graph.generate()
        for _ in 0..2 {
          gg.clear(bak_colour)
          graph.draw_scene()
          graph.gg.render()
        }
        graph.state = .display
    }
    time.sleep_ms(timer_period)
  }
}

//  no used ...
fn (g  Graph) init_graph() {
  rand.seed(int(time.now().unix))
}

//  initialize cell space
fn (mut g Graph) init_cell() {
  for i := 0; i < win_width; i++ {
    g.cells << [0].repeat(win_height)
  }
}

//  Hot code reloading 
//  for change constant and iteration form dynamicaly
[live]
fn (mut g Graph) generate() {

  print('generate, ')

  mut x := f64(0)
  mut y := f64(0)
  mut z := cmplx.complex(x, y)
  //  constant - changing makes graphics changed
  c := cmplx.complex(-0.25, -0.5)

  for j := 0; j < win_height; j++ {
    for i := 0; i < win_width; i++ {
      x = f64(i)*(x_max-x_min)/win_width +x_min
      y = f64(j)*(y_min-y_max)/win_height+y_max
      z = cmplx.complex(x, y)
      //  iteration part
      mut k := 0
      for {
        // iteration forms
        // modify these lines as you like ...
        z = z*z*z*z*z + z*z*z + c
        z = z.sin()+z*z - c
//         z = z.cos().cos() + c
        z = (z*z*z*z+z*z+c)/z
        k++
        if k > 10 || z.abs() >= 10 { break }
      }

      // set piccell on condition
      g.cells[i][j] = if math.abs(z.re) < 10 || math.abs(z.im) < 10 { 1 } else { 0 }
    }
  }
  println('generated ')
}

//  MEMO : main graph loop thread
fn (mut g Graph) run() {
  for {
    glfw.post_empty_event() // force window redraw
    time.sleep_ms(timer_period)
//    println('run()')
  }
}

//  
fn (mut g Graph) draw_curve() {
  for j := 0; j < win_height; j++ {
    for i := 0; i < win_width; i++ {
      if g.cells[i][j] == 1 {
          g.gg.draw_rect(f32(i), f32(j),
          block_size-1, block_size-1, pic_colour)
      }
    }
  }
}

//  
fn (mut g Graph) draw_scene() {
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
  mut graph := &Graph(glfw.get_window_user_pointer(wnd))
  
  match key {
    (glfw.key_escape) {
      glfw.set_should_close(wnd, true)
      println('ESC key for exit this programm')
    }
    (glfw.key_space) {
      graph.state = .newparam
      println('space bar for redraw new form in [live] ')
    }
    else { }
  }
}

