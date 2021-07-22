// title : Han_Zen.v - Filtre Alpha-Numeric lettre to 'Zenkaku' lettre
// begin : 2021-07-18 22:10:29 


import os

//  data file
const (
    data_file = 'text.txt'
)


//  hankaku to zenkaku
fn to_zen(ch string) string {
  return match ch {
    '0' { '０' }
    '1' { '１' }
    '2' { '２' }
    '3' { '３' }
    '4' { '４' }
    '5' { '５' }
    '6' { '６' }
    '7' { '７' }
    '8' { '８' }
    '9' { '９' }
    'A' { 'Ａ' }
    'B' { 'Ｂ' }
    'C' { 'Ｃ' }
    'D' { 'Ｄ' }
    'E' { 'Ｅ' }
    'F' { 'Ｆ' }
    'G' { 'Ｇ' }
    'H' { 'Ｈ' }
    'I' { 'Ｉ' }
    'J' { 'Ｊ' }
    'K' { 'Ｋ' }
    'L' { 'Ｌ' }
    'M' { 'Ｍ' }
    'N' { 'Ｎ' }
    'O' { 'Ｏ' }
    'P' { 'Ｐ' }
    'Q' { 'Ｑ' }
    'R' { 'Ｒ' }
    'S' { 'Ｓ' }
    'T' { 'Ｔ' }
    'U' { 'Ｕ' }
    'V' { 'Ｖ' }
    'W' { 'Ｗ' }
    'X' { 'Ｘ' }
    'Y' { 'Ｙ' }
    'Z' { 'Ｚ' }
    'a' { 'ａ' }
    'b' { 'ｂ' }
    'c' { 'ｃ' }
    'd' { 'ｄ' }
    'e' { 'ｅ' }
    'f' { 'ｆ' }
    'g' { 'ｇ' }
    'h' { 'ｈ' }
    'i' { 'ｉ' }
    'j' { 'ｊ' }
    'k' { 'ｋ' }
    'l' { 'ｌ' }
    'm' { 'ｍ' }
    'n' { 'ｎ' }
    'o' { 'ｏ' }
    'p' { 'ｐ' }
    'q' { 'ｑ' }
    'r' { 'ｒ' }
    's' { 'ｓ' }
    't' { 'ｔ' }
    'u' { 'ｕ' }
    'v' { 'ｖ' }
    'w' { 'ｗ' }
    'x' { 'ｘ' }
    'y' { 'ｙ' }
    'z' { 'ｚ' }
    else { ch }
  }
}

//  zen_closo() : convert UTF-8 codepointre base string to Zenkaku string
fn zen_closo(s string) string {
  src := s.runes()
  mut  res := ''
  for i in 0..(src.len) {
    res = res + to_zen(src[i].str())
  }
  return res
}

fn main() {

  //  read from file
  f_data := os.read_lines(data_file) or { panic('File $data_file ist existen nicht.') }
//    println(f_data)

    for i in 0..(f_data.len) {
      println(zen_closo(f_data[i]))
    }

}

