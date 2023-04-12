import 'package:flutter/material.dart';

class SelectorItem extends StatelessWidget {
  final bool selected;
  final String text;
  final Function()? onClick;
  SelectorItem(
      {required this.selected, required this.text, required this.onClick});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: selected ? Colors.grey[200] : Colors.transparent,
            borderRadius: BorderRadius.circular(23)),
        child: Text(text),
      ),
    );
  }
}
