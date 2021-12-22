import 'package:flutter/material.dart';

class H4PayButton extends StatelessWidget {
  final String text;
  final Function()? onClick;
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

class H4PayCloseButton extends H4PayButton {
  final BuildContext context;
  H4PayCloseButton({required this.context})
      : super(
          text: "닫기",
          onClick: () {
            Navigator.pop(context);
          },
          backgroundColor: Theme.of(context).primaryColor,
          width: double.infinity,
        );
}

class H4PayOkButton extends H4PayButton {
  final BuildContext context;
  final Function()? onClick;

  H4PayOkButton({
    required this.context,
    this.onClick,
  }) : super(
          text: "확인",
          onClick: onClick ??
              () {
                Navigator.pop(context);
              },
          backgroundColor: Theme.of(context).primaryColor,
          width: double.infinity,
        );
}
