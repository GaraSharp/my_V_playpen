// title : peepin_rect.v - gg.draw_image_part() example
// begin : 2024-06-09 16:39:52 
// note  : place default image file on assets/defalut.jpg 
// 

module main

import gg
import gx
//import sokol.sapp  // for mouse cursor handling
import os
import time

const (
    win_width   = 600
    win_height  = 400
    peep_width  = 120
    peep_height = 100
    default_image_file = 'default.jpg'
)

struct App {
mut:
    gg    &gg.Context
    image gg.Image  //  
    coord_x  int    //  place holder for peeping rect x
    coord_y  int    //  place holder for peeping rect y
}

fn main() {
    mut app := &App{
        gg: unsafe { 0 }
        coord_x:  0
        coord_y:  0
    }
    app.gg = gg.new_context(
        bg_color: gx.light_gray
        width: win_width
        height: win_height
        create_window: true
        resizable: true
        window_title: 'peepin Rectangles'
        frame_fn: frame
        keydown_fn: on_keydown
        swap_interval: 2   //  no effect, why ?
        user_data: app
    )

    //  read image from file
    mut image_path := ''
    if os.args.len > 1 {
        image_path = os.resource_abs_path(os.join_path('.', os.args[1]))
    } else {
        image_path = os.resource_abs_path(os.join_path('.', 'assets', default_image_file))
    }
    app.image = app.gg.create_image(image_path) !

    println('Image file   : $image_path')
    println('Image width  : $app.image.width')
    println('Image height : $app.image.height')

    app.gg.run()
}

fn frame(app &App) {
    app.gg.begin()
    app.draw()
    app.gg.end()
    app.gg.show_fps()
}

fn (app &App) draw() {

    app.gg.draw_text_def(200,  20, 'hello world!')
    app.gg.draw_text_def(300,  60, 'привет')
    app.gg.draw_text_def(300,  90, 'привіт')
    app.gg.draw_text_def(300, 120, 'やあ !')

    app.gg.draw_rect_filled(30, 10, 100, 30, gx.blue)
    app.gg.draw_rect_empty(110, 150, 80, 40, gx.black)

    //  frame counter
    app.gg.draw_text(400,20, '${app.gg.frame:06} ',
            size: 30
            color: gg.Color{50, 50, 255, 255}
    )
    
    //  peeping box drawing
    //  destination rect ( window )
    dst := gg.Rect{app.gg.mouse_pos_x, app.gg.mouse_pos_y, peep_width, peep_height}
    //  source rect ( read image from file )
    src := gg.Rect{app.gg.mouse_pos_x*app.image.width /app.gg.width,
                   app.gg.mouse_pos_y*app.image.height/app.gg.height,
                   peep_width *app.image.width /app.gg.width, 
                   peep_height*app.image.height/app.gg.height}
    app.gg.draw_image_part( dst,  src,  app.image )

    time.sleep(30*time.millisecond)
}

//  key events hook
fn on_keydown(key gg.KeyCode, mod gg.Modifier, mut app App) {
    // global keys
    match key {
        .right {
            //  println('right key !')
            app.coord_x = app.coord_x +1
        }
        .left {
            //  println('left key !')
            app.coord_x = app.coord_x -1
        }
        .up {
            //  println('up key !')
            app.coord_y = app.coord_y -1
        }
        .down {
            //  println('down key !')
            app.coord_y = app.coord_y +1
        }
        .escape {
            println('ESC key pressed ... quit')
            exit(0)
        }
        .q {
            println("'q' pressed for ... quit")
            exit(0)
        }
        else {}
    }
}

