// title : t-dist.v
// begin : 2021-02-19 19:56:17 
// note  : confidence interval calcs

//  t distribution : 
// pdf(t) = gamma((n+1)/2) / sqrt(n PI) / gamma(n/2) * (1+t^2/n) ^ -(n+1)/2
// n ; m-1 ... freedom, m = numbers of datums

import math
import os

//  data file
const (
    data_file = 'data.dat'
)

//  confidence level
const  conf_level = 0.95

//  machine eps
const  eps = 0.00001

//  t dist probablity density func
fn t_pdf(t f64, n int) f64 {
  k := (f64(n)+1)/2
  return math.gamma(k) / math.sqrt(f64(n)*math.pi) / math.gamma(f64(n)/2) * math.pow((1.0+t*t/f64(n)), -k)
}

//  t cummlative dist func
fn t_cdf(t f64, n int) f64 {
  if t >= 0.0 {
    return t_cd(t, n) + 0.5
  }
    return 0.5-t_cd(-t, n)
}

fn t_cd(t f64, n int) f64 {
  cnt := int(t/eps)
//  := 0
  mut ret  := f64(0)
  for i in 0..cnt {
    x := f64(i)*eps
    ret = ret + eps*t_pdf(x, n)
  }
  return ret
}

//  inverse of t_cdf()
fn inv_t_cdf(y f64, n int) f64 {
  mut x := 0.0
  for {
    if math.abs(t_cdf(x, n) - y) <= eps {
      return x
      }
    x = x - (t_cdf(x, n) - y) / t_pdf(x, n)
  }
  return 0
}


fn main() {
  
  f_data := os.read_lines(data_file) or { panic('File $data_file ist nicht existen.') }

  //  compose data to array
  data:= f_data.map(it.f64())
  
  println('*** datum')
  println(data)
  
  println('numbers of datas = ${data.len}')
  
  //  平均
  mut mean := 0.0
  for _, e in data { 
    mean += e
  }
  mean /= data.len
  println('mean = $mean')
  
  // 不偏分散の平方根
  mut sum_sqrt := 0.0
  for _, e in data { 
    sum_sqrt += (e - mean)*(e - mean)
  }
  sqrt_u := math.sqrt(sum_sqrt / (data.len - 1))
  println('sqrt of unbiased variance = $sqrt_u')
  
  //  t分布値
  freedom := data.len - 1
  a := inv_t_cdf((1.0+conf_level)/2, freedom)

  //  区間推定値
  range := a*sqrt_u/math.sqrt(data.len)
  println('*** confidence interval at $conf_level')
  println('${mean-range} <= u <= ${mean+range}')


}

