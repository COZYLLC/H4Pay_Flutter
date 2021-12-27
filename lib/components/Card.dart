import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Cart.dart';
import 'package:h4pay/Event.dart';
import 'package:h4pay/Page/Voucher/VoucherView.dart';
import 'package:h4pay/Purchase/Gift.dart';
import 'package:h4pay/Home.dart';
import 'package:h4pay/Notice.dart';
import 'package:h4pay/Purchase/Order.dart';
import 'package:h4pay/Purchase/Purchase.dart';
import 'package:h4pay/Page/Purchase/PurchaseDetail.dart';
import 'package:h4pay/Product.dart';
import 'package:h4pay/Page/Purchase/PurchaseList.dart';
import 'package:h4pay/Util/Wakelock.dart';
import 'package:h4pay/Voucher.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/Util.dart';
import 'package:blur/blur.dart';
import 'package:h4pay/dialog/Event.dart';
import 'package:h4pay/dialog/Notice.dart';
import 'package:h4pay/Util/Beautifier.dart';

class CardWidget extends StatefulWidget {
  final margin;
  final child;
  final Function()? onClick;
  CardWidget({
    required this.margin,
    required this.child,
    this.onClick,
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
        onTap: widget.onClick,
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
  final Function(int) cartOnClick;
  final Function() giftOnClick;

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
                      ).blurred(
                        blur:
                            widget.isClicked || widget.product.soldout ? 2 : 0,
                        blurColor: Colors.grey[400]!,
                        colorOpacity: widget.isClicked || widget.product.soldout
                            ? 0.5
                            : 0,
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                  ),
                ),
                widget.product.soldout
                    ? Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          color: Colors.red.withOpacity(0.5),
                        ),
                        padding: EdgeInsets.all(18),
                        child: Text(
                          "품절",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Container(),
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
    return CardWidget(
      margin: EdgeInsets.symmetric(vertical: 9),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return WideCardScaffold(
            imageUrl: widget.product.img,
            cardContent: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        widget.product.productName.replaceAll(' | ', '\n'),
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
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              if (widget.qty != 1) {
                                parentState!
                                    .decrementCounter(widget.product.id);
                              }
                            },
                            icon: Icon(Icons.remove),
                          ),
                        ),
                        Text(
                          widget.qty.toString(),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              parentState!.incrementCounter(widget.product.id);
                            },
                            icon: Icon(Icons.add),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  parentState!.setState(() {
                    parentState.cartMap.remove('${widget.product.id}');
                  });
                  parentState.updateCart();
                },
                child: Text("삭제"),
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
  final String uid;

  const PurchaseCard({
    Key? key,
    required this.purchase,
    required this.product,
    required this.uid,
  }) : super(key: key);

  _cancel(context) async {
    final isCanceled = await cancelOrder(purchase.orderId);
    if (isCanceled) {
      showSnackbar(
        context,
        "취소 처리 되었습니다.",
        Colors.green,
        Duration(seconds: 1),
      );
      PurchaseListState? parentState =
          context.findAncestorStateOfType<PurchaseListState>();
      parentState!.setState(() {
        parentState.componentKey++;
      });
    } else {
      showSnackbar(
        context,
        "취소 처리에 실패했습니다.",
        Colors.red,
        Duration(seconds: 1),
      );
    }
    Navigator.pop(context, "OK");
  }

  _extend(context) async {
    final extendRes = await (purchase as Gift).extend();
    if (extendRes.success) {
      PurchaseListState? parentState =
          context.findAncestorStateOfType<PurchaseListState>();
      parentState!.setState(() {
        parentState.componentKey++;
      });
      showSnackbar(
        context,
        "기간 연장이 완료되었습니다!",
        Colors.green,
        Duration(seconds: 1),
      );
    } else {
      showSnackbar(
        context,
        extendRes.data,
        Colors.red,
        Duration(seconds: 1),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isGift = purchase.uid == null;
    final isReceiver = purchase.uidto == uid;
    final isValid = !isPassedExpire(purchase.expire) && !purchase.exchanged;
    final canUse = !isGift || isReceiver;
    final isNotExtended = isGift && !purchase.extended!;
    final isUsable = isValid && canUse;

    final Expanded useButton = Expanded(
      flex: 8,
      child: H4PayButton(
        text: "사용 하기",
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PurchaseDetailPage(purchase: purchase),
            ),
          ).then(disableWakeLock);
        },
        backgroundColor: !isGift || isReceiver
            ? Theme.of(context).primaryColor
            : Colors.grey[400]!,
        width: MediaQuery.of(context).size.width * 0.4,
      ),
    );

    final H4PayButton cancelButton = H4PayButton(
      // 주문취소가 가능함.
      text: "주문 취소",
      width: MediaQuery.of(context).size.width * 0.4,
      onClick: () {
        showAlertDialog(
          context,
          "주문 취소",
          "주문을 취소하시겠습니까?\n결제한 금액은 환불됩니다.",
          () => _cancel(context),
          () => Navigator.pop(context),
        );
      },
      backgroundColor: Colors.red,
    );

    final H4PayButton extendButton = H4PayButton(
      // 주문취소가 불가능한 대신, 기간 연장이 가능함.
      text: "기간 연장",
      onClick: () {
        // 연장되지 않았고 수신인 기간 연장을 시도했으면
        showAlertDialog(
          // 의사 물은 후 연장 함수 호출
          context,
          "기간 연장",
          "기간을 연장하면 환불이 불가합니다.\n정말로 기간을 연장하시겠습니까?",
          () {
            _extend(context);
          },
          () {
            Navigator.pop(context);
          },
        );
      },
      backgroundColor: isGift && (purchase.extended! || !isReceiver)
          ? Colors.grey[400]!
          : Theme.of(context).primaryColor,
      width: MediaQuery.of(context).size.width * 0.4,
    );

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("No. ${purchase.orderId}",
              style: TextStyle(fontWeight: FontWeight.w700)),
          Text(getPrettyDateStr(purchase.date, true)),
          Divider(color: Colors.black),
          WideCardScaffold(
            imageUrl: product.img,
            cardContent: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getOrderName(purchase.item, product.productName)),
                    Text(getPrettyAmountStr(purchase.amount)),
                    Text(getPrettyDateStr(purchase.expire, true) + " 까지"),
                    (purchase.exchanged)
                        ? Text("교환됨", style: TextStyle(color: Colors.red))
                        : Container(),
                    isPassedExpire(purchase.expire)
                        ? Text("만료됨", style: TextStyle(color: Colors.red))
                        : Container(),
                  ],
                ),
              )
            ],
          ),
          Container(
            child: isValid //만료되지 않았고 교환되지 않은 것
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isUsable // 만료되지 않았고 일반 주문이거나 수신자이면
                          ? useButton
                          : Container(),
                      !isGift || (isNotExtended && isReceiver)
                          ? Expanded(
                              flex: 8,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: !isGift // 일반 주문일 경우에
                                    ? cancelButton
                                    : isNotExtended & isReceiver
                                        ? extendButton
                                        : Container(),
                              ),
                            )
                          : Container()
                    ],
                  )
                : Container(),
          )
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 9.0, horizontal: 18.0),
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
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  softWrap: false,
                ),
                Text("${getPrettyAmountStr(event.price)} 할인"),
                Text(
                    "${getPrettyDateStr(event.start, false)} ~ ${getPrettyDateStr(event.start, false)}")
              ],
            ),
          ),
          Spacer(),
          CachedNetworkImage(
            imageUrl: event.img,
            width: MediaQuery.of(context).size.width * 0.2,
          ),
        ],
      ),
      onClick: () {
        showCustomAlertDialog(
          context,
          EventDialog(context: context, event: event),
          true,
        );
      },
    );
  }
}

class VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final Product? product;
  VoucherCard({
    required this.voucher,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      margin: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "No. ${voucher.id}",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(getPrettyDateStr(voucher.date, true)),
          Divider(color: Colors.black),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${voucher.issuer['name']} 님이 발송한 선물"),
              Text(getPrettyAmountStr(voucher.amount)),
            ],
          ),
          Text(getPrettyDateStr(voucher.expire, true) + " 까지"),
          H4PayButton(
            text: "사용 하기",
            onClick: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      VoucherDetailPage(voucher: voucher),
                ),
              ).then(disableWakeLock);
            },
            backgroundColor: Theme.of(context).primaryColor,
            width: double.infinity,
          )
        ],
      ),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final Notice notice;

  const NoticeCard({Key? key, required this.notice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
                ),
                Text(
                  notice.content.replaceAll("\\n", "\n"),
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
                Text(getPrettyDateStr(notice.date, false))
              ],
            ),
          ),
          Spacer(),
          CachedNetworkImage(
            imageUrl: notice.img,
            width: MediaQuery.of(context).size.width * 0.2,
          ),
        ],
      ),
      onClick: () {
        showCustomAlertDialog(
          context,
          NoticeDialog(
            context: context,
            notice: notice,
          ),
          true,
        );
      },
    );
  }
}
