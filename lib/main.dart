import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/components/Products.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:custom_navigation_bar/custom_navigation_bar.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'H4Pay'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIdx = 2;

  int _giftBadgeCount = 0;
  int _accountBadgeCount = 0;
  int _cartBadgeCount = 0;

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
    if (orders != null) {
      setState(() {
        _accountBadgeCount = orders.length;
      });
    }
    if (gifts != null) {
      setState(() {
        _giftBadgeCount = gifts.length;
      });
    }

    return 0;
  }

  @override
  void initState() {
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
                      return ProductsWidget(products: products);
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
}
