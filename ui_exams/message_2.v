/* 
 * title : message_2.v - dialog box example
 * begin : 2020-06-25 04:26:32 
 * note  : dialog box with button callback and event loops
 *       : 
 *       : this code includes Japanese character string,
 *       : so, works with environment variable 'VUI_FONT'
 *       : to set Japanese font file like as follows :
 *       :   ex. export $VUI_FONT=~/.local/share/fonts/NotoSans-Regular.ttf
 *       :     or
 *       :   ex. VUI_FONT=~/.local/share/fonts/NotoSans-Regular.ttf v run message_2.v
 *       : 
 *       : 
 */


//import os
import ui

const (
    win_width = 300
    win_height = 55
    //  currently ttc (truetype collection font) is not avaioable in v
//    font_path  = '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc'
)

struct App {
mut:
    counter string = '10'
    window  &ui.Window
}

fn main() {

//   os.setenv('VUI_FONT', font_path, true)

    mut app := &App{
        window: 0
    }
    app.window = ui.window( {
        width: win_width
        height: win_height
        title: '宇宙からのメッセージ ...'
        state: app
    }, 
      [
        ui.column(    // column (and row) widget like as Box widget in Xaw ...
          {
            width: win_width
            spacing: 10
            alignment: .center
          }, [

//    ui.message_box('Hello World')
            ui.label(
                text: '終了するには、以下を10回押して下さい'
            )
            ui.button(
                text: '10 回、押して'
                onclick: btn_count_click
            )
          ]
        )
      ]
    )

    //  app loop
    ui.run(app.window)

}

//  button callback
fn btn_count_click(mut app &App, mut btn &ui.Button) {
    app.counter = (app.counter.int() - 1).str()
    if btn.text == '   Quit' {
      println('Just quit this client ... thanks !')
      exit(0)
    }
    btn.text = '${app.counter.int()}  回、押して'
    if app.counter.int() <= 0 {
      btn.text = '   Quit'
    }
}
