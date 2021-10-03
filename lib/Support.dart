import 'dart:convert';
import 'dart:io';
import 'package:h4pay/Notice.dart';
import 'package:h4pay/NoticeList.dart';
import 'package:h4pay/Result.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Success.dart';
import 'package:h4pay/User.dart';
import 'package:h4pay/main.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:h4pay/MyPage.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/custompaint.dart';
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
                        onClick: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => type.key == 'notice'
                                  ? NoticeListPage(
                                      type: Notice,
                                      withAppBar: true,
                                    )
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
  String? photoName;
  File? file;

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
                    isMultiLine: false,
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
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "사진 첨부",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      height: 40,
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            height: constraints.maxHeight,
                            child: Container(
                              width: constraints.maxWidth * 0.6,
                              child: Text(
                                file != null ? file!.path.split('/')[7] : "",
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200]!,
                              borderRadius: BorderRadius.circular(38),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            child: H4PayButton(
                              text: "사진 업로드",
                              onClick: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  setState(() {
                                    file = File(result.files.single.path!);
                                    photoName = file!.path.split('/')[7];
                                  });
                                }
                              },
                              backgroundColor: Theme.of(context).primaryColor,
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: constraints.maxHeight,
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                  Container(
                    height: 20,
                  ),
                  H4PayButton(
                    text: "제출하기",
                    onClick: () async {
                      if (_formKey.currentState!.validate()) {
                        final H4PayUser? user = await userFromStorage();
                        if (file != null && user != null) {
                          await _upload(
                            user.uid!,
                            user.email!,
                            title.text,
                            widget.type,
                            content.text,
                            file!,
                          );
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuccessPage(
                              canGoBack: false,
                              successText: "문의가 완료되었습니다.",
                              title: "문의 완료",
                              bottomDescription: [
                                Text("더 좋은 서비스를 위해 노력하겠습니다.")
                              ],
                              actions: [
                                H4PayButton(
                                  text: "지원 페이지로 돌아가기",
                                  onClick: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  width: double.infinity,
                                )
                              ],
                            ),
                          ),
                        );
                      }
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

  Future<H4PayResult> _upload(String uid, String email, String title,
      String category, String content, File img) async {
    var stream = new http.ByteStream(DelegatingStream.typed(img.openRead()));
    var length = await img.length();

    var uri = Uri.parse("$API_URL/upload");

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('img', stream, length,
        filename: basename(img.path));
    request.fields.addAll({
      'uid': uid,
      'email': email,
      'title': title,
      'category': category,
      'content': content
    });
    request.files.add(multipartFile);
    var response = await request.send();
    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseString);
      return H4PayResult(
        success: jsonResponse['status'],
        data: jsonResponse['message'],
      );
    } else {
      return H4PayResult(success: false, data: "서버 오류입니다.");
    }
  }
}

class H4PayInput extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final Color backgroundColor;
  final Color borderColor;
  final bool isMultiLine;
  final String? Function(String?)? validator;
  final int? minLines;

  const H4PayInput(
      {Key? key,
      required this.title,
      required this.controller,
      required this.backgroundColor,
      required this.borderColor,
      required this.isMultiLine,
      required this.validator,
      this.minLines})
      : super(key: key);
  @override
  H4PayInputState createState() => H4PayInputState();
}

class H4PayInputState extends State<H4PayInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        Container(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: widget.borderColor,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            textInputAction: widget.isMultiLine
                ? TextInputAction.newline
                : TextInputAction.next,
            keyboardType: widget.isMultiLine
                ? TextInputType.multiline
                : TextInputType.text,
            maxLines: null,
            minLines: widget.isMultiLine ? widget.minLines : 1,
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
