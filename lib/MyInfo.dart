import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/Login.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/PurchaseList.dart';
import 'package:h4pay_flutter/User.dart';
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
  Future<H4PayUser?>? _fetchUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUser = userFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _fetchUser,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final H4PayUser user = snapshot.data as H4PayUser;
              return Container(
                margin: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "안녕하세요,\n",
                                style: TextStyle(fontSize: 25),
                              ),
                              TextSpan(
                                text: "${user.name} ",
                                style: TextStyle(
                                    fontSize: 35, fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: "님",
                                style: TextStyle(fontSize: 30),
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Text("내 정보 보기"),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          InfoMenuList(
                            menu: [
                              InfoMenu(
                                icon: Icon(Icons.list_alt),
                                text: "주문 내역",
                                onClick: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PurchaseList(
                                        type: Order,
                                        appBar: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              InfoMenu(
                                icon: Icon(Icons.logout),
                                text: "로그아웃",
                                onClick: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                },
                              ),
                              InfoMenuTitle(title: "선물"),
                              InfoMenu(
                                icon: Icon(Icons.markunread_mailbox),
                                text: "선물함",
                                onClick: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PurchaseList(
                                        type: Gift,
                                        appBar: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              InfoMenu(
                                icon: Icon(Icons.send),
                                text: "선물 발송 내역",
                                onClick: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PurchaseList(
                                        type: SentGift,
                                        appBar: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
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
  final onClick;

  const InfoMenu(
      {Key? key, required this.icon, required this.text, required this.onClick})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Column(
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
      ),
    );
  }
}
