import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Cart.dart';
import 'package:h4pay_flutter/Home.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/main.dart';

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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
            ),
            child: widget.child),
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
            child: AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                firstChild: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Center(
                      child: Container(
                        width: constraints.maxWidth / 2,
                        height: constraints.maxHeight,
                        child: Stack(
                          children: [
                            InkWell(
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
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: constraints.maxWidth / 2,
                      height: constraints.maxHeight,
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: widget.giftOnClick,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(23),
                              bottomRight: Radius.circular(23),
                            ),
                            child: Container(),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.redeem),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                secondChild: Container(
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
                                        fontSize: 15),
                                  ),
                                  alignment: Alignment(-1, 0),
                                ),
                                Container(
                                  child: Text(
                                    "${widget.product.price} 원",
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
                    ),
                  ),
                ),
                crossFadeState: widget.isClicked
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond),
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
      child: Row(
        children: [
          ProductImage(
            imageUrl: widget.product.img,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  widget.product.productName,
                  //dummy.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.fade,
                ),
              ),
              Text(
                (widget.product.price * widget.qty).toString(),
                style: TextStyle(fontSize: 20),
              ),
              Row(
                children: [
                  widget.qty != 1
                      ? IconButton(
                          onPressed: () {
                            parentState.decrementCounter(widget.product.id);
                          },
                          icon: Icon(Icons.remove),
                        )
                      : Container(),
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
          Spacer(),
          TextButton(
            onPressed: () {
              parentState.setState(() {
                parentState.cartMap.remove('${widget.product.id}');
              });
              parentState.updateCart();
            },
            child: Text("삭제"),
          ),
        ],
      ),
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
