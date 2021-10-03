import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay/Gift.dart';
import 'package:h4pay/Login.dart';
import 'package:h4pay/PurchaseDetail.dart';
import 'package:h4pay/Register.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/components/Button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}

class H4PayRoute {
  final String route;
  final String data;
  H4PayRoute({required this.route, required this.data});
}

class IntroPage extends StatefulWidget {
  bool canGoBack;
  IntroPage({required this.canGoBack});

  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ipController = TextEditingController();

  StreamSubscription? _sub;

  Future<void> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final String? initialLink = await getInitialLink();
      if (initialLink != null) {
        final H4PayRoute route = parseUrl(initialLink);
        pushToRoute(route);
      }
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
    // Attach a listener to the stream
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        final H4PayRoute route = parseUrl(link);
        pushToRoute(route);
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
  }

  pushToRoute(H4PayRoute route) async {
    if (route.route == 'giftView') {
      final Gift? gift = await fetchGiftDetail(route.data);
      if (gift != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseDetailPage(purchase: gift),
          ),
        );
      } else {
        showSnackbar(
          context,
          "주문 상세 정보 조회에 실패했습니다.",
          Colors.red,
          Duration(seconds: 1),
        );
      }
    }
  }

  H4PayRoute parseUrl(String url) {
    return H4PayRoute(route: url.split("/")[3], data: url.split("/")[4]);
  }

  @override
  void initState() {
    super.initState();
    //loadApiUrl(prefs);

    connectionCheck().then((value) {
      if (!value) {
        if (dotenv.env['TEST_MODE'] == "TRUE") {
          showCustomAlertDialog(
            context,
            "서버 오류",
            [Text("서버와 연결할 수 없습니다. 개발자 모드이므로 IP 변경을 시도합니다.")],
            [
              H4PayButton(
                  text: "확인",
                  onClick: () {
                    Navigator.pop(context);
                    showIpChangeDialog();
                  },
                  backgroundColor: Theme.of(context).primaryColor),
            ],
            false,
          );
        } else {
          showCustomAlertDialog(
            context,
            "서버 오류",
            [
              Text("서버와 연결할 수 없습니다.\n앱을 종료합니다."),
            ],
            [
              H4PayButton(
                  text: "확인",
                  onClick: () {
                    exit(0);
                  },
                  backgroundColor: Colors.red,
                  width: double.infinity)
            ],
            false,
          );
        }
      } else {
        initUniLinks().then((value) => null);
      }
    });
  }

  Future<bool> connectionCheck() async {
    final connStatus = await Connectivity().checkConnectivity();
    if (connStatus == ConnectivityResult.mobile ||
        connStatus == ConnectivityResult.wifi) {
      try {
        final socket = await Socket.connect(
          API_URL!.split(":")[1].split("//")[1],
          int.parse(API_URL!.split(":")[2].split("/")[0]),
          timeout: Duration(seconds: 3),
        );
        socket.destroy();
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return widget.canGoBack;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: EmptyAppBar(),
        backgroundColor: Color(0xff434343),
        body: Stack(
          children: [
            Positioned(
              top: -(MediaQuery.of(context).size.height * 0.3),
              left: -(MediaQuery.of(context).size.width * 1.5),
              child: Image.asset(
                "assets/image/pattern.png",
                width: MediaQuery.of(context).size.width * 2,
                color: Colors.grey[850]!.withOpacity(0.7),
              ),
            ),
            Positioned(
              top: -(MediaQuery.of(context).size.height * 0.6),
              right: -(MediaQuery.of(context).size.width * 1.5),
              child: Image.asset(
                "assets/image/pattern.png",
                width: MediaQuery.of(context).size.width * 2,
                color: Colors.grey[850]!.withOpacity(0.7),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.15,
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.1),
                      child: Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.1),
                        child: Image.asset(
                          'assets/image/H4pay.png',
                          width: MediaQuery.of(context).size.width * 0.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    H4PayButton(
                      text: "로그인",
                      width: double.infinity,
                      onClick: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage(canGoBack: true)),
                        );
                      },
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                    ),
                    H4PayButton(
                      text: "회원가입",
                      width: double.infinity,
                      onClick: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      backgroundColor: Color(0xff4F83D6),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountFindPage(),
                          ),
                        );
                      },
                      child: Text(
                        "아이디나 비밀번호를 잊어버리셨나요?",
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    dotenv.env['TEST_MODE'] == "TRUE"
                        ? InkWell(
                            onTap: showIpChangeDialog,
                            child: Text(
                              "서버 IP 변경",
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showIpChangeDialog() {
    showCustomAlertDialog(
        context,
        "서버 URL 변경",
        [
          Text(
              "서버 URL을 프로토콜, 포트, Route와 함께 입력해주세요. ex) https://yoon-lab.xyz:23408/api"),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _ipController,
              validator: (value) {
                return value!.isNotEmpty ? null : "URL을 입력해주세요.";
              },
            ),
          )
        ],
        [
          H4PayButton(
            text: "확인",
            onClick: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              if (_formKey.currentState!.validate()) {
                final _prefs = await SharedPreferences.getInstance();
                _prefs.setString(
                  'API_URL',
                  _ipController.text,
                );
                API_URL = _ipController.text;
                final connStatus = await connectionCheck();
                if (connStatus) {
                  Navigator.pop(context);
                  showSnackbar(
                    context,
                    "IP '${_ipController.text}' 로 서버 URL을 설정합니다.",
                    Colors.green,
                    Duration(seconds: 1),
                  );
                } else {
                  showSnackbar(
                    context,
                    "IP '${_ipController.text}' 로 연결을 시도했지만 잘 안 되는 것 같네요...",
                    Colors.red,
                    Duration(seconds: 1),
                  );
                }
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
          )
        ],
        true);
  }
}
