#
# title : minidom-disin.py 
# begin : 2024-02-10 19:54:07 
# note  : minidom でXML をハンドルする手段の研究

# ライブラリのインポート
import xml.dom.minidom
import urllib.request


# 取得する XML ファイルの URL 気象庁のfeed
url = "https://www.data.jma.go.jp/developer/xml/feed/eqvol.xml"


#  url から、個別の地震についての情報を出力する
def info(url) :
    # URL にある XML ファイルを取得しそれを文字列として格納
    r = urllib.request.Request(url)
    with urllib.request.urlopen(r) as res:
        xml_text = res.read().decode()

    #  parse操作
    dom = xml.dom.minidom.parseString(xml_text)

    #  'entry' タグの文書部分を総なめするループ
    for entry in dom.getElementsByTagName('Body'):

        #  震源座標と深さ
        info = entry.getElementsByTagName('jmx_eb:Coordinate')
        if info != [] :
            if info[0].hasAttribute('description') : 
                print('Info : ' + info[0].getAttribute('description'))

        #  マグニチュード
        info = entry.getElementsByTagName('jmx_eb:Magnitude')
        if info != [] :
            #print('url  : ' + info[0].firstChild.data)
            if info[0].hasAttribute('description') : 
                print('Magn : ' + info[0].getAttribute('description'))

        #  地域
        for hypoinfo in entry.getElementsByTagName('Hypocenter') :
            info = hypoinfo.getElementsByTagName('Name')
            if info != [] :
                print('Area : ' + info[0].firstChild.data)
                if info[0].hasAttribute('description') : 
                    print('attr : ' + info[0].getAttribute('description'))


#  main part

# URL にある XML ファイルを取得しそれを文字列として格納
r = urllib.request.Request(url)
with urllib.request.urlopen(r) as res:
    xml_text = res.read().decode()

#  parse操作
dom = xml.dom.minidom.parseString(xml_text)
print('... parsed')

#  各記事の括りは「entry」tag で行われているので、
#  それを抽出するッ
for entry in dom.getElementsByTagName('entry'):

    # タイトル
    ti = entry.getElementsByTagName('title')
    print('Head : ' + ti[0].firstChild.data)
    if ti[0].hasAttribute('desc') : 
      print('attr : ' + ti[0].getAttribute('desc'))

    # 発報日時
    dat = entry.getElementsByTagName('updated')
    print('Date : ' + dat[0].firstChild.data)
    if dat[0].hasAttribute('desc') : 
      print('attr : ' + dat[0].getAttribute('desc'))

    # 情報本文
    bd = entry.getElementsByTagName('content')
    print('Body : ' + bd[0].firstChild.data)
    if bd[0].hasAttribute('desc') : 
      print('attr : ' + bd[0].getAttribute('desc'))

    # link
    id = entry.getElementsByTagName('id')
    link = id[0].firstChild.data
    info(link)
    print('link : ' + link)

    print('///')

