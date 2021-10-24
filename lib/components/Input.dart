import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum H4PayInputType { round, underline }

class H4PayInput extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isMultiLine;
  final H4PayInputType type;
  final String? Function(String?)? validator;
  final int? minLines;

  const H4PayInput(
      {Key? key,
      required this.title,
      required this.controller,
      this.backgroundColor,
      this.borderColor,
      required this.isMultiLine,
      required this.validator,
      this.minLines})
      : type = H4PayInputType.underline,
        super(key: key);

  const H4PayInput.round({
    Key? key,
    required this.title,
    required this.controller,
    this.backgroundColor,
    this.borderColor,
    required this.isMultiLine,
    required this.validator,
    this.minLines,
  })  : type = H4PayInputType.round,
        super(key: key);

  const H4PayInput.done({
    Key? key,
    required this.title,
    required this.controller,
    this.backgroundColor,
    this.borderColor,
    required this.isMultiLine,
    required this.validator,
    this.minLines,
  })  : type = H4PayInputType.underline,
        super(key: key);

  @override
  H4PayInputState createState() => H4PayInputState();
}

class H4PayInputState extends State<H4PayInput> {
  Color defaultBackgroundColor = Colors.grey[200]!;
  Color defaultBorderColor = Colors.grey[400]!;

  @override
  Widget build(BuildContext context) {
    BoxDecoration roundDecoration = BoxDecoration(
      color: widget.backgroundColor ?? defaultBackgroundColor,
      borderRadius: BorderRadius.circular(38),
      border: Border.all(
        color: widget.borderColor ?? defaultBorderColor,
      ),
    );
    Container titleText = Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        widget.title!,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration:
              widget.type == H4PayInputType.round ? roundDecoration : null,
          child: TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: widget.title,
            ),
            textInputAction: widget.isMultiLine
                ? TextInputAction.newline
                : TextInputAction.next,
            keyboardType: widget.isMultiLine
                ? TextInputType.multiline
                : TextInputType.text,
            maxLines: null,
            minLines: widget.isMultiLine ? widget.minLines : 1,
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
