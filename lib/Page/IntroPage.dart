import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay/AppLink.dart';
import 'package:h4pay/Network/Maintenance.dart';
import 'package:h4pay/Page/Account/Login.dart';
import 'package:h4pay/Page/Account/Register.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Maintenance.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/Util/Connection.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/main.dart';
import 'package:new_version/new_version.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    );
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
    if (!kIsWeb) registerListener(context);
    connectionCheck().then((connected) async {
      if (!connected) {
        if (isTestMode) {
          showCustomAlertDialog(
            context,
            H4PayDialog(
              title: "서버 오류",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("서버와 연결할 수 없습니다. 개발자 모드이므로 IP 변경을 시도합니다.")],
              ),
              actions: [
                H4PayOkButton(
                  context: context,
                  onClick: () {
                    Navigator.pop(context);
                    showIpChangeDialog(context, _formKey, _ipController);
                  },
                ),
              ],
            ),
            false,
          );
        } else {
          showCustomAlertDialog(
            context,
            H4PayDialog(
              title: "서버 오류",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("서버와 연결할 수 없습니다.")],
              ),
              actions: [
                H4PayOkButton(
                  context: context,
                  onClick: () {
                    exit(0);
                  },
                )
              ],
            ),
            false,
          );
        }
      } else {
        checkUpdate();
        if (!kIsWeb) {
          final Widget? route = await initUniLinks(context);
          if (route != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => route),
            );
            return;
          }
        }

        final H4PayUser? user = await userFromStorageAndVerify();
        debugPrint("hi");
        final SharedPreferences _prefs = await SharedPreferences.getInstance();
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                prefs: _prefs,
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> checkUpdate() async {
    if (kIsWeb) {
      return;
    }
    if (Platform.isAndroid) {
      final status = await InAppUpdate.checkForUpdate();
      if (status.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate().catchError(
          (err) => showSnackbar(
            context,
            "업데이트에 실패했어요. 스토어에서 직접 진행해주세요.",
            Colors.red,
            Duration(seconds: 1),
          ),
        );
      }
    } else if (Platform.isIOS) {
      final newVersion = NewVersion(
        iOSId: "com.cozyllc.h4pay",
        iOSAppStoreCountry: "KR",
      );
      final status = await newVersion.getVersionStatus();
      if (status!.canUpdate) {
        showAlertDialog(context, "앱 업데이트 안내",
            "H4Pay를 더 안정적으로 이용하기 위해서 앱 업데이트가 필요해요. 앱스토어로 이동해 업데이트할까요?", () {
          launch(status.appStoreLink).catchError((err) {
            showSnackbar(
              context,
              "업데이트를 확인했지만 앱스토어 실행에 실패했어요: ${err.toString()}",
              Colors.red,
              Duration(seconds: 3),
            );
          });
        }, () {
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showAlertDialog(context, "앱 종료", "앱을 종료하시겠습니까?", () {
          exit(0);
        }, () {
          Navigator.pop(context);
        });
        return false;
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
                      onClick: () {
                        navigateRoute(context, RegisterPage());
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
                    isTestMode
                        ? InkWell(
                            onTap: () {
                              showIpChangeDialog(
                                  context, _formKey, _ipController);
                            },
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
}
