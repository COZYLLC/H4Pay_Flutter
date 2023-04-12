import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Cart.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/Page/IntroPage.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Carousel.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Event.dart';
import 'package:h4pay/model/Notice.dart';
import 'package:h4pay/model/Product.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/dialog/Event.dart';
import 'package:h4pay/dialog/GiftOption.dart';
import 'package:h4pay/dialog/Notice.dart';
import 'package:h4pay/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:h4pay/main.dart';

class Home extends StatefulWidget {
  final SharedPreferences prefs;
  Home(this.prefs);

  @override
  HomeState createState() => HomeState(prefs);
}

class HomeState extends State<Home> {
  final SharedPreferences prefs;
  final GlobalKey _carouselKey = GlobalKey();
  final H4PayService service = getService();
  int? currentTile;
  bool cartClicked = false;
  bool moving = false;
  Future<H4PayUser?>? _userFuture;
  Future<List<Product>>? _productFuture;
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  HomeState(this.prefs);

  @override
  void initState() {
    super.initState();
    _userFuture = userFromStorage();
    _productFuture = service.getVisibleProducts();
  }

  _getAds(H4PayUser user) async {
    return this._memoizer.runOnce(() async {
      Map data = {};
      data['notices'] = await service.getNotices();
      data['events'] = await service.getAllEvents();
      return data;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<double> center = [
      MediaQuery.of(context).size.width * 0.5 -
          MediaQuery.of(context).size.width * 0.3 * 0.5,
      MediaQuery.of(context).size.height * 0.35
    ];
    return FutureBuilder(
      future: _userFuture,
      builder: (context, AsyncSnapshot<H4PayUser?> snapshot) {
        debugPrint(snapshot.data.toString());
        if (snapshot.hasData) {
          final H4PayUser? user = snapshot.data;
          if (user == null) {
            return ErrorPage(UserNotFoundException());
          }
          if (user.schoolId == null) {
            return ErrorPage(
              UserNotFoundException(
                message: "앱 데이터베이스 변경 작업으로 인해 재로그인이 필요합니다. 재로그인 후 이용해주세요.",
                onClick: () async {
                  await logout();
                  navigateRoute(context, IntroPage(canGoBack: true));
                },
              ),
            );
          }
          return FutureBuilder(
            future: _productFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<List<Product>> snapshot,
            ) {
              if (snapshot.hasData) {
                final List<Product> products = snapshot.data!;
                products.sort((a, b) => a.productName.compareTo(b.productName));
                return Stack(children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: _getAds(user),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              final List<Notice> notices =
                                  snapshot.data['notices'] as List<Notice>;
                              final List<Event> events =
                                  snapshot.data['events'] as List<Event>;
                              final noticeSublist = notices.length > 3
                                  ? notices.sublist(0, 2)
                                  : notices;
                              final eventSublist = events.length > 3
                                  ? events.sublist(0, 2)
                                  : events;
                              final adList = [
                                ...noticeSublist,
                                ...eventSublist
                              ];
                              return CarouselSlider(
                                options: CarouselOptions(
                                  height:
                                      MediaQuery.of(context).size.width * 0.35,
                                ),
                                items: adList.map((i) {
                                  return LayoutBuilder(
                                    builder:
                                        (BuildContext context, constraint) {
                                      return InkWell(
                                          onTap: () {
                                            i.runtimeType == Notice
                                                ? showCustomAlertDialog(
                                                    context,
                                                    NoticeDialog(
                                                      context: context,
                                                      notice: i,
                                                    ),
                                                    true,
                                                  )
                                                : showCustomAlertDialog(
                                                    context,
                                                    EventDialog(
                                                      context: context,
                                                      event: i as Event,
                                                    ),
                                                    true,
                                                  );
                                          },
                                          child: CarouselBox(imageUrl: i.img));
                                    },
                                  );
                                }).toList(),
                              );
                            } else if (snapshot.hasError) {
                              return ErrorPage(snapshot.error as Exception);
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        GridView.count(
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
                              return ProductCard(
                                product: products[index],
                                isClicked: currentTile == products[index].id,
                                cartOnClick: addProductToCart,
                                giftOnClick: () {
                                  openGiftAlert(products[index]);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedPositioned(
                    curve: Curves.fastOutSlowIn,
                    child: cartClicked
                        ? CachedNetworkImage(
                            imageUrl: products
                                .firstWhere(
                                    (product) => product.id == currentTile!)
                                .img,
                            width: MediaQuery.of(context).size.width * 0.3,
                          )
                        : Container(),
                    duration: Duration(milliseconds: 500),
                    left: moving
                        ? MediaQuery.of(context).size.width * 0.55
                        : center[0],
                    bottom: moving ? 0 : center[1],
                  )
                ]);
              } else if (snapshot.hasError) {
                debugPrint(snapshot.error.toString());
                return Text(snapshot.error.toString());
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        } else if (snapshot.hasError) {
          showSnackbar(
              context, "사용자 정보를 불러올 수 없습니다.", Colors.red, Duration(seconds: 3));
          return CircularProgressIndicator();
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  addProductToCart(int id) async {
    showSnackbar(
      context,
      "장바구니에 추가되었습니다.",
      Colors.green,
      Duration(seconds: 1),
    );
    final cartString = prefs.getString('cart'); // SharedPrefernce에서 장바구니 로드
    Map cartMap = {"$id": 1}; // 장바구니 데이터가 없을 때 초기 데이터.
    if (cartString != null) {
      cartMap = json.decode(cartString); // 장바구니 데이터 파싱
      cartMap["$id"] == null
          ? cartMap["$id"] = 1
          : cartMap["$id"]++; // 해당 ID의 데이터가 없으면 1개로, 있으면 1 더하기
    }
    prefs.setString(
      'cart',
      json.encode(cartMap),
    ); // 장바구니 데이터 Stringify 후 SharedPreference에 저장
    final MyHomePageState? parentState =
        context.findAncestorStateOfType<MyHomePageState>();
    parentState!.setState(() {
      parentState.cartBadgeCount = countAllItemsInCart(cartMap);
    });
    if (!mounted) return;
    setState(() {
      cartClicked = true;
    });
    await Future.delayed(Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      moving = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      cartClicked = false;
      moving = false;
    });
  }

  openGiftAlert(Product product) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController name = new TextEditingController();
    final TextEditingController qty = new TextEditingController();
    showCustomAlertDialog(
      context,
      GiftOptionDialog(
        context: context,
        formKey: _formKey,
        name: name,
        qty: qty,
        prefs: prefs,
        product: product,
      ),
      true,
    );
  }
}
