import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:h4pay_flutter/MyInfo.dart';
import 'package:h4pay_flutter/components/Card.dart';
import 'package:h4pay_flutter/custompaint.dart';

class SupportPage extends StatefulWidget {
  @override
  SupportPageState createState() => SupportPageState();
}

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
                      .toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
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
                  CardWidget(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Text("결제, 취소, 환불 관련 문의"),
                    onClick: () {},
                  ),
                  CardWidget(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Text("시스템 관련 문의"),
                    onClick: () {},
                  ),
                  CardWidget(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Text("건의사항 접수"),
                    onClick: () {},
                  ),
                  CardWidget(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Text("공지사항"),
                    onClick: () {},
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
