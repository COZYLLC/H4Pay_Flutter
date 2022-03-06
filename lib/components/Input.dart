import 'dart:async';

import 'package:flutter/material.dart';
import 'package:h4pay/Util/mp.dart';
import 'package:h4pay/components/Button.dart';

enum H4PayInputType { next, done, button }

class H4PayInput extends StatefulWidget {
  final bool? isPassword;
  final bool? isNumber;
  final String title;
  final TextEditingController controller;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool? isMultiLine;
  final H4PayInputType type;
  final String? Function(String?)? validator;
  final int? minLines;
  final FutureOr Function()? onEditingComplete;
  final List<MultiMaskedTextInputFormatter>? inputFormatters;
  final String? buttonText;
  final Function()? onButtonClick;
  final Function()? onFieldClick;
  final int? maxLength;

  const H4PayInput(
      {Key? key,
      this.isPassword,
      this.isNumber,
      required this.title,
      required this.controller,
      this.backgroundColor,
      this.borderColor,
      this.isMultiLine,
      this.validator,
      this.maxLength,
      this.minLines,
      this.onEditingComplete,
      this.inputFormatters,
      this.buttonText,
      this.onButtonClick,
      this.onFieldClick})
      : type = H4PayInputType.next,
        super(key: key);

  const H4PayInput.button({
    Key? key,
    this.isPassword,
    this.isNumber,
    required this.title,
    required this.controller,
    this.backgroundColor,
    this.borderColor,
    this.isMultiLine,
    this.validator,
    this.minLines,
    this.onEditingComplete,
    this.inputFormatters,
    required this.buttonText,
    this.onButtonClick,
    this.onFieldClick,
    this.maxLength,
  })  : type = H4PayInputType.button,
        super(key: key);

  const H4PayInput.done({
    Key? key,
    this.isPassword,
    this.isNumber,
    required this.title,
    required this.controller,
    this.backgroundColor,
    this.borderColor,
    this.isMultiLine,
    this.validator,
    this.minLines,
    this.onEditingComplete,
    this.inputFormatters,
    this.buttonText,
    this.onButtonClick,
    this.onFieldClick,
    this.maxLength,
  })  : type = H4PayInputType.done,
        super(key: key);

  @override
  H4PayInputState createState() => H4PayInputState();
}

class H4PayInputState extends State<H4PayInput> {
  final Color defaultBackgroundColor = Colors.grey[200]!;
  final Color defaultBorderColor = Colors.grey[700]!;

  @override
  Widget build(BuildContext context) {
    final roundBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(23),
    );
    final InputDecoration roundDecoration = InputDecoration(
      fillColor: widget.backgroundColor ?? defaultBackgroundColor,
      filled: true,
      border: roundBorder,
      contentPadding: new EdgeInsets.all(10),
      isDense: true,
      counter: Offstage(),
    );
    final Container titleText = Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        widget.title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );

    final Container normalField = Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 8,
                child: TextFormField(
                  obscureText: widget.isPassword ?? false,
                  controller: widget.controller,
                  decoration: roundDecoration,
                  textInputAction: widget.isMultiLine ?? false
                      ? TextInputAction.newline
                      : widget.type == H4PayInputType.done
                          ? TextInputAction.done
                          : TextInputAction.next,
                  keyboardType: widget.isNumber ?? false
                      ? TextInputType.number
                      : widget.isMultiLine ?? false
                          ? TextInputType.multiline
                          : TextInputType.text,
                  maxLines: widget.isMultiLine ?? false ? null : 1,
                  minLines:
                      widget.isMultiLine ?? false ? widget.minLines : null,
                  maxLength: widget.maxLength,
                  validator: widget.validator,
                  onEditingComplete: widget.onEditingComplete,
                  inputFormatters: widget.inputFormatters,
                ),
              ),
              widget.type == H4PayInputType.button
                  ? Flexible(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.only(left: 8),
                        child: H4PayButton(
                          text: widget.buttonText!,
                          onClick: widget.onButtonClick,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ],
      ),
    );
    final Container fieldWithButton = Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleText,
            LayoutBuilder(builder: (context, constraints) {
              return Container(
                height: 40,
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      height: constraints.maxHeight,
                      child: SizedBox(
                        width: constraints.maxWidth * 0.75,
                        child: TextFormField(
                          controller: widget.controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                            isDense: true,
                            counter: Offstage(),
                          ),
                          keyboardType: widget.isNumber ?? false
                              ? TextInputType.number
                              : widget.isMultiLine ?? false
                                  ? TextInputType.multiline
                                  : TextInputType.text,
                          onTap: widget.onFieldClick,
                          maxLength: widget.maxLength,
                          inputFormatters: widget.inputFormatters,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ?? defaultBackgroundColor,
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(
                          color: widget.borderColor ?? defaultBorderColor,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: H4PayButton(
                        text: widget.buttonText ?? "확인",
                        onClick: widget.onButtonClick,
                        backgroundColor: Theme.of(context).primaryColor,
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: constraints.maxHeight,
                      ),
                    )
                  ],
                ),
              );
            }),
          ],
        ));
    return widget.type == H4PayInputType.button ? fieldWithButton : normalField;
  }
}
