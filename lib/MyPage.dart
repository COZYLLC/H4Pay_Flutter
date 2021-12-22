import 'dart:async';
import 'package:flutter/material.dart';
import 'package:h4pay/Page/Account/ChangePassword.dart';
import 'package:h4pay/Purchase/Gift.dart';
import 'package:h4pay/H4PayInfo.dart';
import 'package:h4pay/IntroPage.dart';
import 'package:h4pay/Purchase/Order.dart';
import 'package:h4pay/Page/Purchase/PurchaseList.dart';
import 'package:h4pay/Page/Voucher/VoucherList.dart';
import 'package:h4pay/Result.dart';
import 'package:h4pay/Success.dart';
import 'package:h4pay/User.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/main.dart';
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
    super.initState();
    _fetchUser = userFromStorage();
  }

  FutureOr updateBadges(value) {
    myHomePageState = context.findAncestorStateOfType<MyHomePageState>();
    myHomePageState!.updateBadges();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: _fetchUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final H4PayUser user = snapshot.data as H4PayUser;
            return Container(
              margin: EdgeInsets.all(18),
              child: Column(
                children: [
                  HelloUser(
                    user: user,
                    withButton: true,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: InfoMenuList(
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
                                    type: Order, appBar: true, title: "주문 내역"),
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
                                    type: Gift, appBar: true, title: "받은 선물함"),
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
                                    title: "선물 발송 내역"),
                              ),
                            );
                          },
                        ),
                        InfoMenu(
                          icon: Icon(Icons.card_giftcard),
                          text: "상품권 보관함",
                          badgeCount: widget.badges['voucher'],
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VoucherList(),
                              ),
                            ).then(updateBadges);
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 40),
                          child: InfoMenu(
                            icon: Icon(Icons.info),
                            text: "정보 보기",
                            onClick: () {
                              navigateRoute(context, H4PayInfoPage());
                            },
                          ),
                        ),
                        InfoMenu(
                          icon: Icon(Icons.logout),
                          text: "로그아웃",
                          onClick: () {
                            showAlertDialog(context, "로그아웃", "정말로 로그아웃 하시겠습니까?",
                                () {
                              logout();
                              navigateRoute(
                                context,
                                IntroPage(canGoBack: false),
                              );
                            }, () {
                              Navigator.pop(context);
                            });
                          },
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
    );
  }
}

class HelloUser extends StatelessWidget {
  final H4PayUser user;
  final bool withButton;

  HelloUser({required this.user, required this.withButton});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: "님",
                style: TextStyle(fontSize: 30),
              )
            ],
          ),
        ),
        withButton
            ? H4PayButton(
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
              )
            : Container(),
      ],
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
  final Function()? onClick;

  const InfoMenu(
      {Key? key,
      this.badgeCount,
      required this.icon,
      required this.text,
      this.onClick})
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
                  ? Badge(count: badgeCount!)
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

class Badge extends StatefulWidget {
  final int count;
  Badge({required this.count});

  @override
  BadgeState createState() => BadgeState();
}

class BadgeState extends State<Badge> {
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            widget.count.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
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

  _withdraw(H4PayUser user) async {
    final H4PayResult withdrawResult = await withdraw(user.uid!, user.name!);
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
                  navigateRoute(
                    context,
                    IntroPage(
                      canGoBack: false,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: H4PayAppbar(title: "내 정보", height: 56.0, canGoBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HelloUser(user: widget.user, withButton: false),
            InfoMenuList(
              menu: [
                InfoMenuTitle(title: "내 정보"),
                InfoMenu(
                  icon: Icon(Icons.perm_identity),
                  text: widget.user.uid!,
                ),
                InfoMenu(
                  icon: Icon(Icons.badge),
                  text: widget.user.name!,
                ),
                InfoMenu(
                  icon: Icon(Icons.email),
                  text: widget.user.email!,
                ),
                InfoMenu(
                  icon: Icon(Icons.work),
                  text: roleStrFromLetter(widget.user.role!),
                ),
                InfoMenuTitle(title: "정보 변경"),
                InfoMenu(
                  icon: Icon(Icons.password),
                  text: "비밀번호 변경",
                  onClick: () {
                    showComponentDialog(
                      context,
                      ChangePWDialog(
                        formKey: _formKey,
                        prevPassword: prevPassword,
                        pw2Change: pw2Change,
                        pwCheck: pwCheck,
                        user: widget.user,
                      ),
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
                () {
                  _withdraw(user);
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
