import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/components/Button.dart';
import 'package:h4pay_flutter/components/WebView.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
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
              child: Column(
                children: [
                  TextFormField(
                      decoration: InputDecoration(labelText: "이름"),
                      textInputAction: TextInputAction.next),
                  TextFormField(
                      decoration: InputDecoration(labelText: "아이디"),
                      textInputAction: TextInputAction.next),
                  TextFormField(
                      decoration: InputDecoration(labelText: "비밀번호"),
                      textInputAction: TextInputAction.next),
                  TextFormField(
                      decoration: InputDecoration(labelText: "비밀번호 확인"),
                      textInputAction: TextInputAction.next),
                  TextFormField(
                      decoration: InputDecoration(labelText: "이메일"),
                      textInputAction: TextInputAction.next),
                  TextFormField(
                      decoration: InputDecoration(labelText: "전화번호"),
                      textInputAction: TextInputAction.next),
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
                    onClick: () {},
                    backgroundColor: Colors.blue,
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
