import 'package:flutter/widgets.dart';

class ErrorPage extends StatelessWidget {
  final String title;
  final String description;
  ErrorPage({required this.title, required this.description});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Text(title), Text(description)],
    );
  }
}
