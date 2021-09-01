import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/components/Card.dart';
import 'package:http/http.dart' as http;
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'H4Pay', prefs: prefs),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.prefs})
      : super(key: key);

  final String title;
  final SharedPreferences prefs;

  @override
  _MyHomePageState createState() => _MyHomePageState(prefs);
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIdx = 2;

  int _giftBadgeCount = 0;
  int _accountBadgeCount = 0;
  int _cartBadgeCount = 0;

  final SharedPreferences prefs;

  _MyHomePageState(this.prefs);

  Future<String> fetchStoreState() async {
    final response =
        await http.get(Uri.parse('https://yoon-lab.xyz:23408/api/store'));
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

  Future<int> updateBadges() async {
    // calculate cart items, orders, gifts and set badge states.
    final orders = await fetchOrder('ckm0728wash');
    final gifts = await fetchGift('ckm0728wash');
    int orderCount = 0;
    int giftCount = 0;
    if (orders != null) {
      orders.forEach(
        (order) => {
          if (!order.exchanged) {orderCount++},
        },
      );
      setState(() {
        _accountBadgeCount = orderCount;
      });
    }
    if (gifts != null) {
      gifts.forEach(
        (gift) => {
          if (!gift.exchanged) {giftCount++}
        },
      );
      setState(() {
        _giftBadgeCount = giftCount;
      });
    }

    return 0;
  }

  @override
  void initState() {
    super.initState();
    updateBadges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: () {
              print('Pressed Home');
            },
            child: FutureBuilder(
              future: fetchStoreState(),
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
          SingleChildScrollView(
            child: Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(height: 170.0),
                  items: [1, 2, 3, 4, 5].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.fromLTRB(5, 12, 5, 0),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(23),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x1a000000),
                                  offset: Offset(0.0, 1.0),
                                  blurRadius: 6.0,
                                  spreadRadius: 0.1,
                                ),
                              ],
                            ),
                            child: Center(
                                child: Text(
                              'Advertisement $i',
                              style: TextStyle(fontSize: 16.0),
                            )));
                      },
                    );
                  }).toList(),
                ),
                FutureBuilder(
                  future: fetchProduct(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final products = snapshot.data as List<Product>;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        children: List.generate(
                          products.length,
                          (index) {
                            EdgeInsets margin;
                            index % 2 == 0
                                ? margin = EdgeInsets.fromLTRB(22, 12, 9, 12)
                                : margin = EdgeInsets.fromLTRB(9, 12, 22, 12);
                            return CardWidget(
                              margin: margin,
                              onClick: () {
                                addProductToCart(index);
                              },
                              child: Column(
                                children: [
                                  Image.network(
                                    products[index].img,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Text(
                                            products[index].productName,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          alignment: Alignment(-1, 0),
                                        ),
                                        Container(
                                          child: Text(
                                            "${products[index].price} 원",
                                            textAlign: TextAlign.left,
                                          ),
                                          alignment: Alignment(-1, 0),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment(-1, 0),
                                    padding: EdgeInsets.only(left: 20),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        items: [
          CustomNavigationBarItem(
            icon: Icon(Icons.support_agent),
          ),
          CustomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              showBadge: _giftBadgeCount != 0,
              badgeCount: _giftBadgeCount),
          CustomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          CustomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              showBadge: _cartBadgeCount != 0,
              badgeCount: _cartBadgeCount),
          CustomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              showBadge: _accountBadgeCount != 0,
              badgeCount: _accountBadgeCount)
        ],
        currentIndex: _currentIdx,
        backgroundColor: Colors.white,
        onTap: (i) {
          setState(() {
            _currentIdx = i;
          });
        },
      ),
    );
  }

  addProductToCart(int id) {
    final cartString = prefs.getString('cart'); // SharedPrefernce에서 장바구니 로드
    Map cartMap = {"$id": 1}; // 장바구니 데이터가 없을 때 초기 데이터.
    if (cartString != null) {
      cartMap = json.decode(cartString); // 장바구니 데이터 파싱
      cartMap["$id"] == null
          ? cartMap["$id"] = 1
          : cartMap["$id"]++; // 해당 ID의 데이터가 없으면 1개로, 있으면 1 더하기
    }
    prefs.setString('cart',
        json.encode(cartMap)); // 장바구니 데이터 Stringify 후 SharedPreference에 저장
    int itemCount = 0;
    cartMap.forEach((key, value) {
      itemCount += value as int;
    });
    setState(() {
      _cartBadgeCount = itemCount;
    });
  }
}
