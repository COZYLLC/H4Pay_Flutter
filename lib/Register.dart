import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Login.dart';
import 'package:h4pay/Result.dart';
import 'package:h4pay/Success.dart';
import 'package:h4pay/User.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/main.dart';
import 'package:h4pay/mp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  List<String> userTypes = ['A', 'AT', 'T', 'M', 'S'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("회원가입"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: name,
                    decoration: InputDecoration(labelText: "이름"),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final RegExp regExp = RegExp(r'^[가-힣]{2,8}$');
                      return regExp.hasMatch(value!) ? null : "이름이 올바르지 않습니다.";
                    },
                  ),
                  TextFormField(
                    controller: id,
                    decoration: InputDecoration(labelText: "아이디"),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final RegExp regExp = RegExp(r'^[A-za-z0-9]{5,15}$');
                      return regExp.hasMatch(value!) ? null : "아이디가 올바르지 않습니다.";
                    },
                  ),
                  TextFormField(
                    controller: pw,
                    decoration: InputDecoration(labelText: "비밀번호"),
                    textInputAction: TextInputAction.next,
                    obscureText: true,
                    validator: (value) {
                      final RegExp regExp = RegExp(
                        r'(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$',
                      );
                      return regExp.hasMatch(value!)
                          ? null
                          : "비밀번호는 영대소문자와 숫자, 특수문자를 포함해 8자 이상이어야 합니다.";
                    },
                  ),
                  TextFormField(
                    controller: pwCheck,
                    decoration: InputDecoration(labelText: "비밀번호 확인"),
                    textInputAction: TextInputAction.next,
                    obscureText: true,
                    validator: (value) {
                      return (pw.text == pwCheck.text)
                          ? null
                          : "비밀번호가 일치하지 않습니다.";
                    },
                  ),
                  DropdownButtonFormField(
                    hint: Text("사용자 유형 선택"),
                    value: selectedUserType,
                    items: userTypes
                        .map(
                          (e) => DropdownMenuItem(
                            child: Text(
                              roleStrFromLetter(e),
                            ),
                            value: e,
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUserType = value.toString();
                      });
                    },
                  ),
                  Container(
                    child: (selectedUserType != null)
                        ? TextFormField(
                            controller: userAuth,
                            decoration: InputDecoration(
                              labelText:
                                  selectedUserType == 'S' ? "학번" : "인증코드",
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              return (selectedUserType != 'S' ||
                                      userAuth.text.length == 4)
                                  ? null
                                  : "올바르지 않습니다.";
                            },
                          )
                        : Container(),
                  ),
                  TextFormField(
                    controller: email,
                    decoration: InputDecoration(labelText: "이메일"),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final RegExp regExp = RegExp(
                          r'([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$');
                      return regExp.hasMatch(value!) ? null : "이메일이 올바르지 않습니다.";
                    },
                  ),
                  TextFormField(
                    controller: tel,
                    decoration: InputDecoration(labelText: "전화번호"),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final RegExp regExp = RegExp(r'^\d{3}-\d{4}-\d{4}$');
                      return regExp.hasMatch(value!)
                          ? null
                          : "전화번호가 올바르지 않습니다.";
                    },
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
