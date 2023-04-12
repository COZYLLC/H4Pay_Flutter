import 'package:flutter/material.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';

class LoadingDialog extends H4PayDialog {
  final String title;
  LoadingDialog({
    required this.title,
  }) : super(
          title: title,
          content: SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
}
