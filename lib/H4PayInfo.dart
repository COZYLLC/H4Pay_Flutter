import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Seller.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class HyperLinkText extends StatelessWidget {
  final String text;
  final String url;

  const HyperLinkText({Key? key, required this.text, required this.url})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(text, style: TextStyle(decoration: TextDecoration.underline)),
      onTap: () {
        launch(url);
      },
    );
  }
}

class H4PayInfoPage extends StatefulWidget {
  @override
  H4PayInfoPageState createState() => H4PayInfoPageState();
}

class H4PayInfoPageState extends State {
  List<Map>? infos;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<List<Map>> _fetchInfos() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    Seller seller = Seller(
      name: "서전고 사회적협동조합",
      ceo: "안상희",
      address: "충북 진천군 덕산읍 대하로 47",
      tel: "043-537-8737",
      businessId: "564-82-00214",
      sellerId: "2021-충북진천-0007",
    );
    return infos = [
      {'type': 'version', 'text': "버전: $version"},
      {
        'type': 'alert',
        'text': "COZY 정보",
        'content': [
          Text("COZY 대표: 송치원"),
          HyperLinkText(text: "Tel: 010-6795-8358", url: "tel://010-6795-8358"),
          Text("Fax: 0508-941-8358"),
          Text("사업자등록번호: 619-88-02154"),
          Text(""),
          HyperLinkText(
            text: "인스타그램: cozyllc",
            url: "https://www.instagram.com/cozyllc/",
          ),
          HyperLinkText(
            text: "카카오채널: cozyllc",
            url: "http://pf.kakao.com/_xlJCks",
          ),
          HyperLinkText(
            text: "홈페이지: https://cozyllc.co.kr",
            url: "https://cozyllc.co.kr",
          ),
        ]
      },
      {
        'type': 'route',
        'text': "이용약관",
        'content': WebViewScaffold(
          initialUrl: "https://h4pay.co.kr/law/terms.html",
        ),
      },
      {
        'type': 'route',
        'text': "개인정보 처리방침",
        'content': WebViewScaffold(
            initialUrl: "https://h4pay.co.kr/law/privacyPolicy.html")
      },
      {
        'type': 'route',
        'text': "오픈소스 라이선스",
        'content': LicensePage(
          applicationName: "H4Pay",
          applicationVersion: packageInfo.version,
        )
      },
      {
        'type': 'alert',
        'text': '${seller.name} 사업자 정보',
        'content': [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: seller.name),
                TextSpan(text: seller.ceo)
              ],
            ),
          ),
          Text("주소: ${seller.address}"),
          Text("Tel: ${seller.tel}"),
          Text("사업자등록번호: ${seller.businessId}"),
          HyperLinkText(
            text: "통신판매업신고: ${seller.sellerId}",
            url:
                "https://ftc.go.kr/www/bizCommView.do?key=232&apv_perm_no=2021445011930200007&pageUnit=10&searchCnd=apv_perm_mgt_no&searchKrwd=2021%EC%B6%A9%EB%B6%81%EC%A7%84%EC%B2%9C0007&pageIndex=1",
          )
        ],
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("H4Pay 정보 보기"),
      ),
      body: FutureBuilder(
        future: _fetchInfos(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Map> infos = snapshot.data as List<Map>;
            return SingleChildScrollView(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(80),
                    child: Image.asset("assets/image/H4pay.png"),
                  ),
                  ListView.builder(
                    itemCount: infos.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (infos[index]['type'] == 'version') {}
                      return CardWidget(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Text(infos[index]['text']),
                        onClick: () {
                          if (infos[index]['content'] != null) {
                            if (infos[index]['type'] == "alert") {
                              showCustomAlertDialog(
                                context,
                                infos[index]['text'],
                                infos[index]['content'],
                                [
                                  H4PayButton(
                                    text: "닫기",
                                    onClick: () {
                                      Navigator.pop(context);
                                    },
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    width: double.infinity,
                                  )
                                ],
                                true,
                              );
                            } else if (infos[index]['type'] == "route") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => infos[index]['content'],
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  )
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
