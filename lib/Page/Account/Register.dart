import 'package:flutter/material.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Account/Login.dart';
import 'package:h4pay/Page/Success.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/Util/Encryption.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/components/SchoolSelectDialog.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/main.dart';
import 'package:h4pay/Util/mp.dart';
import 'package:h4pay/Util/validator.dart';
import 'package:h4pay/model/School.dart';
import 'package:dio/dio.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final H4PayService service = getService();
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final pw = TextEditingController();
  final pwCheck = TextEditingController();
  final email = TextEditingController();
  final tel = TextEditingController();
  final pin = TextEditingController();
  final school = TextEditingController();
  bool? isTelChecked;
  bool? isEmailChecked;
  String? generatedPin;
  String? selectedUserType;
  List<School>? schools;
  School? selectedSchool;

  @override
  void initState() {
    super.initState();
  }

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
                  H4PayInput.button(
                    title: "학교 선택",
                    controller: school,
                    buttonText: "검색",
                    onButtonClick: _openSchoolSelectDialog,
                    onFieldClick: _openSchoolSelectDialog,
                    validator: (value) =>
                        value!.length < 1 ? "학교를 선택해주세요." : null,
                  ),
                  H4PayInput(
                    title: "이름",
                    controller: name,
                    validator: nameValidator,
                  ),
                  Focus(
                    child: H4PayInput(
                      title: "이메일",
                      controller: email,
                      validator: emailValidator,
                      onEditingComplete: _checkEmailValidity,
                    ),
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        _checkEmailValidity();
                      }
                    },
                  ),
                  isEmailChecked == false
                      ? Text(
                          "이메일이 이미 사용중입니다.",
                          style: TextStyle(color: Colors.red),
                        )
                      : Container(),
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
                  H4PayInput.button(
                    isNumber: true,
                    buttonText: "인증",
                    title: "휴대전화 번호",
                    controller: tel,
                    validator: telValidator,
                    inputFormatters: [
                      MultiMaskedTextInputFormatter(
                        masks: ['xxx-xxxx-xxxx', 'xxx-xxx-xxxx'],
                        separator: '-',
                      )
                    ],
                    onButtonClick: _sendAuthPin,
                  ),
                  H4PayInput.button(
                    onEditingComplete: () {
                      _formKey.currentState!.validate();
                    },
                    isNumber: true,
                    buttonText: "확인",
                    title: "인증번호 입력",
                    maxLength: 6,
                    validator: (value) {
                      return generatedPin == null
                          ? "인증번호를 전송해주세요."
                          : !(isNumeric(value!) && value.length <= 6)
                              ? "인증번호의 형식이 올바르지 않습니다."
                              : null;
                    },
                    controller: pin,
                    onButtonClick: () {
                      setState(() {
                        isTelChecked =
                            encryptPassword(pin.text) == generatedPin;
                      });
                    },
                  ),
                  isTelChecked == true
                      ? Text(
                          "인증이 완료되었습니다.",
                          style: TextStyle(color: Colors.green),
                        )
                      : isTelChecked == false
                          ? Text(
                              "인증번호가 올바르지 않습니다.",
                              style: TextStyle(color: Colors.red),
                            )
                          : Container(),
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
                    onClick: _register,
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

  void _openSchoolSelectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => SchoolSelectDialog(),
    ).then((value) {
      debugPrint("${value.id} selected");
      setState(() {
        school.text = value.name;
        selectedSchool = value;
      });
    });
  }

  void _sendAuthPin() {
    if (telValidator(tel.text) == null)
      service.authTel({"tel": tel.text.replaceAll("-", "")}).then((value) {
        showSnackbar(
          context,
          "인증번호가 발송되었습니다. 카카오 알림톡 혹은 문자를 확인해주세요.",
          Colors.green,
          Duration(seconds: 1),
        );
        setState(() {
          isTelChecked = null;
          generatedPin = value;
        });
      }).catchError((err) {
        showSnackbar(
          context,
          "해당 전화번호로 이미 가입된 것 같아요.",
          Colors.red,
          Duration(seconds: 3),
        );
      });
  }

  void _checkEmailValidity() {
    print("checking email validity");
    if (emailValidator(email.text) == null)
      service.checkUidValid(
        {'email': email.text, "type": "live"},
      ).then((isValid) {
        print(isValid);
        if (isValid) {
          setState(() {
            isEmailChecked = true;
          });
        } else if (!isValid) {
          setState(() {
            isEmailChecked = false;
          });
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

  Future<void> _register() async {
    if (selectedSchool == null) {
      showSnackbar(
        context,
        "학교를 선택해주세요.",
        Colors.red,
        Duration(seconds: 3),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      showSnackbar(
        context,
        "모든 정보를 올바르게 입력해주세요.",
        Colors.red,
        Duration(seconds: 3),
      );
      return;
    }
    if (generatedPin != encryptPassword(pin.text)) {
      showSnackbar(
        context,
        "인증번호가 올바르지 않습니다.",
        Colors.red,
        Duration(seconds: 3),
      );
      return;
    }
    final Map<String, String> requestBody = {
      'uid': email.text.split("@")[0],
      'password': encryptPassword(pw.text),
      'aID': '',
      'gID': '',
      'email': email.text,
      'tel': tel.text.replaceAll("-", ""),
      'role': 'S',
      "name": name.text,
      'schoolId': selectedSchool!.id,
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
                      builder: (context) => LoginPage(canGoBack: false),
                    ),
                  );
                },
                backgroundColor: Theme.of(context).primaryColor,
                width: double.infinity,
              )
            ],
          ),
        ),
      );
    }).catchError((err) {
      if (err.runtimeType == DioError) {
        final DioError error = err as DioError;
        if (error.response!.statusCode == 400) {
          showSnackbar(
            context,
            "이미 존재하는 아이디입니다.",
            Colors.red,
            Duration(seconds: 2),
          );
        }
      } else {
        showServerErrorSnackbar(context, err);
      }
    });
  }
}
