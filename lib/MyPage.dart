import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/H4PayInfo.dart';
import 'package:h4pay_flutter/Login.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/PurchaseList.dart';
import 'package:h4pay_flutter/Result.dart';
import 'package:h4pay_flutter/Success.dart';
import 'package:h4pay_flutter/Support.dart';
import 'package:h4pay_flutter/User.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:h4pay_flutter/components/Button.dart';
import 'package:h4pay_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends StatefulWidget {
  final SharedPreferences prefs;
  final Map<String, int> badges;

  MyPage({required this.prefs, required this.badges});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  Future<H4PayUser?>? _fetchUser;
  MyHomePageState? myHomePageState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUser = userFromStorage();
  }

  FutureOr updateBadges(value) {
    myHomePageState = context.findAncestorStateOfType<MyHomePageState>();
    myHomePageState!.updateBadges();
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
                        HelloUser(user: user),
                        Spacer(),
                        H4PayButton(
                          text: "내 정보 보기",
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyInfoPage(
                                  user: user,
                                ),
                              ),
                            );
                          },
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
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
                                badgeCount: widget.badges['order'],
                                onClick: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PurchaseList(
                                        type: Order,
                                        appBar: true,
                                      ),
                                    ),
                                  ).then(updateBadges);
                                },
                              ),
                              InfoMenuTitle(title: "선물"),
                              InfoMenu(
                                icon: Icon(Icons.markunread_mailbox),
                                text: "선물함",
                                badgeCount: widget.badges['gift'],
                                onClick: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PurchaseList(
                                        type: Gift,
                                        appBar: true,
                                      ),
                                    ),
                                  ).then(updateBadges);
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
                              Container(
                                margin: EdgeInsets.only(top: 40),
                                child: InfoMenu(
                                  icon: Icon(Icons.info),
                                  text: "정보 보기",
                                  onClick: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => H4PayInfoPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              InfoMenu(
                                icon: Icon(Icons.logout),
                                text: "로그아웃",
                                onClick: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => IntroPage(
                                        canGoBack: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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

class HelloUser extends StatelessWidget {
  final H4PayUser user;
  HelloUser({required this.user});
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "안녕하세요,\n",
            style: TextStyle(fontSize: 25),
          ),
          TextSpan(
            text: "${user.name} ",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: "님",
            style: TextStyle(fontSize: 30),
          )
        ],
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
  final int? badgeCount;
  final Icon icon;
  final String text;
  final onClick;

  const InfoMenu(
      {Key? key,
      this.badgeCount,
      required this.icon,
      required this.text,
      required this.onClick})
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
              Spacer(),
              badgeCount != null && badgeCount != 0
                  ? ClipOval(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badgeCount.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : Container(),
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

class MyInfoPage extends StatefulWidget {
  final H4PayUser user;
  MyInfoPage({required this.user});
  @override
  MyInfoPageState createState() => MyInfoPageState();
}

class MyInfoPageState extends State<MyInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController prevPassword = TextEditingController();
  final TextEditingController pw2Change = TextEditingController();
  final TextEditingController pwCheck = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("내 정보"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HelloUser(user: widget.user),
            InfoMenuList(
              menu: [
                InfoMenuTitle(title: "내 정보"),
                InfoMenu(
                  icon: Icon(Icons.perm_identity),
                  text: widget.user.uid!,
                  onClick: null,
                ),
                InfoMenu(
                  icon: Icon(Icons.badge),
                  text: widget.user.name!,
                  onClick: null,
                ),
                InfoMenu(
                  icon: Icon(Icons.email),
                  text: widget.user.email!,
                  onClick: null,
                ),
                InfoMenu(
                  icon: Icon(Icons.work),
                  text: roleStrFromLetter(widget.user.role!),
                  onClick: null,
                ),
                InfoMenuTitle(title: "정보 변경"),
                InfoMenu(
                  icon: Icon(Icons.password),
                  text: "비밀번호 변경",
                  onClick: () {
                    showCustomAlertDialog(
                      context,
                      "비밀번호 변경하기",
                      [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                child: TextFormField(
                                  controller: prevPassword,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "기존 비밀번호",
                                  ),
                                  validator: (value) {
                                    final RegExp regExp = RegExp(
                                      r'(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$',
                                    );
                                    return regExp.hasMatch(value!)
                                        ? null
                                        : "비밀번호가 올바르지 않습니다.";
                                  },
                                ),
                              ),
                              Container(
                                child: TextFormField(
                                  controller: pw2Change,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "변경할 비밀번호",
                                  ),
                                  validator: (value) {
                                    final RegExp regExp = RegExp(
                                      r'(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$',
                                    );
                                    return regExp.hasMatch(value!)
                                        ? null
                                        : "비밀번호가 올바르지 않습니다.";
                                  },
                                ),
                              ),
                              TextFormField(
                                controller: pwCheck,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "비밀번호 확인",
                                ),
                                validator: (value) {
                                  final RegExp regExp = RegExp(
                                    r'(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$',
                                  );
                                  return regExp.hasMatch(value!)
                                      ? null
                                      : "비밀번호가 올바르지 않습니다.";
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                      [
                        H4PayButton(
                          text: "비밀번호 변경",
                          onClick: () async {
                            if (_formKey.currentState!.validate()) {
                              if (await changePassword(widget.user,
                                  prevPassword.text, pw2Change.text)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SuccessPage(
                                      title: "비밀번호 변경 완료",
                                      canGoBack: false,
                                      successText: "비밀번호 변경이\n완료되었습니다.",
                                      bottomDescription: [],
                                      actions: [
                                        H4PayButton(
                                          text: "로그인 하러 가기",
                                          onClick: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      IntroPage(
                                                        canGoBack: false,
                                                      )),
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
                              } else {
                                showSnackbar(
                                  context,
                                  "비밀번호 변경에 실패했습니다.",
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
                        ),
                      ],
                      true,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(18),
        child: H4PayButton(
          text: "H4Pay 탈퇴하기",
          onClick: () async {
            final H4PayUser? user = await userFromStorage();
            if (user != null) {
              showAlertDialog(
                context,
                "탈퇴하기",
                "구매 내역과 모든 교횐권, 선물 발송 내역, 받은 선물 등의 정보가 모두 삭제됩니다.\n정말로 탈퇴하시겠습니까?",
                () async {
                  final H4PayResult withdrawResult =
                      await withdraw(user.uid!, user.name!);
                  if (withdrawResult.success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessPage(
                          canGoBack: false,
                          title: "회원 탈퇴 완료",
                          successText: "다음 번에 다시 뵐 수 있길 희망할게요.",
                          bottomDescription: [Text("회원탈퇴가 정상적으로 처리되었습니다.")],
                          actions: [
                            H4PayButton(
                              text: "홈으로 돌아가기",
                              onClick: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => IntroPage(
                                            canGoBack: false,
                                          )),
                                );
                              },
                              backgroundColor: Theme.of(context).primaryColor,
                              width: double.infinity,
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
                () {
                  Navigator.pop(context);
                },
              );
            }
          },
          backgroundColor: Colors.red,
          width: double.infinity,
        ),
      ),
    );
  }
}
