// title : disin.v - kishouchou XML feed parsing exam.
// begin : 2024-01-04 05:02:35 

import net.http
import encoding.xml

//  feed url kishouchou disin reports
const (
  xml_url =  'https://www.data.jma.go.jp/developer/xml/feed/eqvol.xml'

)

//  xml.XMLNodeContents() から文字列を取り出すインチキ関数
fn get_str(item xml.XMLNodeContents) string {
    return item.str()[21 .. item.str().len-2]
}

//  個別の地震情報 XML から地震の情報を表示する
fn get_info(url string) {
  //  get xml 
  xml_str := http.get(url)  or { panic(err) }

  //  parse it
  doc := xml.XMLDocument.from_string(xml_str.body) or { panic(err) }

  //  震源位置、規模
  coord := doc.get_elements_by_tag('jmx_eb:Coordinate')
  if coord != [] {
      println('Info : ${ coord[0].attributes['description'] }  ')
  }

  //  マグニチュード
  if coord != [] {
    magn := doc.get_elements_by_tag('jmx_eb:Magnitude')
    println('Magn : ${ magn[0].attributes['description'] }')
  }

  //  地域
  area := doc.get_elements_by_tag('Area')[0]
  name := area.get_elements_by_tag('Name')[0].children[0]
  println('Area : ${ get_str(name) }')
}

//  
fn main() {

  //  get xml 
  xml_str := http.get(xml_url)  or { panic(err) }

  //  parse it
  doc := xml.XMLDocument.from_string(xml_str.body) or { panic(err) }
  println('... parsed')

  //  各記事の括りは「entry」tag で行われているので、
  //  それを抽出するッ
  index := doc.get_elements_by_tag('entry')
  for entry in index {

    //  タイトル
    ttl := entry.get_elements_by_tag('title')
    head := get_str(ttl[0].children[0])
    println('head : $head')

    //  発報日付
    date := get_str(doc.get_elements_by_tag('updated')[0].children[0])
    println('Date : ${ date }')

    //  情報本文
    body := get_str(entry.get_elements_by_tag('content')[0].children[0])
    println('body : $body')

    //  link
    link := get_str(entry.get_elements_by_tag('id')[0].children[0])
    get_info(link)
    println('link : $link')

    println('///')
  }

}

