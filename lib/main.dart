import 'dart:async';
import 'dart:convert' as JSON;
import 'dart:io';

import 'package:chakh_ley_delivery_boy/home_page.dart';
import 'package:chakh_ley_delivery_boy/models/user_pref.dart';
import 'package:chakh_ley_delivery_boy/pages/otp.dart';
import 'package:chakh_ley_delivery_boy/static_variables/static_variables.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sentry/sentry.dart';

import 'entity/api_static.dart';
import 'models/user_post.dart';

void main() {
  ConstantVariables.sentryClient =
      SentryClient(dsn: ConstantVariables.sentryDSN);

  runZoned(() async {
    runApp(MyApp());
  }, onError: (error, stackTrace) async {
    // print(error);
    await ConstantVariables.sentryClient.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chakh Le - Delivery Boy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.red, appBarTheme: AppBarTheme(elevation: 0)),
      home: LoginPage(),
      routes: <String, WidgetBuilder>{
        '/homepage': (BuildContext context) => HomePage(),
        '/loginpage': (BuildContext context) => LoginPage(),
      },
    );
  }
}

String buttonText = "ENTER MOBILE";
bool enableLogin = false;
bool enableOtp = false;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Avenir - Bold', fontSize: 15.0);
  TextEditingController _phnController = TextEditingController();
  bool loggedIn = true;
  bool _phnEnabled = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    getDetails().then((val) {
      ConstantVariables.user = val;
    });

    isLoggedIn().then((val) {
      if (val) {
        Navigator.pushReplacementNamed(context, '/homepage');
      } else {
        setState(() {
          loggedIn = false;
        });
      }
    });

    _phnController.addListener(getButtonText);
  }

  void _showOTPBottomSheet(
      GlobalKey<ScaffoldState> scaffoldKey, String destination) {
    scaffoldKey.currentState
        .showBottomSheet<void>((BuildContext context) {
          return OTPBottomSheet(destination);
        })
        .closed
        .whenComplete(() {});
  }

  void getButtonText() {
    if (_phnController.text.trim().length != 10) {
      setState(() {
        buttonText = "ENTER VALID MOBILE";
        enableLogin = false;
      });
    } else {
      setState(() {
        enableLogin = true;
        buttonText = "SEND OTP";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final phnField = TextField(
      style: style,
      controller: _phnController,
      keyboardType: TextInputType.number,
      enabled: _phnEnabled,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
        hintText: "Mobile Number",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );

    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: enableLogin ? Colors.red : Colors.redAccent.shade100,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: enableLogin
            ? () {
                setState(() {
                  enableLogin = false;
                  _phnEnabled = false;
                });
                loginUserPost();
              }
            : null,
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: style.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[200],
      key: _scaffoldKey,
      body: loggedIn
          ? Container()
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 130.0,
                          child: Image.asset(
                            "assets/logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 45.0),
                        phnField,
                        SizedBox(
                          height: 35.0,
                        ),
                        loginButton,
                        SizedBox(
                          height: 15.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<http.Response> createPost(LoginPost post) async {
    final response = await http.post(UserStatic.keyOtpURL,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: postLoginToJson(post));

    return response;
  }

  loginUserPost() {
    LoginPost post = LoginPost(
      destination: _phnController.text,
      isLogin: "true",
    );

    // ignore: missing_return
    createPost(post).then((response) {
      if (response.statusCode == 201) {
        // print(response.body);
        _showOTPBottomSheet(_scaffoldKey, _phnController.text.trim());
        Fluttertoast.showToast(
          msg: "OTP has been sent to your registered mobile number.",
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );
        return "true";
      } else if (response.statusCode == 403) {
        // OTP requesting not allowed
        var json = JSON.jsonDecode(response.body);
        assert(json is Map);
        Fluttertoast.showToast(
          msg: json['detail'],
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );
      } else if (response.statusCode >= 400) {
        Fluttertoast.showToast(
          msg: "You are not a valid delivery boy!",
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );
      } else {
        // print(response.statusCode);
      }

      setState(() {
        _phnEnabled = true;
      });
    }).catchError((error) {
      // print('error : $error');
    });
  }
}
