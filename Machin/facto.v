import  math.big

fn long_f(n int) big.Integer {
  if n == 0 {
    return big.integer_from_int(1)
  } else {
    return big.integer_from_int(n)*long_f(n-1)
  }
}

fn main() {
  println(long_f(100))
}
