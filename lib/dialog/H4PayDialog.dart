import 'package:flutter/material.dart';

class H4PayDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const H4PayDialog(
      {Key? key, required this.title, required this.content, this.actions})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(23.0),
        ),
      ),
      contentPadding: EdgeInsets.all(23),
      title: Text(title),
      content: SingleChildScrollView(child: content),
      actions: actions,
      actionsPadding: EdgeInsets.symmetric(horizontal: 23),
    );
  }
}
