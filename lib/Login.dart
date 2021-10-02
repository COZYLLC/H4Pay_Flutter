import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:h4pay_flutter/Register.dart';
import 'package:h4pay_flutter/Result.dart';
import 'package:h4pay_flutter/Setting.dart';
import 'package:h4pay_flutter/User.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:h4pay_flutter/components/Button.dart';
import 'package:h4pay_flutter/main.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class LoginPage extends StatefulWidget {
  bool canGoBack;
  LoginPage({required this.canGoBack});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Firebase.initializeApp();
    _loginCheck();
  }

  Future _loginCheck() async {
    await logout();
  }

  @override
  Widget build(BuildContext context) {
    final _loginFormKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        return widget.canGoBack;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("로그인"),
          centerTitle: true,
          automaticallyImplyLeading: widget.canGoBack,
        ),
        body: Container(
          margin: EdgeInsets.all(40),
          child: Column(
            children: [
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: "아이디",
                      ),
                      validator: (value) {
                        final RegExp regExp = RegExp(r'^[A-za-z0-9]{5,15}$');
                        print("[VALIDATOR] ${regExp.hasMatch(value!)}");
                        if (!regExp.hasMatch(value)) {
                          return "아이디는 영소문자와 숫자를 포함해 5자 이상 19자 이하여아 합니다.";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (_) {
                        _loginFormKey.currentState!.validate();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      controller: _pwController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "비밀번호",
                      ),
                      validator: (value) {
                        final RegExp regExp = RegExp(
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$');
                        if (!regExp.hasMatch(value!)) {
                          return "비밀번호는 영대소문자와 숫자, 특수문자를 포함해 8자 이상이어야 합니다.";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (_) {
                        _loginFormKey.currentState!.validate();
                      },
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
/*               H4PayButton(
                text: "googleLogin",
                onClick: _signInWithGoogle,
                backgroundColor: Theme.of(context).primaryColor,
                width: double.infinity,
              
              SignInWithAppleButton(onPressed: _signInWithApple), */
              H4PayButton(
                text: "로그인",
                width: double.infinity,
                onClick: () async {
                  _loginFormKey.currentState!.validate();
                  if (await _login(_idController.text, _pwController.text)) {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(
                          title: "H4Pay",
                          prefs: prefs,
                        ),
                      ),
                    );
                  } else {
                    showSnackbar(
                      context,
                      "아이디 혹은 비밀번호가 틀렸습니다.",
                      Colors.red,
                      Duration(
                        seconds: 1,
                      ),
                    );
                  }
                },
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

/* 
  Future<bool> _signInWithGoogle() async {
    try {
      GoogleSignInAccount? account = await GoogleSignIn(scopes: [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ]).signIn();
      if (account != null) {
        print(account.id);
        print(account.email);
        print(account.displayName);
        print(account.photoUrl);
        GoogleSignInAuthentication? authentication =
            await account.authentication;
        return await _googleLogin(authentication.idToken!);
      } else {
        return false;
      }
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> _signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        //webAuthenticationOptions: WebAuthenticationOptions(clientId: clientId, redirectUri: redirectUri)
      );

      print(credential);
      return true;
      // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
      // after they have been validated with Apple (see `Integration` section for more information on how to do this)
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _googleLogin(String _idToken) async {
       final _prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse("$API_URL/users/auth/google"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(
        {'idtoken': _idToken},
      ),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print("[API] $jsonResponse");
      if (jsonResponse['verified']) {
        if (jsonResponse['existUser']) {
          final H4PayUser? user = await tokenCheck(jsonResponse['accessToken']);
          user!.saveToStorage();
          return true;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterPage(),
            ),
          );
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
 */
  Future<bool> _login(String id, String pw) async {
    final bytes = utf8.encode(pw);
    final digest = sha256.convert(bytes);
    final _prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse("$API_URL/users/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'uid': id,
        'password': base64.encode(digest.bytes),
      }),
    );
    print("LOGIN TRY");
    if (response.statusCode == 200) {
      print("LOGIN STATUS TRUE");
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status']) {
        print("JSON STATUS TRUE");
        final H4PayUser? user = await tokenCheck(jsonResponse['accessToken']);
        await user!.saveToStorage();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}

class AccountFindPage extends StatefulWidget {
  @override
  AccountFindPageState createState() => AccountFindPageState();
}

class AccountFindPageState extends State<AccountFindPage> {
  final GlobalKey<FormState> _findIdFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _findPwFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("계정 찾기"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(23),
        child: Column(
          children: [
            Text("아이디 찾기"),
            Form(
              key: _findIdFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "이름"),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final RegExp regExp = RegExp(r'^[가-힣]{2,8}$');
                      return regExp.hasMatch(value!) ? null : "이름이 올바르지 않습니다.";
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "이메일"),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      final RegExp regExp = RegExp(
                          r'([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$');
                      return regExp.hasMatch(value!) ? null : "이메일이 올바르지 않습니다.";
                    },
                  ),
                ],
              ),
            ),
            H4PayButton(
              text: "찾기",
              onClick: () async {
                if (_findIdFormKey.currentState!.validate()) {
                  // 입력값이 정상이면
                  final H4PayResult findResult = await _findId(
                    _nameController.text,
                    _emailController.text,
                  );
                  showSnackbar(
                      context,
                      findResult.data,
                      findResult.success ? Colors.green : Colors.red,
                      Duration(seconds: 1));
                }
              },
              backgroundColor: Color(0xff5B82D1),
              width: double.infinity,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Text("비밀번호 찾기"),
            Form(
              key: _findPwFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "이름"),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final RegExp regExp = RegExp(r'^[가-힣]{2,8}$');
                      return regExp.hasMatch(value!) ? null : "이름이 올바르지 않습니다.";
                    },
                  ),
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(labelText: "아이디"),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final RegExp regExp = RegExp(r'^[A-za-z0-9]{5,15}$');
                      return regExp.hasMatch(value!) ? null : "아이디가 올바르지 않습니다.";
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "이메일"),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      final RegExp regExp = RegExp(
                          r'([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$');
                      return regExp.hasMatch(value!) ? null : "이메일이 올바르지 않습니다.";
                    },
                  ),
                ],
              ),
            ),
            H4PayButton(
              text: "찾기",
              onClick: () async {
                if (_findPwFormKey.currentState!.validate()) {
                  // 입력값이 정상이면
                  final H4PayResult findResult = await _findPw(
                      _nameController.text,
                      _emailController.text,
                      _idController.text);
                  showSnackbar(
                      context,
                      findResult.data,
                      findResult.success ? Colors.green : Colors.red,
                      Duration(seconds: 1));
                }
              },
              backgroundColor: Color(0xff5B82D1),
              width: double.infinity,
            )
          ],
        ),
      ),
    );
  }

  Future<H4PayResult> _findId(String name, String email) async {
    final _prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse("$API_URL/users/find/uid"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        "name": name,
        "email": email,
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return H4PayResult(
        success: jsonResponse['status'],
        data: jsonResponse['message'],
      );
    } else {
      return H4PayResult(
        success: false,
        data: "서버 오류입니다.",
      );
    }
  }

  Future<H4PayResult> _findPw(String name, String email, String uid) async {
    final _prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse("$API_URL/users/find/password"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({"name": name, "email": email, "uid": uid}),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return H4PayResult(
        success: jsonResponse['status'],
        data: jsonResponse['message'],
      );
    } else {
      return H4PayResult(
        success: false,
        data: "서버 오류입니다.",
      );
    }
  }
}
