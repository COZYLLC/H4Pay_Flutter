import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Util/Connection.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/model/Notice.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpChangerDialog extends H4PayDialog {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ipEditingController = TextEditingController();
  final BuildContext context;
  IpChangerDialog(
    this.context,
  ) : super(title: "IP 주소 변경", content: Container());
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "서버 URL을 프로토콜, 포트, Route, 엔드포인트와 함께 입력해주세요. ex) https://yoon-lab.xyz:23408/api/"),
        Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.url,
            controller: _ipEditingController,
            validator: (value) {
              return value!.isNotEmpty ? null : "URL을 입력해주세요.";
            },
          ),
        ),
        H4PayOkButton(
          context: context,
          onClick: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            if (_formKey.currentState!.validate()) {
              final _prefs = await SharedPreferences.getInstance();
              _prefs.setString(
                'API_URL',
                _ipEditingController.text,
              );
              apiUrl = _ipEditingController.text;
              print("API URL newly setted: $apiUrl");
              final connStatus = await connectionCheck();
              if (connStatus) {
                Navigator.pop(context);
                showSnackbar(
                  context,
                  "IP '${_ipEditingController.text}' 로 서버 URL을 설정합니다.",
                  Colors.green,
                  Duration(seconds: 1),
                );
              } else {
                showSnackbar(
                  context,
                  "IP '${_ipEditingController.text}' 로 연결을 시도했지만 잘 안 되는 것 같네요...",
                  Colors.red,
                  Duration(seconds: 1),
                );
              }
            }
          },
        )
      ],
    );
  }
}
