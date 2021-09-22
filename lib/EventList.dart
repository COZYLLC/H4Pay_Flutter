import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Event.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:h4pay_flutter/components/Card.dart';

class EventListPage extends StatefulWidget {
  @override
  EventListPageState createState() => EventListPageState();
}

class EventListPageState extends State<EventListPage> {
  Future<List<Event>?>? _eventFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _eventFuture = fetchEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Event> event = snapshot.data as List<Event>;
            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    itemCount: event.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return EventCard(event: event[index]);
                    },
                  ),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
