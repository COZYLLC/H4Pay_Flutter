import 'dart:async';

import 'package:flutter/material.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/SchoolSelectorItem.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/model/School.dart';

class SchoolSelectDialog extends StatefulWidget {
  @override
  SchoolSelectDialogState createState() => SchoolSelectDialogState();
}

class SchoolSelectDialogState extends State<SchoolSelectDialog> {
  School? selectedSchool = null;
  final H4PayService service = getService();
  final StreamController _searchStream = StreamController.broadcast();

  @override
  initState() {
    super.initState();
  }

  Future<List<School>> _getSchools(String? name) async {
    await Future.delayed(Duration(seconds: 1));
    debugPrint(name);
    if (name == "서전")
      return [
        School(
          name: "서전고등학교",
          id: "M100002171",
          seller: Seller(
            name: "서전고 사회적협동조합",
            address: "충청북도 진천군 덕산읍 대하로 47, 서전고 사회적협동조합",
            founderName: "안상희",
            tel: "043-537-8737",
            businessId: "564-82-00214",
            sellerId: "2021-충북진천-0007",
          ),
        ),
      ];
    if (name == "땡땡")
      return [
        School(
          name: "땡땡고등학교",
          id: "M100002172",
          seller: Seller(
            name: "서전고 사회적협동조합",
            address: "충청북도 진천군 덕산읍 대하로 47, 서전고 사회적협동조합",
            founderName: "안상희",
            tel: "043-537-8737",
            businessId: "564-82-00214",
            sellerId: "2021-충북진천-0007",
          ),
        )
      ];
    return [
      School(
        name: "서전고등학교",
        id: "M100002171",
        seller: Seller(
          name: "서전고 사회적협동조합",
          address: "충청북도 진천군 덕산읍 대하로 47, 서전고 사회적협동조합",
          founderName: "안상희",
          tel: "043-537-8737",
          businessId: "564-82-00214",
          sellerId: "2021-충북진천-0007",
        ),
      ),
      School(
        name: "땡땡고등학교",
        id: "M100002172",
        seller: Seller(
          name: "서전고 사회적협동조합",
          address: "충청북도 진천군 덕산읍 대하로 47, 서전고 사회적협동조합",
          founderName: "안상희",
          tel: "043-537-8737",
          businessId: "564-82-00214",
          sellerId: "2021-충북진천-0007",
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return H4PayDialog(
      title: "학교를 선택해주세요",
      content: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      _searchStream.add(value);
                    },
                    decoration: InputDecoration(icon: Icon(Icons.search)),
                  ),
                ),
                StreamBuilder(
                  stream: _searchStream.stream,
                  initialData: "",
                  builder: (BuildContext context, AsyncSnapshot snaps) {
                    if (snaps.hasData) {
                      return FutureBuilder(
                        future: service.getSchools(name: snaps.data),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            final List<School> schools = snapshot.data;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: schools.length,
                                  itemBuilder: (BuildContext context, int idx) {
                                    return SelectorItem(
                                      selected: selectedSchool != null
                                          ? selectedSchool!.id ==
                                              schools[idx].id
                                          : false,
                                      text: schools[idx].name,
                                      onClick: () {
                                        setState(() {
                                          selectedSchool = schools[idx];
                                        });
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return ErrorPage(snapshot.error as Exception);
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
            H4PayOkButton(
              context: context,
              onClick: selectedSchool != null
                  ? () {
                      Navigator.pop(context, selectedSchool);
                    }
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
