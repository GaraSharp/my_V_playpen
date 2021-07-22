// title : generate_tbl.v - 
// begin : 2021-07-18 21:32:06 


fn print_tbl(src string, dst string) {
  str_1 := src.runes()
  str_2 := dst.runes()

  for i in 0..(str_1.len) {
    println('    \'${str_1[i]}\' { \'${str_2[i]}\' }')
  }
}

fn main() {
//  print_tbl(' !#$%&()=~+-*/<>', '　！＃＄％＆（）＝〜＋−＊／＜＞')
  print_tbl('0123456789', '０１２３４５６７８９')
  print_tbl('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ')
  print_tbl('abcdefghijklmnopqrstuvwxyz', 'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ')
  
}

