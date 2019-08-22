import 'dart:convert' as JSON;
import 'dart:io';

import 'package:chakh_ley_delivery_boy/entity/api_static.dart';
import 'package:chakh_ley_delivery_boy/models/user_post.dart';
import 'package:chakh_ley_delivery_boy/models/user_pref.dart';
import 'package:chakh_ley_delivery_boy/static_variables/static_variables.dart';
import 'package:chakh_ley_delivery_boy/utils/parse_jwt.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';

class OTPBottomSheet extends StatefulWidget {
  @override
  _OTPBottomSheetState createState() => _OTPBottomSheetState();

  final String destination;

  static String name, phone;

  OTPBottomSheet(this.destination);
}

class _OTPBottomSheetState extends State<OTPBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return otpBottomSheet();
  }

  Widget otpBottomSheet() {
    return Container(
      alignment: Alignment.topLeft,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5.0, right: 5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, bottom: 5.0, left: 15.0),
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                      fontFamily: 'Avenir-Black',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    'OTP has been sent to your registered mobile number.',
                    style: TextStyle(
                      fontFamily: 'Avenir-Bold',
                      fontSize: 13.0,
                      fontWeight: FontWeight.w300,
                      color: Colors.black54,
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: PinCodeTextField(
                autofocus: false,
                maxLength: 5,
                onDone: (pin) {
                  verifyOTP(pin);
                },
                pinBoxHeight: 50.0,
                pinBoxWidth: 50.0,
                defaultBorderColor: Colors.grey.shade800,
                pinTextStyle: TextStyle(
                    fontFamily: 'Avenir-Black',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0,
                    color: Colors.black87),
                pinTextAnimatedSwitcherTransition:
                    ProvidedPinBoxTextAnimation.scalingTransition,
                pinTextAnimatedSwitcherDuration: Duration(milliseconds: 150),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<http.Response> createOTPPost(VerifyLoginOTPPost post) async {
    final response = await http.post(
      UserStatic.keyOtpURL,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: postVerifyLoginOTPToJson(post),
    );

    return response;
  }

  void verifyOTP(String pin) {
    VerifyLoginOTPPost post = VerifyLoginOTPPost(
        destination: widget.destination, isLogin: "true", verifyOTP: pin);

    createOTPPost(post).then((response) {
      validate(response);
    });
  }

  void saveUserCredentials(int id, String mobile, String name) {
    ConstantVariables.user['mobile'] = mobile;
    ConstantVariables.user['name'] = name;
    ConstantVariables.user['id'] = "$id";
    ConstantVariables.userLoggedIn = true;

    saveUser(id, name, mobile);
    loginUser();
  }

  ///
  /// SAMPLE PAYLOAD DATA JWT
  ///
  /// {
  ///  "user_id": 1,
  ///  "is_admin": true,
  ///  "exp": 1563122247,
  ///  "email": "mahengandhi19@gmail.com",
  ///  "mobile": "9881745553",
  ///  "name": "Mahen Gandhi",
  ///  "username": "imlegend19"
  /// }
  ///

  void validate(http.Response response) async {
    if (response.statusCode == 403) {
      var json = JSON.jsonDecode(response.body);
      assert(json is Map);

      await ConstantVariables.sentryClient.captureException(
        exception: Exception("Order Patch Error"),
        stackTrace:
            '[object: ${json['detail']}, response.body: ${response.body}, '
            'response.headers: ${response.headers}, response: $response,'
            'status code: ${response.statusCode}]',
      );

      Fluttertoast.showToast(
        msg: json['detail'],
        fontSize: 13.0,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2,
      );
    } else if (response.statusCode == 202) {
      var json = JSON.jsonDecode(response.body);
      assert(json is Map);

      String token = json["token"];
      // print(token);
      var decodedObject = parseJwt(token);

      Fluttertoast.showToast(
        msg: "Logged In Successfully !!!",
        fontSize: 13.0,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2,
      );

      saveUserCredentials(decodedObject['user_id'], decodedObject['mobile'],
          decodedObject['name']);
      Navigator.popAndPushNamed(context, '/homepage');
    } else {
      var json = JSON.jsonDecode(response.body);
      assert(json is Map);

      await ConstantVariables.sentryClient.captureException(
        exception: Exception("Order Patch Error"),
        stackTrace:
            '[object: ${json['detail']}, response.body: ${response.body}, '
            'response.headers: ${response.headers}, response: $response,'
            'status code: ${response.statusCode}]',
      );

      Fluttertoast.showToast(
        msg: json['detail'],
        fontSize: 13.0,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2,
      );
    }
  }
}
