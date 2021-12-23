import 'package:flutter/material.dart';
import 'package:h4pay/Login.dart';
import 'package:h4pay/Result.dart';
import 'package:h4pay/Success.dart';
import 'package:h4pay/User.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/main.dart';
import 'package:h4pay/mp.dart';
import 'package:h4pay/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final id = TextEditingController();
  final pw = TextEditingController();
  final pwCheck = TextEditingController();
  final userAuth = TextEditingController();
  final email = TextEditingController();
  final tel = TextEditingController();
  String? selectedUserType;

  List<Map<String, dynamic>> terms = [
    {
      'value': false,
      'text': "(필수) H4Pay 이용약관",
      'url': "https://h4pay.co.kr/law/terms.html"
    },
    {
      'value': false,
      'text': "(필수) 개인정보 처리방침",
      'url': "https://h4pay.co.kr/law/privacyPolicy.html"
    }
  ];

  _checkUidValidity() {
    uidDuplicateCheck(id.text).then((isDuplicated) {
      if (!isDuplicated) {
        showCustomAlertDialog(
          context,
          H4PayDialog(
            title: "아이디 중복",
            content: Text("이미 존재하는 아이디입니다."),
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
      } else {
        do {
          FocusScope.of(context).nextFocus();
        } while (FocusScope.of(context).focusedChild!.context!.widget
            is! EditableText);
      }
    });
  }

  List<String> userTypes = ['S'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: H4PayAppbar(title: "회원가입", height: 56.0, canGoBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  H4PayInput(
                    title: "이름",
                    controller: name,
                    validator: nameValidator,
                  ),
                  H4PayInput(
                    title: "아이디",
                    controller: id,
                    validator: idValidator,
                    onEditingComplete: _checkUidValidity,
                  ),
                  H4PayInput(
                    title: "비밀번호",
                    controller: pw,
                    validator: pwValidator,
                    isPassword: true,
                  ),
                  H4PayInput(
                    title: "비밀번호 확인",
                    controller: pwCheck,
                    validator: (value) =>
                        pw.text == value ? null : "비밀번호가 일치하지 않습니다.",
                  ),
                  H4PayInput(
                    title: "학번",
                    controller: userAuth,
                    validator: (value) =>
                        value!.length == 4 ? null : "학번은 4자리 숫자입니다.",
                  ),
                  H4PayInput(
                    title: "이메일",
                    controller: email,
                    validator: emailValidator,
                  ),
                  H4PayInput.done(
                    isNumber: true,
                    title: "휴대전화 번호",
                    controller: tel,
                    validator: telValidator,
                    inputFormatters: [
                      MultiMaskedTextInputFormatter(
                        masks: ['xxx-xxxx-xxxx', 'xxx-xxx-xxxx'],
                        separator: '-',
                      )
                    ],
                  ),
                  ListView.builder(
                    itemCount: terms.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Checkbox(
                            value: terms[index]['value'],
                            onChanged: (bool? value) {
                              if (!terms[index]['value']) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WebViewScaffold(
                                      title: "약관 보기",
                                      initialUrl: terms[index]['url'],
                                    ),
                                  ),
                                );
                              }
                              setState(() {
                                terms[index]['value'] = value!;
                              });
                            },
                          ),
                          Text(terms[index]['text']),
                        ],
                      );
                    },
                  ),
                  H4PayButton(
                    text: "회원가입",
                    onClick: () async {
                      if (_formKey.currentState!.validate()) {
                        final H4PayResult registerResult = await createUser(
                          name.text,
                          id.text,
                          pw.text,
                          userAuth.text,
                          email.text,
                          tel.text,
                          selectedUserType!,
                        );
                        if (registerResult.success == true) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SuccessPage(
                                title: "가입 완료",
                                canGoBack: false,
                                successText: "회원가입이 완료되었습니다.",
                                bottomDescription: [Text("더 간편한 매점을 이용해보세요!")],
                                actions: [
                                  H4PayButton(
                                    text: "로그인 하러 가기",
                                    onClick: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LoginPage(canGoBack: false),
                                        ),
                                      );
                                    },
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    width: double.infinity,
                                  )
                                ],
                              ),
                            ),
                          );
                        } else if (registerResult.success == false) {
                          showSnackbar(
                            context,
                            registerResult.data,
                            Colors.red,
                            Duration(
                              seconds: 1,
                            ),
                          );
                        }
                      }
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    width: double.infinity,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
