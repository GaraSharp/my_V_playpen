// 
// title : scr_shot.v
// begin : 2020-07-04 04:29:05 
//

import ui
import os

const (
    png_width  = 1170
    png_height = 655
	win_width  = png_width +20
	win_height = png_height+20
)

struct App {
mut:
	counter string = '0'
	window  &ui.Window = 0
}

fn main() {
	mut app := &App{}
	app.window = ui.window({
		width: win_width
		height: win_height
		title: 'the button'
		state: app
	}, [
		ui.column({
//			alignment: .top
			spacing: 5
			stretch: true
//			margin: ui.MarginConfig{5,5,5,5}
			margin: {top:10,left:10,right:10,bottom:10}
		}, [
			ui.button(
				width:  10
				height: 10
				icon_path: os.resource_abs_path('capt_ex.png')
				text: 'Alt'
				onclick: btn_count_click
			)
			
			]
			
		)
	])
	ui.run(app.window)
}

fn btn_count_click(mut app App, mut btn &ui.Button) {
  app.counter = (app.counter.int() + 1).str()
  println('Button pressed ; $app.counter')
  //  follow line is no effect on 2020-09-01
  btn.icon_path = os.resource_abs_path('logo2.png')
  if app.counter.int() == 10 {
    println('Just pressed for 10 times ! quit this')
    println('Thank you !')
    exit(0)
  }
}


