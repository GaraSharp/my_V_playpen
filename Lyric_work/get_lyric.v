/* 
 * title : get_lyric.v - 歌詞取得ヘルパー
 * begin : 2025-07-15 16:39:00  
 * note  : uta-net.com 専用
 * 
 */

import net.http
import os

const  file_name = 'jacket.jpg'

//  single quote 除去サービス
fn deq(str string) string {
  mut  res := ''

  for i in 0..str.len {
    c := str[i].ascii_str()
    if c == '\'' {
      return res
    }
    res = res +c
  }
  return res
}


//  
fn main() {

    if os.args.len == 1 {
        println('Usage : get_lyric <url>')
        exit(0)
    }

    mut  mark_str   := ''
    
    // wget from Uta-net.com
    doc := http.get_text(os.args[1])

    //  split read lines to array to get 
    str := doc.split_into_lines()

    //  
    println('\n===  歌詞  ===\n')

    //  search docs 

    //  title 
    // <h2 class="ms-2 ms-md-3 kashi-title">
    mark_str = '<h2 class=\"ms-2 ms-md-3 kashi-title\">'
    for idx in 0 .. str.len {
      msg_ptr := str[idx].index_after(mark_str, 0) or { 0 }
      if msg_ptr > 0 {
        msg := str[idx][msg_ptr+mark_str.len .. ].replace('<br />', '\n').replace('</h2>', '\n')
        print(msg)
      }
    }

    // artist
    //  <span itemprop="byArtist name">
    mark_str = '<span itemprop=\"byArtist name\">'
    for idx in 0 .. str.len {
      msg_ptr := str[idx].index_after(mark_str, 0) or { 0 }
      if msg_ptr > 0 {
        msg := str[idx][msg_ptr+mark_str.len .. ].replace('<br />', '\n').replace('</span></a></h3>', '\n')
        println(msg)
      }
    }

    // Lyricist
    // itemprop="lyricist">
    mark_str = 'itemprop=\"lyricist\">'
    for idx in 0 .. str.len {
      msg_ptr := str[idx].index_after(mark_str, 0) or { 0 }
      if msg_ptr > 0 {
        msg := str[idx][msg_ptr+mark_str.len .. ].replace('<br />', '\n').replace('</a>', '')
        print('作詞 : $msg')
      }
    }

    // Composer
    // itemprop="composer">
    mark_str = 'itemprop="composer\">'
    for idx in 0 .. str.len {
      msg_ptr := str[idx].index_after(mark_str, 0) or { 0 }
      if msg_ptr > 0 {
        msg := str[idx][msg_ptr+mark_str.len .. ].replace('<br />', '\n').replace('</a>', '')
        print('作曲 : $msg')
      }
    }

    // Arranger
    // itemprop="arranger">
    mark_str = 'itemprop="arranger\">'
    for idx in 0 .. str.len {
      msg_ptr := str[idx].index_after(mark_str, 0) or { 0 }
      if msg_ptr > 0 {
        msg := str[idx][msg_ptr+mark_str.len .. ].replace('<br />', '\n').replace('</a>', '')
        print('編曲 : $msg')
      }
    }

    println('')

    //  Kashi
    //  <div id=\"kashi_area\" itemprop=\"text\">
    mark_str = '<div id=\"kashi_area\" itemprop=\"text\">'
    for idx in 0 .. str.len {
      msg_ptr := str[idx].index_after(mark_str, 0) or { 0 }
      if msg_ptr > 0 {
        msg := str[idx][msg_ptr+mark_str.len .. ].replace('<br />', '\n').replace('</div>', '\n')
        println('$msg')
      }
    }

    //  Jackets
    //  background-image: url(
    mark_str = 'background-image: url(\''
    for idx in 0 .. str.len {
      msg_ptr := str[idx].index_after(mark_str, 0) or { 0 }
      if msg_ptr > 0 {
        mut msg := deq( str[idx][msg_ptr+mark_str.len .. ].replace('<br />', '\n').replace('</a>', '') )
        if msg[0..4] == '/res' {
          msg = 'https://www.uta-net.com' + msg
        }
        println('Jacket : $msg')
        //  downloads
        http.download_file(msg, file_name)  ! 
        //os.execute('wget -O $file_name \''+msg+'\'')
      }
    }

}


