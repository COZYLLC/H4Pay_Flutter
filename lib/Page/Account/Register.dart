import 'package:flutter/material.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Account/Login.dart';
import 'package:h4pay/Page/Success.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/Util/Encryption.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/main.dart';
import 'package:h4pay/Util/mp.dart';
import 'package:h4pay/Util/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final H4PayService service = getService();
  final _formKey = GlobalKey<FormState>();
  final pw = TextEditingController();
  final pwCheck = TextEditingController();
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

  _checkEmailValidity() {
    service.checkUidValid(
      {'uid': email.text.split("@")[0]},
    ).then((isDuplicated) {
      if (isDuplicated) {
        do {
          FocusScope.of(context).nextFocus();
        } while (FocusScope.of(context).focusedChild!.context!.widget
            is! EditableText);
      } else if (!isDuplicated) {
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
      }
    }).catchError((e) {
      showServerErrorSnackbar(context, e);
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
                    title: "이메일",
                    controller: email,
                    validator: emailValidator,
                    onEditingComplete: _checkEmailValidity,
                  ),
                  Text(
                    "이메일의 @(골뱅이) 앞의 문자를 아이디로 자동 등록합니다.",
                    style: TextStyle(color: Colors.red),
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
                    isPassword: true,
                    validator: (value) =>
                        pw.text == value ? null : "비밀번호가 일치하지 않습니다.",
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
                        final Map<String, String> requestBody = {
                          'uid': email.text.split("@")[0],
                          'password': encryptPassword(pw.text),
                          'aID': '',
                          'gID': '',
                          'email': email.text,
                          'tel': tel.text.replaceAll("-", ""),
                          'role': 'S',
                        };
                        service.register(requestBody).then((response) async {
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
                        }).catchError((err) {
                          showServerErrorSnackbar(context, err);
                        });
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
