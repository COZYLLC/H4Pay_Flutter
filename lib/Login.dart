import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay_flutter/Register.dart';
import 'package:h4pay_flutter/User.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:h4pay_flutter/components/Button.dart';
import 'package:h4pay_flutter/main.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:connectivity/connectivity.dart';

class LoginPage extends StatefulWidget {
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
    Firebase.initializeApp();
    _loginCheck();
  }

  Future _loginCheck() async {
    await logout();
  }

  @override
  Widget build(BuildContext context) {
    final _idFormKey = GlobalKey<FormState>();
    final _pwFormKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("로그인"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          margin: EdgeInsets.all(40),
          child: Column(
            children: [
              Form(
                key: _idFormKey,
                child: TextFormField(
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
                    _idFormKey.currentState!.validate();
                  },
                ),
              ),
              Form(
                key: _pwFormKey,
                child: TextFormField(
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
                    _pwFormKey.currentState!.validate();
                  },
                ),
              ),
              H4PayButton(
                text: "googleLogin",
                onClick: _signInWithGoogle,
                backgroundColor: Colors.lightBlue,
                width: double.infinity,
              ),
              SignInWithAppleButton(onPressed: _signInWithApple),
              H4PayButton(
                text: "로그인",
                width: double.infinity,
                onClick: () async {
                  _idFormKey.currentState!.validate();
                  _pwFormKey.currentState!.validate();
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
                backgroundColor: Colors.lightBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    final response = await http.post(
      Uri.parse("${dotenv.env['API_URL']}/users/auth/google"),
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

  Future<bool> _login(String id, String pw) async {
    final bytes = utf8.encode(pw);
    final digest = sha256.convert(bytes);
    final response = await http.post(
      Uri.parse("${dotenv.env['API_URL']}/users/login"),
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

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [],
      ),
    );
  }
}
