import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductsWidget extends StatefulWidget {
  ProductsWidget({required this.products});
  final List<Product> products;

  @override
  _ProductsWidgetState createState() => _ProductsWidgetState(products);
}

class _ProductsWidgetState extends State<ProductsWidget> {
  final products;

  _ProductsWidgetState(this.products);
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      children: List.generate(products.length, (index) {
        if (index % 2 == 0)
          return Container(
            margin: EdgeInsets.fromLTRB(22, 12, 9, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1a000000),
                  offset: Offset(0.0, 3.0),
                  blurRadius: 6.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Center(
                child: Column(
              children: [
                Image.network(
                  products[index].img,
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          products[index].productName,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
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
            )),
          );
        else
          return Container(
            margin: EdgeInsets.fromLTRB(9, 12, 22, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1a000000),
                  offset: Offset(0.0, 3.0),
                  blurRadius: 6.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: products[index].img,
                    fadeInCurve: Curves.easeIn,
                    fadeOutDuration: Duration(seconds: 3),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text(
                            products[index].productName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
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
            ),
          );
      }),
    );
  }
}
