import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/model/Event.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';

class EventDialog extends H4PayDialog {
  final BuildContext context;
  final Event event;
  EventDialog({required this.context, required this.event})
      : super(
          title: "이벤트",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(imageUrl: event.img),
              Container(
                height: 30,
              ),
              Text("${getPrettyAmountStr(event.price)} 할인"),
              Text(
                  "${getPrettyDateStr(event.start, false)} ~ ${getPrettyDateStr(event.end, false)}"),
              Text(event.content.replaceAll("\\n", "\n")),
            ],
          ),
        );
}
