// title : ticks.v - error handling exam.
// begin : 2023-09-02 02:45:51 

import os
import time


//  unix ticks -> time string
fn ticks_str(tval i64) string {
  date_p := time.date_from_days_after_unix_epoch(int(tval / (24*3600)))
  mut hh := tval % (24*3600)
  ss  :=  hh % 60
  hh = hh / 60 
  mm  :=  hh % 60
  hh = hh / 60 

  return '${date_p.year}-${date_p.month:02d}-${date_p.day:02d} ${hh:02d}:${mm:02d}:${ss:02d}'
}


fn main() {

  for i in 1..(os.args.len) {
    print('[$i] : ${os.args[i]} ... ')
    //  Result型の返戻値で、エラーハンドルの分岐処理
    //  else 節がエラー時の処理となる
    if mut tval := time.parse(os.args[i]) {
      //  time string -> UNIX tick
      println('$tval.unix')
    } else {
      // UNIX tick -> time string
      println('${ticks_str(os.args[i].i64())}')
    }
  }
}

