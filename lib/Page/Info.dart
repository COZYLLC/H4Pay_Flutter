import 'package:flutter/material.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/dialog/IpChanger.dart';
import 'package:h4pay/main.dart';
import 'package:h4pay/model/School.dart';
import 'package:h4pay/model/User.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

enum InfoType {
  Dialog,
  Route,
  None,
}

class InfoButton extends StatelessWidget {
  final InfoType type;
  final String text;
  final Widget? page;
  final BuildContext? parentContext;
  InfoButton.dialog(
    this.text, {
    this.type = InfoType.Dialog,
    required this.page,
    required this.parentContext,
  });
  InfoButton.route(
    this.text, {
    this.type = InfoType.Route,
    required this.page,
    required this.parentContext,
  });
  InfoButton.none(
    this.text, {
    this.type = InfoType.None,
    this.page,
    this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      margin: EdgeInsets.all(2),
      child: Text(text),
      onClick: () {
        switch (type) {
          case InfoType.Route:
            navigateRoute(context, page!);
            break;
          case InfoType.Dialog:
            showCustomAlertDialog(
              context,
              H4PayDialog(
                title: text,
                content: page!,
                actions: [
                  H4PayOkButton(
                    context: context,
                    onClick: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              true,
            );
            break;
          case InfoType.None:
            break;
        }
      },
    );
  }
}

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

class H4PayInfoPageState extends State<H4PayInfoPage> {
  final H4PayService service = getService();

  _getSchool() async {
    await Future.delayed(Duration(seconds: 1));
    return School(
      name: "서전고등학교",
      id: "M100002171",
      seller: Seller(
        name: "서전고 사회적협동조합",
        address: "충청북도 진천군 덕산읍 대하로 47, 서전고 사회적협동조합",
        founderName: "안상희",
        tel: "043-537-8737",
        businessId: "564-82-00214",
        sellerId: "2021-충북진천-0007",
      ),
    );
  }

  Future<List<InfoButton>> _fetchInfos() async {
    final H4PayUser? user = await userFromStorage();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    if (user == null) {
      showSnackbar(
          context, "사용자 정보를 불러올 수 없습니다.", Colors.red, Duration(seconds: 3));
      return [];
    }

    // School school = (await service.getSchools(id: user.schoolId))[0];
    School school = await _getSchool(); // fake api call
    return [
      InfoButton.none("버전: $version"),
      InfoButton.dialog(
        "COZY 정보",
        page: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("대표: 송치원"),
            HyperLinkText(
                text: "Tel: 010-6795-8358", url: "tel://010-6795-8358"),
            Text("Fax: 0508-941-8358"),
            Text("사업자등록번호: 619-88-02154\n"),
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
          ],
        ),
        parentContext: context,
      ),
      InfoButton.route(
        "이용 약관",
        page: WebViewScaffold(
          title: "약관 보기",
          initialUrl: "https://h4pay.co.kr/law/terms.html",
        ),
        parentContext: context,
      ),
      InfoButton.route(
        "개인정보 처리 방침",
        page: WebViewScaffold(
          title: "약관 보기",
          initialUrl: "https://h4pay.co.kr/law/privacyPolicy.html",
        ),
        parentContext: context,
      ),
      InfoButton.route(
        "오픈소스 라이선스",
        page: LicensePage(
          applicationName: "H4Pay",
          applicationVersion: packageInfo.version,
        ),
        parentContext: context,
      ),
      InfoButton.dialog(
        "${school.seller.name} 사업자 정보",
        page: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("대표: ${school.seller.founderName}"),
            Text("주소: ${school.seller.address}"),
            Text("Tel: ${school.seller.tel}"),
            Text("사업자등록번호: ${school.seller.businessId}"),
            HyperLinkText(
              text: "통신판매업신고: ${school.seller.sellerId}",
              url:
                  "https://ftc.go.kr/www/bizCommView.do?key=232&apv_perm_no=2021445011930200007&pageUnit=10&searchCnd=apv_perm_mgt_no&searchKrwd=2021%EC%B6%A9%EB%B6%81%EC%A7%84%EC%B2%9C0007&pageIndex=1",
            )
          ],
        ),
        parentContext: context,
      ),
      InfoButton.dialog(
        "IP주소 변경",
        page: IpChangerDialog(context),
        parentContext: context,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: H4PayAppbar(title: "H4Pay 정보", height: 56.0, canGoBack: true),
      body: FutureBuilder(
        future: _fetchInfos(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<InfoButton> infos = snapshot.data as List<InfoButton>;
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
                      return infos[index];
                    },
                  )
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
