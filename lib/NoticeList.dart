import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Event.dart';
import 'package:h4pay/Notice.dart';
import 'package:h4pay/PurchaseList.dart';
import 'package:h4pay/components/Card.dart';

class NoticeListPage extends StatelessWidget {
  final Type type;
  final bool withAppBar;

  const NoticeListPage({Key? key, required this.type, required this.withAppBar})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListPage(
      type: type,
      withAppBar: withAppBar,
      appBarTitle: "공지사항",
      dataFuture: type == Notice ? fetchNotice() : fetchEvent(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List data = snapshot.data as List;
          if (data.length != 0) {
            return ListView.builder(
              itemCount: data.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return type == Notice
                    ? NoticeCard(notice: data[index] as Notice)
                    : EventCard(event: data[index] as Event);
              },
            );
          } else {
            return Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.4,
              ),
              color: Colors.red,
              alignment: Alignment.center,
              child: Text("장바구니가 비어 있는 것 같아요."),
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
