import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay/Network/H4PayService.dart';

import 'package:h4pay/Page/Cart.dart';
import 'package:h4pay/Page/IntroPage.dart';
import 'package:h4pay/Page/NoticeList.dart';
import 'package:h4pay/Page/Home.dart';
import 'package:h4pay/Page/Account/MyPage.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Page/Support.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Purchase/Gift.dart';
import 'package:h4pay/model/Purchase/Order.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/Util/Connection.dart';
import 'package:h4pay/model/Voucher.dart';
import 'package:h4pay/Util/creatematerialcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  if (kReleaseMode) {
    await dotenv.load(fileName: ".env");
  } else {
    await dotenv.load(fileName: ".env.development");
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await loadApiUrl(prefs);
  runApp(MyApp(prefs));
}

loadApiUrl(SharedPreferences prefs) async {
  if (prefs.getString("API_URL") == null || prefs.getString("API_URL") == "") {
    // prefs에 저장된 URL이 없으면(최초 실행) env URL을 prefs에 저장 후 연결테스트
    prefs.setString('API_URL', dotenv.env['API_URL']!);
    apiUrl = dotenv.env['API_URL'];
  } else {
    // prefs에 저장된 것으로 연결시도 후 작동하지 않으면
    apiUrl = prefs.getString("API_URL");
    if (!await connectionCheck()) {
      // env에 저장된 것으로 시도
      apiUrl = dotenv.env['API_URL'];
    }
  }
}

class MyApp extends StatelessWidget {
  final prefs;
  MyApp(this.prefs);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: MaterialApp(
            theme: ThemeData(
              fontFamily: 'Spoqa_Han_Sans',
              primarySwatch: createMaterialColor(Color(0xff5B82D1)),
              primaryColor: Color(0xff5B82D1),
            ),
            //home: MyHomePage(title: 'H4Pay', prefs: prefs),
            home: IntroPage(
              canGoBack: false,
            ),
          ),
        ));
  }
}

class H4PayAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final double height;
  final bool canGoBack;
  final Function()? backPressed;
  H4PayAppbar(
      {Key? key,
      required this.title,
      this.actions,
      required this.height,
      required this.canGoBack,
      this.backPressed});

  @override
  H4PayAppbarState createState() => H4PayAppbarState();

  @override
  Size get preferredSize => Size(0, this.height);
}

class H4PayAppbarState extends State<H4PayAppbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 0, top: 10),
      child: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: widget.canGoBack,
        centerTitle: false,
        leading: widget.canGoBack
            ? IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: widget.backPressed == null
                    ? () {
                        Navigator.pop(context);
                      }
                    : widget.backPressed,
                color: Colors.black,
              )
            : null,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: widget.actions,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.prefs}) : super(key: key);

  final SharedPreferences prefs;

  @override
  MyHomePageState createState() => MyHomePageState(prefs);
}

class MyHomePageState extends State<MyHomePage> {
  int _currentIdx = 2;
  final H4PayService service = getService();
  int giftBadgeCount = 0;
  int accountBadgeCount = 0;
  int voucherBadgeCount = 0;
  int cartBadgeCount = 0;
  Map<String, int> badges = {'order': 0, 'gift': 0, 'voucher': 0};
  String _title = "H4Pay";
  Future? _fetchStoreStatus;

  final SharedPreferences prefs;
  MyHomePageState(this.prefs);

  Future updateBadges() async {
    // calculate cart items, orders, gifts, vouchers and set badge states.
    final H4PayUser? user = await userFromStorage();
    if (user == null) {
      showSnackbar(
        context,
        "사용자 정보를 불러올 수 없습니다. 앱을 종료합니다.",
        Colors.red,
        Duration(seconds: 1),
      );
      await Future.delayed(Duration(seconds: 3));
      exit(0);
    }
    List<Order> orders;
    List<Gift> gifts;
    List<Voucher> vouchers;

    try {
      orders = [];
      gifts = [];
      vouchers = await service.getVouchers(user.tel!);
    } on NetworkException catch (e) {
      showSnackbar(
        context,
        "(${e.statusCode}) 서버 오류가 발생했습니다. 고객센터로 문의해주세요.",
        Colors.red,
        Duration(seconds: 3),
      );
      return;
    }

    int orderCount = 0;
    int giftCount = 0;
    int voucherCount = 0;

    orders.forEach(
      (order) => {
        if (!order.exchanged) orderCount++,
      },
    );
    gifts.forEach(
      (gift) => {if (!gift.exchanged && gift.uidto == user.uid) giftCount++},
    );
    vouchers.forEach(
      (voucher) => {
        if (!voucher.exchanged &&
            DateTime.parse(voucher.expire).millisecondsSinceEpoch >
                DateTime.now().millisecondsSinceEpoch)
          voucherCount++
      },
    );

    setState(() {
      badges['order'] = orderCount;
      badges['gift'] = giftCount;
      badges['voucher'] = voucherCount;
      accountBadgeCount = orderCount + giftCount + voucherCount;
    });
    final cartString = prefs.getString('cart'); // SharedPrefernce에서 장바구니 로드
    if (cartString != null) {
      final Map cartMap = json.decode(cartString); // 장바구니 데이터 파싱
      setState(() {
        cartBadgeCount = countAllItemsInCart(cartMap);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateBadges();
    _fetchStoreStatus = service.getStoreStatus();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget?> _children = [
      SupportPage(),
      EventListPage(),
      Home(prefs),
      Cart(prefs),
      MyPage(prefs: prefs, badges: badges)
    ];
    List<String> titles = ["지원", "이벤트", "H4Pay", "장바구니", "마이페이지"];

    return WillPopScope(
      onWillPop: () async => onBackPressed(context, true),
      child: Scaffold(
        appBar: H4PayAppbar(
          title: _title,
          height: 56.0,
          actions: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                child: FutureBuilder(
                  future: _fetchStoreStatus,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final bool isOpened = snapshot.data as bool;
                      return Text(
                        isOpened ? "OPEN" : "CLOSE",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
          ],
          canGoBack: false,
        ),
        body: Stack(
          children: [
            _children[_currentIdx]!,
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(
          items: [
            CustomNavigationBarItem(
              icon: Icon(Icons.support_agent),
            ),
            CustomNavigationBarItem(
              icon: Icon(Icons.celebration),
            ),
            CustomNavigationBarItem(
              icon: Icon(Icons.home),
            ),
            CustomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              showBadge: cartBadgeCount != 0,
              badgeCount: cartBadgeCount,
            ),
            CustomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              showBadge: accountBadgeCount != 0,
              badgeCount: accountBadgeCount,
            )
          ],
          currentIndex: _currentIdx,
          backgroundColor: Colors.white,
          selectedColor: Theme.of(context).primaryColor,
          onTap: (i) {
            setState(() {
              _currentIdx = i;
              _title = titles[i];
            });
          },
        ),
      ),
    );
  }
}
