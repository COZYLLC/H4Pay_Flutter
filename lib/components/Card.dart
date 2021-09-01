import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardWidget extends StatefulWidget {
  CardWidget(
      {required this.margin, required this.child, required this.onClick});
  final margin;
  final child;
  final onClick;

  @override
  _CardWidgetState createState() => _CardWidgetState(margin, child, onClick);
}

class _CardWidgetState extends State<CardWidget> {
  final _margin;
  final _child;
  final _onClick;

  _CardWidgetState(this._margin, this._child, this._onClick);

  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: _margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(23),
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () {
          _onClick();
        },
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
            ),
            child: _child),
      ),
    );
  }
}
