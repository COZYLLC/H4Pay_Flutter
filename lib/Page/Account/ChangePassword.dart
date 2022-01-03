import 'package:flutter/material.dart';
import 'package:h4pay/Page/IntroPage.dart';
import 'package:h4pay/Page/Success.dart';
import 'package:h4pay/User.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/Util/validator.dart';

class ChangePWDialog extends H4PayDialog {
  final GlobalKey<FormState> formKey;
  final TextEditingController prevPassword;
  final TextEditingController pw2Change;
  final TextEditingController pwCheck;
  final H4PayUser user;

  ChangePWDialog({
    required this.formKey,
    required this.prevPassword,
    required this.pw2Change,
    required this.pwCheck,
    required this.user,
  }) : super(
          title: "비밀번호 변경",
          content: Container(),
        );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(23.0),
        ),
      ),
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  H4PayInput(
                    isPassword: true,
                    title: "기존 비밀번호",
                    controller: prevPassword,
                    validator: null,
                  ),
                  H4PayInput(
                    isPassword: true,
                    title: "변경할 비밀번호",
                    controller: pw2Change,
                    validator: pwValidator,
                  ),
                  H4PayInput.done(
                    isPassword: true,
                    title: "비밀번호 확인",
                    controller: pwCheck,
                    validator: (value) =>
                        value == pw2Change.text ? null : "비밀번호가 일치하지 않습니다.",
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        H4PayButton(
          text: "비밀번호 변경",
          onClick: () {
            _changePassword(context);
          },
          backgroundColor: Theme.of(context).primaryColor,
          width: double.infinity,
        ),
      ],
    );
  }

  Future _changePassword(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (await changePassword(user, prevPassword.text, pw2Change.text)) {
        navigateRoute(
          context,
          SuccessPage(
            title: "비밀번호 변경 완료",
            canGoBack: false,
            successText: "비밀번호 변경이\n완료되었습니다.",
            bottomDescription: [Text("변경한 비밀번호로 다시 로그인해주세요.")],
            actions: [
              H4PayButton(
                text: "로그인 하러 가기",
                backgroundColor: Theme.of(context).primaryColor,
                width: double.infinity,
                onClick: () {
                  navigateRoute(
                    context,
                    IntroPage(canGoBack: false),
                  );
                },
              )
            ],
          ),
        );
      } else {
        Navigator.pop(context);
        showSnackbar(
          context,
          "비밀번호 변경에 실패했습니다.",
          Colors.red,
          Duration(seconds: 1),
        );
      }
    }
  }
}
