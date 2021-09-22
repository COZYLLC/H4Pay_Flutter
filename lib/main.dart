import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay_flutter/Cart.dart';
import 'package:h4pay_flutter/EventList.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/Home.dart';
import 'package:h4pay_flutter/Login.dart';
import 'package:h4pay_flutter/MyInfo.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/PurchaseList.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:h4pay_flutter/Support.dart';
import 'package:h4pay_flutter/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future main() async {
  await dotenv.load(fileName: ".env");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  final prefs;
  MyApp(this.prefs);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Spoqa_Han_Sans',
        primarySwatch: Colors.blue,
      ),
      //home: MyHomePage(title: 'H4Pay', prefs: prefs),
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.prefs})
      : super(key: key);

  final String title;
  final SharedPreferences prefs;

  @override
  MyHomePageState createState() => MyHomePageState(prefs);
}

class MyHomePageState extends State<MyHomePage> {
  int _currentIdx = 2;

  int giftBadgeCount = 0;
  int accountBadgeCount = 0;
  int cartBadgeCount = 0;
  Future? _fetchStoreStatus;

  final SharedPreferences prefs;
  MyHomePageState(this.prefs);

  Future updateBadges() async {
    // calculate cart items, orders, gifts and set badge states.
    final H4PayUser? user = await userFromStorage();
    final orders = await fetchOrder(user!.uid);
    final gifts = await fetchGift(user.uid);

    int orderCount = 0;
    int giftCount = 0;
    if (orders != null) {
      orders.forEach(
        (order) => {
          if (!order.exchanged) {orderCount++},
        },
      );
      setState(() {
        accountBadgeCount = orderCount;
      });
    }
    if (gifts != null) {
      gifts.forEach(
        (gift) => {
          if (!gift.exchanged) {giftCount++}
        },
      );
      setState(() {
        giftBadgeCount = giftCount;
      });
    }
    final cartString = prefs.getString('cart'); // SharedPrefernce에서 장바구니 로드
    if (cartString != null) {
      final Map cartMap = json.decode(cartString); // 장바구니 데이터 파싱
      setState(() {
        cartBadgeCount = countAllItemsInCart(cartMap);
      });
    }
  }

  Future<String> fetchStoreState() async {
    final response =
        await http.get(Uri.parse('${dotenv.env['API_URL']}/store'));
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
      EventListPage(),
      Home(prefs),
      Cart(prefs),
      MyInfo(prefs)
    ];
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                print('Pressed Home');
              },
              child: FutureBuilder(
                future: _fetchStoreStatus,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data.toString(),
                      style: TextStyle(color: Colors.white),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            _children[_currentIdx]!,
/*           AlertCard(
            icon: Icon(Icons.shopping_bag, color: Colors.white, size: 40),
            text: "장바구니에 추가되었습니다!",
            textColor: Colors.white,
            backgroundColor: Colors.green,
          ), */
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
          onTap: (i) {
            setState(() {
              _currentIdx = i;
            });
          },
        ),
      ),
    );
  }
}
