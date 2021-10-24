String? Function(String?)? idValidator = (value) {
  final RegExp regExp = RegExp(r'^[A-za-z0-9]{5,15}$');
  return regExp.hasMatch(value!) ? null : "아이디가 올바르지 않습니다.";
};

String? Function(String?)? pwValidator = (value) {
  final RegExp regExp = RegExp(
    r'(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$',
  );
  return regExp.hasMatch(value!)
      ? null
      : "비밀번호는 영대소문자와 숫자, 특수문자를 포함해 8자 이상이어야 합니다.";
};

String? Function(String?)? emailValidator = (value) {
  final RegExp regExp = RegExp(
      r'([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$');
  return regExp.hasMatch(value!) ? null : "이메일이 올바르지 않습니다.";
};

String? Function(String?)? telValidator = (value) {
  final RegExp regExp = RegExp(r'^\d{3}-\d{4}-\d{4}$');
  return regExp.hasMatch(value!) ? null : "전화번호가 올바르지 않습니다.";
};
