import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class H4PayButton extends StatelessWidget {
  final String text;
  final onClick;
  final Color backgroundColor;
  final double width;

  const H4PayButton(
      {Key? key,
      required this.text,
      required this.onClick,
      required this.backgroundColor,
      required this.width})
      : super(key: key);
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: ElevatedButton(
        child: Text(this.text),
        onPressed: this.onClick,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
            backgroundColor,
          ),
        ),
      ),
    );
  }
}
