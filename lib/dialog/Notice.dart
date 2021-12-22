import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Notice.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';

class NoticeDialog extends H4PayDialog {
  final BuildContext context;
  final Notice notice;
  NoticeDialog({
    required this.context,
    required this.notice,
  }) : super(
          title: "공지사항",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(imageUrl: notice.img),
              Container(
                height: 30,
              ),
              Text(notice.content.replaceAll("\\n", "\n")),
              Text(getPrettyDateStr(notice.date, false))
            ],
          ),
          actions: [
            H4PayCloseButton(
              context: context,
            ),
          ],
        );
}
