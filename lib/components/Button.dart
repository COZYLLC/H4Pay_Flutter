import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class H4PayButton extends StatelessWidget {
  final String text;
  final onClick;
  final Color backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const H4PayButton(
      {Key? key,
      required this.text,
      required this.onClick,
      required this.backgroundColor,
      this.textColor,
      this.width,
      this.height})
      : super(key: key);
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: ElevatedButton(
        child: Text(
          this.text,
          style: TextStyle(color: textColor),
        ),
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
