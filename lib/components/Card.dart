import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Cart.dart';
import 'package:h4pay_flutter/Event.dart';
import 'package:h4pay_flutter/Home.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Purchase.dart';
import 'package:h4pay_flutter/PurchaseDetail.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/PurchaseList.dart';
import 'package:h4pay_flutter/components/Button.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:blur/blur.dart';

class CardWidget extends StatefulWidget {
  final margin;
  final child;
  final onClick;
  CardWidget({
    required this.margin,
    required this.child,
    required this.onClick,
  });

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: widget.margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(23),
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () {
          widget.onClick();
        },
        child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
            ),
            child: widget.child),
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final Icon icon;
  final String text;
  final Color textColor;
  final Color backgroundColor;

  const AlertCard(
      {Key? key,
      required this.icon,
      required this.text,
      required this.textColor,
      required this.backgroundColor})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(23)),
      margin: EdgeInsets.all(23),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          icon,
          Center(
            child: Text(
              "장바구니에 추가되었습니다!",
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  bool isClicked;
  final cartOnClick;
  final giftOnClick;

  ProductCard(
      {required this.product,
      required this.isClicked,
      required this.cartOnClick,
      required this.giftOnClick});
  @override
  State<StatefulWidget> createState() => ProductCardState();
}

class ProductCardState extends State<ProductCard> {
  var addCartClicked = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(23),
        ),
      ),
      child: LayoutBuilder(
        builder: (lBuildContext, constraints) {
          return Center(
            child: Stack(
              children: [
                Container(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(23)),
                    onTap: () {
                      setState(() {
                        widget.isClicked = true;
                      });
                      HomeState? parentState =
                          context.findAncestorStateOfType<HomeState>();
                      parentState!.setState(() {
                        parentState.currentTile = widget.product.id;
                      });
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.product.img,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.width * 0.3,
                          ),
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  child: Text(
                                    widget.product.productName,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  alignment: Alignment(-1, 0),
                                ),
                                Container(
                                  child: Text(
                                    getPrettyAmountStr(widget.product.price),
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
                    ).frosted(
                      borderRadius: BorderRadius.all(
                        Radius.circular(23),
                      ),
                      blur: widget.isClicked ? 5 : 0,
                      frostColor:
                          widget.isClicked ? Colors.grey[400]! : Colors.white,
                    ),
                  ),
                ),
                IgnorePointer(
                  ignoring: !widget.isClicked,
                  child: AnimatedOpacity(
                    opacity: widget.isClicked ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Center(
                          child: Container(
                            width: constraints.maxWidth / 2,
                            height: constraints.maxHeight,
                            child: InkWell(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(23),
                                bottomLeft: Radius.circular(23),
                              ),
                              onTap: () {
                                widget.cartOnClick(widget.product.id);
                              },
                              child: Container(
                                child: Center(
                                  child: Icon(Icons.shopping_cart),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: constraints.maxWidth / 2,
                            height: constraints.maxHeight,
                            child: InkWell(
                              onTap: widget.giftOnClick,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(23),
                                bottomRight: Radius.circular(23),
                              ),
                              child: Icon(Icons.redeem),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CartCard extends StatefulWidget {
  final Product product;
  final int qty;
  CartCard({required this.product, required this.qty});

  @override
  CartCardState createState() => CartCardState();
}

class CartCardState extends State<CartCard> {
  @override
  Widget build(BuildContext context) {
    CartState? parentState = context.findAncestorStateOfType<CartState>();
    var cartMap = parentState!.cartMap;
    return CardWidget(
      margin: EdgeInsets.symmetric(vertical: 9),
      onClick: () {},
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return WideCardScaffold(
            imageUrl: widget.product.img,
            cardContent: [
              Container(
                width: constraints.maxWidth * 0.39,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        widget.product.productName.replaceAll(' | ', '\n'),
                        //dummy.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    Text(
                      getPrettyAmountStr(widget.product.price * widget.qty),
                      style: TextStyle(fontSize: 20),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (widget.qty != 1) {
                              parentState.decrementCounter(widget.product.id);
                            }
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Text(
                          widget.qty.toString(),
                        ),
                        IconButton(
                          onPressed: () {
                            parentState.incrementCounter(widget.product.id);
                          },
                          icon: Icon(Icons.add),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Spacer(),
              Container(
                child: TextButton(
                  onPressed: () {
                    parentState.setState(() {
                      parentState.cartMap.remove('${widget.product.id}');
                    });
                    parentState.updateCart();
                  },
                  child: Text("삭제"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class WideCardScaffold extends StatelessWidget {
  final String imageUrl;
  final List<Widget> cardContent;

  const WideCardScaffold(
      {Key? key, required this.imageUrl, required this.cardContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [ProductImage(imageUrl: imageUrl), ...cardContent],
    );
  }
}

class ProductImage extends StatelessWidget {
  final imageUrl;
  const ProductImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 제품 사진
      padding: EdgeInsets.all(20),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => Icon(Icons.error),
        width: MediaQuery.of(context).size.width * 0.25,
        height: MediaQuery.of(context).size.width * 0.25,
      ),
    );
  }
}

class PurchaseCard extends StatelessWidget {
  final Purchase purchase;
  final Product product;

  const PurchaseCard({Key? key, required this.purchase, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "No. ${purchase.orderId}",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            getPrettyDateStr(purchase.date, true),
          ),
          Divider(color: Colors.black),
          WideCardScaffold(
            imageUrl: product.img,
            cardContent: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getProductName(purchase.item, product),
                  ),
                  Text(
                    getPrettyAmountStr(purchase.amount),
                  ),
                  Text(
                    getPrettyDateStr(purchase.expire, true),
                  ),
                  Text(
                    purchase.exchanged ? "교환 됨" : "",
                  ),
                ],
              )
            ],
          ),
          Container(
            child: purchase.uid != null
                ? H4PayButton(
                    text: "주문 취소",
                    width: double.infinity,
                    onClick: () {
                      showAlertDialog(
                          context, "주문 취소", "주문을 취소하시겠습니까?\n결제한 금액은 환불됩니다.",
                          () async {
                        final isCanceled = await cancelOrder(purchase.orderId);
                        if (isCanceled) {
                          showSnackbar(
                            context,
                            "취소 처리 되었습니다.",
                            Colors.green,
                            Duration(
                              seconds: 1,
                            ),
                          );
                          PurchaseListState? parentState = context
                              .findAncestorStateOfType<PurchaseListState>();
                          parentState!.setState(() {
                            parentState.componentKey++;
                          });
                        } else {
                          showSnackbar(
                            context,
                            "취소 처리에 실패했습니다.",
                            Colors.red,
                            Duration(
                              seconds: 1,
                            ),
                          );
                        }
                        Navigator.pop(context, "OK");
                      }, () {
                        Navigator.pop(context, "Cancel");
                      });
                    },
                    backgroundColor: Colors.red,
                  )
                : Container(),
          )
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 9.0, horizontal: 18.0),
      onClick: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseDetailPage(
              purchase: purchase,
            ),
          ),
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.name,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25)),
              Text("${getPrettyAmountStr(event.price)} 할인"),
              Text(
                  "${getPrettyDateStr(event.start, false)} ~ ${getPrettyDateStr(event.start, false)}")
            ],
          ),
          Spacer(),
          Image.network(
            'https://m.kyochon.com/resources/image/contents/event/customEvent/img_event_custom_10.jpg',
            width: MediaQuery.of(context).size.width * 0.2,
          ),
        ],
      ),
      onClick: () {
        showCustomAlertDialog(
            context,
            event.name,
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                      'https://m.kyochon.com/resources/image/contents/event/customEvent/img_event_custom_10.jpg'),
                  Container(
                    height: 30,
                  ),
                  Text("${getPrettyAmountStr(event.price)} 할인"),
                  Text(
                      "${getPrettyDateStr(event.start, false)} ~ ${getPrettyDateStr(event.start, false)}")
                ],
              ),
            ],
            [
              H4PayButton(
                text: "닫기",
                onClick: () {
                  Navigator.pop(context);
                },
                backgroundColor: Colors.blue,
                width: double.infinity,
              )
            ],
            true);
      },
    );
  }
}
