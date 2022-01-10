import 'dart:async';

import 'package:flutter/material.dart';
import 'package:h4pay/Network/User.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/main.dart';
import 'package:h4pay/Util/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  bool canGoBack;
  LoginPage({required this.canGoBack});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loginCheck();
  }

  Future _loginCheck() async {
    await logout();
  }

  @override
  Widget build(BuildContext context) {
    final _loginFormKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        return widget.canGoBack;
      },
      child: Scaffold(
        appBar: H4PayAppbar(
            title: "로그인", height: 56.0, canGoBack: widget.canGoBack),
        body: Container(
          margin: EdgeInsets.all(40),
          child: Column(
            children: [
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
                    H4PayInput(
                      title: "아이디",
                      controller: _idController,
                      validator: idValidator,
                    ),
                    H4PayInput.done(
                      isPassword: true,
                      title: "비밀번호",
                      controller: _pwController,
                      validator: pwValidator,
                    ),
                  ],
                ),
              ),
              H4PayButton(
                text: "로그인",
                width: double.infinity,
                onClick: () async {
                  if (_loginFormKey.currentState!.validate()) {
                    try {
                      final String accessToken =
                          await login(_idController.text, _pwController.text);
                      final H4PayUser? user = await tokenCheck(accessToken);
                      if (user != null) {
                        await user.saveToStorage();
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        navigateRoute(
                          context,
                          MyHomePage(prefs: prefs),
                        );
                      } else {
                        throw UserNotFoundException();
                      }
                    } on NetworkException catch (e) {
                      showSnackbar(
                        context,
                        "(${e.statusCode}) 서버 오류가 발생했습니다. 고객센터로 문의해주세요.",
                        Colors.red,
                        Duration(seconds: 3),
                      );
                    } on UserNotFoundException {
                      showSnackbar(
                        context,
                        "아이디 혹은 비밀번호가 틀렸습니다.",
                        Colors.red,
                        Duration(seconds: 3),
                      );
                    }
                  }
                },
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountFindPage extends StatefulWidget {
  @override
  AccountFindPageState createState() => AccountFindPageState();
}

class AccountFindPageState extends State<AccountFindPage> {
  final GlobalKey<FormState> _findIdFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _findPwFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: H4PayAppbar(
        title: "계정 찾기",
        height: 56.0,
        canGoBack: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(23),
        child: Column(
          children: [
            Text("아이디 찾기"),
            Form(
              key: _findIdFormKey,
              child: Column(
                children: [
                  H4PayInput(
                    title: "이름",
                    controller: _nameController,
                    validator: nameValidator,
                  ),
                  H4PayInput.done(
                    title: "이메일",
                    controller: _emailController,
                    validator: emailValidator,
                  )
                ],
              ),
            ),
            H4PayButton(
              text: "찾기",
              onClick: () async {
                if (_findIdFormKey.currentState!.validate()) {
                  // 입력값이 정상이면
                  try {
                    await findId(
                      _nameController.text,
                      _emailController.text,
                    );
                    showSnackbar(
                      context,
                      "아이디가 메일로 전송되었어요. 메일이 도착하지 않았으면 스팸함을 확인해보세요.",
                      Colors.green,
                      Duration(seconds: 3),
                    );
                  } on NetworkException catch (e) {
                    showServerErrorSnackbar(context, e);
                  }
                }
              },
              backgroundColor: Color(0xff5B82D1),
              width: double.infinity,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Text("비밀번호 찾기"),
            Form(
              key: _findPwFormKey,
              child: Column(
                children: [
                  H4PayInput(
                    title: "이름",
                    controller: _nameController,
                    validator: nameValidator,
                  ),
                  H4PayInput(
                    title: "아이디",
                    controller: _idController,
                    validator: idValidator,
                  ),
                  H4PayInput.done(
                    title: "이메일",
                    controller: _emailController,
                    validator: emailValidator,
                  ),
                ],
              ),
            ),
            H4PayButton(
              text: "찾기",
              onClick: () async {
                if (_findPwFormKey.currentState!.validate()) {
                  // 입력값이 정상이면
                  try {
                    await findPw(
                      _nameController.text,
                      _emailController.text,
                      _idController.text,
                    );
                    showSnackbar(
                      context,
                      "새로운 비밀번호가 메일로 전송되었어요. 메일이 도착하지 않았으면 스팸함을 확인해보세요.",
                      Colors.green,
                      Duration(seconds: 3),
                    );
                  } on NetworkException catch (e) {
                    showServerErrorSnackbar(context, e);
                  }
                }
              },
              backgroundColor: Color(0xff5B82D1),
              width: double.infinity,
            )
          ],
        ),
      ),
    );
  }
}
