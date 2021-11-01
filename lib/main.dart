import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay/Cart.dart';
import 'package:h4pay/Event.dart';
import 'package:h4pay/IntroPage.dart';
import 'package:h4pay/NoticeList.dart';
import 'package:h4pay/Gift.dart';
import 'package:h4pay/Home.dart';
import 'package:h4pay/MyPage.dart';
import 'package:h4pay/Order.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Support.dart';
import 'package:h4pay/User.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/creatematerialcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future main() async {
  await dotenv.load(fileName: ".env");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await loadApiUrl(prefs);
  runApp(MyApp(prefs));
}

loadApiUrl(SharedPreferences prefs) async {
  print(prefs.getString("API_URL"));
  if (prefs.getString("API_URL") == null || prefs.getString("API_URL") == "") {
    prefs.setString('API_URL', dotenv.env['API_URL']!);
    API_URL = dotenv.env['API_URL'];
  } else {
    API_URL = prefs.getString("API_URL");
    if (!await connectionCheck()) {
      prefs.setString('API_URL', dotenv.env['API_URL']!);
      API_URL = dotenv.env['API_URL'];
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

  int giftBadgeCount = 0;
  int accountBadgeCount = 0;
  int cartBadgeCount = 0;
  Map<String, int> badges = {'order': 0, 'gift': 0};
  String _title = "H4Pay";
  Future? _fetchStoreStatus;

  final SharedPreferences prefs;
  MyHomePageState(this.prefs);

  Future<String> fetchStoreState() async {
    final response = await http.get(Uri.parse('$API_URL/store'));
    if (response.statusCode == 200) {
      bool state = jsonDecode(response.body)['isOpened'];
      if (state) {
        return 'OPEN';
      } else {
        return 'CLOSED';
      }
    } else {
      throw Exception('Failed to fetch store state.');
    }
  }

  Future updateBadges() async {
    // calculate cart items, orders, gifts and set badge states.
    print("[LOGIC] update badges");
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
    final orders = await fetchOrder(user.uid);
    final gifts = await fetchGift(user.uid);

    int orderCount = 0;
    int giftCount = 0;
    if (orders != null) {
      orders.forEach(
        (order) => {
          if (!order.exchanged) {orderCount++},
        },
      );
    }
    if (gifts != null) {
      gifts.forEach(
        (gift) => {
          if (!gift.exchanged && gift.uidto == user.uid) {giftCount++}
        },
      );
    }
    setState(() {
      badges['order'] = orderCount;
      badges['gift'] = giftCount;
      accountBadgeCount = orderCount + giftCount;
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
    _fetchStoreStatus = fetchStoreState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget?> _children = [
      SupportPage(),
      NoticeListPage(
        type: Event,
        withAppBar: false,
      ),
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
                      return Text(
                        snapshot.data.toString(),
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
