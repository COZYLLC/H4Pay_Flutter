import 'package:flutter/material.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Event.dart';
import 'package:h4pay/model/Notice.dart';
import 'package:h4pay/Page/Purchase/PurchaseList.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/model/User.dart';

class NoticeListPage extends ListPage {
  NoticeListPage()
      : super(
          withAppBar: true,
          type: Notice,
          dataFuture: getService().getNotices,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<Notice> data = snapshot.data;

              if (data.length != 0) {
                return ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return NoticeCard(notice: data[index]);
                  },
                );
              } else {
                return CenterInScroll(
                  child: Text(
                    "공지사항이 없는 것 같아요.",
                  ),
                );
              }
            } else if (snapshot.hasError) {
              showServerErrorSnackbar(
                context,
                snapshot.error as NetworkException,
              );
              return ErrorPage(snapshot.error as Exception);
            } else {
              return CenterInScroll(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
}

class CenterInScroll extends StatelessWidget {
  final Widget child;
  CenterInScroll({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.4,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class EventListPage extends ListPage {
  EventListPage()
      : super(
          withAppBar: true,
          type: Event,
          dataFuture: getService().getAllEvents,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List data = snapshot.data as List;
              if (data.length != 0) {
                return ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return EventCard(event: data[index] as Event);
                  },
                );
              } else {
                return CenterInScroll(
                  child: Text("이벤트가 없는 것 같아요."),
                );
              }
            } else if (snapshot.hasError) {
              showServerErrorSnackbar(
                context,
                snapshot.error as Exception,
              );
              return ErrorPage(snapshot.error as Exception);
            } else {
              return CenterInScroll(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
}
