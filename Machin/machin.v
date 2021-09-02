/*
 * title : machin.v - Machin formulae Pi digit calcs with V
 * begin : 2021-09-02 23:18:25 
 * note  : 
 * 
 */

import  math.big

const (
  //  calculation digit size
  digits = 1000
)

fn main() {
  mut sum := big.integer_from_int(0)
  mut term_1 := big.integer_from_int(1)
  mut term_2 := big.integer_from_int(1)
  mut flg := 0
  mut d   := 1

  for _ in 0..digits {
    term_1 = term_1 * big.integer_from_int(10)
  }

  term_2 = term_1 / big.integer_from_int(239)
  term_1 = term_1 / big.integer_from_int(5)

  for term_1 > big.integer_from_int(0) {
    if flg == 0 {
      sum = sum + term_1/big.integer_from_int(d) * big.integer_from_int(4)
      sum = sum - term_2/big.integer_from_int(d)

    } else {
      sum = sum - term_1/big.integer_from_int(d) * big.integer_from_int(4)
      sum = sum + term_2/big.integer_from_int(d)
    }

    term_1 = term_1 / big.integer_from_int(5*5)
    term_2 = term_2 / big.integer_from_int(239*239)
    flg = 1 - flg
    d += 2
  }
    
//  println(term_1)
//  println(term_2)
  println('Pi digits : ')
  println(sum * big.integer_from_int(4))

}

