import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:h4pay_flutter/components/Card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyInfo extends StatefulWidget {
  final SharedPreferences prefs;
  MyInfo(this.prefs);

  @override
  MyInfoState createState() => MyInfoState(prefs);
}

class MyInfoState extends State<MyInfo> {
  final SharedPreferences prefs;
  MyInfoState(this.prefs);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: "안녕하세요,\n", style: TextStyle(fontSize: 25)),
                        TextSpan(
                            text: "송치원 ",
                            style: TextStyle(
                                fontSize: 35, fontWeight: FontWeight.w700)),
                        TextSpan(text: "님", style: TextStyle(fontSize: 30))
                      ],
                    ),
                  ),
                  Spacer(),
                  TextButton(onPressed: () {}, child: Text("내 정보 보기"))
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    InfoMenuList(
                      menu: [
                        InfoMenu(icon: Icon(Icons.list_alt), text: "주문 내역"),
                        InfoMenuTitle(title: "교사 전용 메뉴"),
                        InfoMenu(
                            icon: Icon(Icons.redeem), text: "학생에게 대량 선물하기"),
                        InfoMenuTitle(title: "선물"),
                        InfoMenu(icon: Icon(Icons.inbox), text: "받은 선물함"),
                        InfoMenu(icon: Icon(Icons.send), text: "선물 발송 내역")
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoMenuTitle extends StatelessWidget {
  final String title;
  const InfoMenuTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class InfoMenuList extends StatelessWidget {
  final List<Widget> menu;

  const InfoMenuList({Key? key, required this.menu}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: menu,
    );
  }
}

class InfoMenu extends StatelessWidget {
  final Icon icon;
  final String text;

  const InfoMenu({Key? key, required this.icon, required this.text})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(margin: EdgeInsets.only(right: 8), child: icon),
            Text(
              text,
              textAlign: TextAlign.left,
            ),
          ],
        ),
        Divider(
          thickness: 1,
        )
      ],
    );
  }
}
