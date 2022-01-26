import 'package:flutter/material.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/model/School.dart';

class SelectorBottomSheet extends StatefulWidget {
  @override
  SelectorBottomSheetState createState() => SelectorBottomSheetState();
}

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
        color: selected ? Colors.grey : Colors.transparent,
        child: Text(text),
      ),
    );
  }
}

class SelectorBottomSheetState extends State<SelectorBottomSheet> {
  String? selectedSchool = null;

  Future<List<School>> _getSchools() async {
    await Future.delayed(Duration(seconds: 1));

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: Colors.grey[300],
      ),
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                "학교를 선택하세요",
                style: TextStyle(fontSize: 28),
              ),
              FutureBuilder(
                future: _getSchools(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    final List<School> schools = snapshot.data;
                    return ListView.builder(
                      itemCount: schools.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int idx) {
                        return SelectorItem(
                          selected: selectedSchool == schools[idx].id,
                          text: schools[idx].name,
                          onClick: () {
                            setState(() {
                              debugPrint(schools[idx].id);
                              selectedSchool = schools[idx].id;
                            });
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return ErrorPage((snapshot.error) as Exception);
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            ],
          ),
          H4PayButton(
            text: "확인",
            onClick: selectedSchool != null ? () {} : null,
            width: double.infinity,
          )
        ],
      ),
    );
  }
}
