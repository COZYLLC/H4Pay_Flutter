import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay_flutter/Login.dart';
import 'package:h4pay_flutter/Register.dart';
import 'package:h4pay_flutter/Setting.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:h4pay_flutter/components/Button.dart';
import 'package:h4pay_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
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
