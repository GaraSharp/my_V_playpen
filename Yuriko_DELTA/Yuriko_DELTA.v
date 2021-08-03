// title : Yuriko_DELTA.v - 
// begin : 2021-07-29 22:45:44 
// note  : 東京都の変異株情報を取得し、データ出力する


import net.http
import json
import os

const (
  //  東京都のコロナウィルス変異株情報のgithubデータのアドレス
  data_url = 'https://raw.githubusercontent.com/tokyo-metropolitan-gov/covid19/development/data/variants.json'
  file_name = 'variant.dat'
)

//  データ構造

struct File {
    date      string
    datasets  []Date_item
}

struct Date_item {
    period  Period
    data    Data
}

struct  Period {
    begin  string
    end    string
}

struct Data {
    l452r               Delta
    variant_test_count  int
    variant_pcr_rate    f64
    negative_rate       f64
}

struct  Delta {
    positive_count  int
    positive_rate   f64
}

//  main だよ
fn main() {

  data := http.get_text(data_url) .to_lower()
//println('text - $data')

  datum := json.decode(File, data) or { eprintln ('cannot')  return }
//println(datum)

  mut indep  := []f64{}
  mut depend := []f64{}
  mut idx    := 1

  for item in datum.datasets {
    positive := item.data.l452r.positive_count
    total    := item.data.variant_test_count
    rate     := f64(positive)/total
    println('*** $item.period.begin')
    println('  variant_test_count ; $total')
    println('  positive_count     ; $positive')
    println('  positive_rate      ; $rate')

    if rate != 0 {
      indep  << idx
      depend << rate
      idx += 1
    }
  }

  println('indep   ; $indep')
  println('depend  ; $depend')

  mut f_out := os.create(file_name) or { panic(err) }
  for i in 0..(indep.len) {
     f_out.writeln('${indep[i]}  ${depend[i]}') ?
  }
  f_out.close()

}

