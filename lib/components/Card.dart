import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardWidget extends StatefulWidget {
  final margin;
  final child;
  final onClick;

  const CardWidget({
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
          child: widget.child,
        ),
      ),
    );
  }
}
