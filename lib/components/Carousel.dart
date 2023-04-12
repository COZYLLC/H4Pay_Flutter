import 'package:flutter/material.dart';

class CarouselBox extends StatelessWidget {
  final String imageUrl;
  CarouselBox({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.fromLTRB(5, 12, 5, 0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        color: Theme.of(context).primaryColor,
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
    );
  }
}
