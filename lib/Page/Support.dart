import 'dart:convert';
import 'dart:io';
import 'package:h4pay/Page/NoticeList.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Page/Success.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/main.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Page/Account/MyPage.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/Util/custompaint.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class SupportPage extends StatefulWidget {
  @override
  SupportPageState createState() => SupportPageState();
}

final Map types = {
  'payment': "결제, 취소, 환불 관련 문의",
  'system': "시스템 관련 문의",
  "suggest": "건의사항 접수",
  "notice": "공지사항"
};

class SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.1, 1],
          colors: [
            Color(0xffe8ffef),
            Color(0xfffbfffd),
          ],
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(
                MediaQuery.of(context).size.width,
                (MediaQuery.of(context).size.width * 0.9603657072613252)
                    .toDouble(),
              ), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
              painter: RPSCustomPainter(),
            ),
            Text(
              "무엇을 도와드릴까요?",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.08),
              width: MediaQuery.of(context).size.width * 0.8,
              child: InfoMenuList(
                menu: [
                  ListView.builder(
                    itemCount: types.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final type = types.entries.elementAt(index);
                      return CardWidget(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Text(type.value),
                        onClick: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => type.key == 'notice'
                                  ? NoticeListPage()
                                  : SupportFormPage(
                                      type: type.key,
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportFormPage extends StatefulWidget {
  final String type;
  const SupportFormPage({Key? key, required this.type}) : super(key: key);

  @override
  SupportFormPageState createState() => SupportFormPageState();
}

class SupportFormPageState extends State<SupportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final content = TextEditingController();
  final fileName = TextEditingController();
  String? photoName;
  File? file;

  void _openFileSelector() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
        fileName.text = file != null ? file!.path.split('/')[7] : "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: H4PayAppbar(
        title: "문의하기",
        height: 56.0,
        canGoBack: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              types[widget.type],
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            Container(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  H4PayInput(
                    title: "제목",
                    controller: title,
                    backgroundColor: Colors.grey[200]!,
                    borderColor: Colors.grey[400]!,
                    validator: (value) {
                      return value!.length > 0 ? null : "문의 내용을 입력해주세요.";
                    },
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: H4PayInput(
                      title: "문의 내용",
                      controller: content,
                      backgroundColor: Colors.grey[200]!,
                      borderColor: Colors.grey[400]!,
                      isMultiLine: true,
                      validator: (value) {
                        return value!.length > 0 ? null : "문의 내용을 입력해주세요.";
                      },
                      minLines:
                          (MediaQuery.of(context).size.height / 55).floor(),
                    ),
                  ),
                  H4PayInput.button(
                    title: "사진 첨부",
                    controller: fileName,
                    buttonText: "선택",
                    onButtonClick: _openFileSelector,
                    onFieldClick: _openFileSelector,
                  ),
                  Container(
                    height: 20,
                  ),
                  H4PayButton(
                    text: "제출하기",
                    onClick: () {
                      _submit(context);
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    width: double.infinity,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final H4PayUser? user = await userFromStorage();
      if (user != null) {
        await _upload(
          user.uid!,
          user.email!,
          title.text,
          widget.type,
          content.text,
          file,
        );
        navigateRoute(
          context,
          SuccessPage(
            canGoBack: false,
            successText: "문의가 완료되었습니다.",
            title: "문의 완료",
            bottomDescription: [Text("더 좋은 서비스를 위해 노력하겠습니다.")],
            actions: [
              H4PayButton(
                text: "지원 페이지로 돌아가기",
                onClick: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                backgroundColor: Theme.of(context).primaryColor,
                width: double.infinity,
              )
            ],
          ),
        );
      }
    }
  }

  Future<bool> _upload(String uid, String email, String title, String category,
      String content, File? img) async {
    var uri = Uri.parse("${apiUrl}uploads");
    var request = new http.MultipartRequest("POST", uri);

    request.fields.addAll({
      'uid': uid,
      'email': email,
      'title': title,
      'category': category,
      'content': content
    });

    if (img != null) {
      var stream = new http.ByteStream(DelegatingStream.typed(img.openRead()));
      var length = await img.length();
      var multipartFile = new http.MultipartFile('img', stream, length,
          filename: basename(img.path));
      request.files.add(multipartFile);
    }
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseString);
        return jsonResponse['status'];
      } else {
        throw NetworkException(response.statusCode);
      }
    } catch (e) {
      return false;
    }
  }
}
