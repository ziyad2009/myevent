import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/widgets/main_page.dart';
import 'package:myevents/widgets/otp_pin.dart';

import '../locator.dart';

enum PhoneAuthState {
  None,
  AutoComplete,
  CodeSent,
  Failed,
  AutoRetrieveTimeout,
  Verified
}

class PhoneSignIn extends StatefulWidget {
  @override
  _PhoneSignInState createState() => _PhoneSignInState();
}

class _PhoneSignInState extends State<PhoneSignIn> {
  final _signInformKey = GlobalKey<FormState>();
  bool _inAsync = false;
  bool _isNewLogin = false;
  bool _termsAgree = false;

  final BackendService _backendService = locator<BackendService>();
  TextEditingController _phoneNumber = TextEditingController();

  String _verificationId;
  FirebaseAuth _auth = FirebaseAuth.instance;
  PhoneAuthState _phoneAuthState = PhoneAuthState.None;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50, left: 24, right: 24),
        child: SingleChildScrollView(
          child: Form(
            key: _signInformKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset(
                        "lib/assets/myevents_logo.png",
                        height: 142,
                        width: 132,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text("Enter mobile number", style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        "🇸🇦 +966",
                        style: TextStyle(
                            color: exoticPurple,
                            height: 1,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextFormField(
                          controller: _phoneNumber,
                          enabled: !_inAsync,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(9),
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          validator: (String val) {
                            if (val.length != 9)
                              return "Please enter a valid number";
                            else
                              return null;
                          },
                          decoration: new InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(6.0, 10.0, 15.0, 10.0),
                            hintText: "** *** ****",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                letterSpacing: 1.25,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 0.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("I have read the terms and conditions",
                        style: TextStyle(color: exoticPurple)),
                    Checkbox(
                        value: _termsAgree,
                        onChanged: (bool val) {
                          setState(() {
                            _termsAgree = val;
                          });
                        })
                  ],
                ),
                Visibility(
                    child: Text("Enter the code",
                        style: TextStyle(fontSize: 21, color: exoticPurple)),
                    visible: _phoneAuthState == PhoneAuthState.CodeSent ||
                        _phoneAuthState == PhoneAuthState.AutoRetrieveTimeout),
                SizedBox(height: 4),
                Visibility(
                  visible: _phoneAuthState == PhoneAuthState.CodeSent ||
                      _phoneAuthState == PhoneAuthState.AutoRetrieveTimeout,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: PinView(
                      count: 6,
                      autoFocusFirstField: false,
                      style: TextStyle(
                          fontSize: 19.0, fontWeight: FontWeight.w500),
                      submit: (String pinCode) async {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        FirebaseUser user =
                            await _signInWithPhoneNumber(pinCode);
                        if (user != null) {
                          if (_isNewLogin) {
                            print("Firebase isNewLogin $_isNewLogin");
                            await _signUpWithStrapi(
                                user.uid, _backendService.getGraphClient());
                          } else {
                            print("Firebase isNewLogin $_isNewLogin");
                            await _signInToStrapi(user.uid);
                          }
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Visibility(
                      visible: !_inAsync,
                      child: GraphQLConsumer(
                        builder: (client) => RaisedButton(
                          color: primaryColor,
                          child: Text("NEXT",
                              style: TextStyle(color: Colors.white)),
                          onPressed: () async {
                            if (_phoneNumber.text.isEmpty) {
                              BotToast.showText(
                                  text:
                                      "Please enter mobile number to continue");
                              return;
                            }

                            if (!_termsAgree) {
                              BotToast.showText(
                                  text:
                                      "Please accept the terms and conditions to continue");
                              return;
                            }

                            _verifyPhoneNumber();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Visibility(
                  visible: _inAsync,
                  child: Column(
                    children: <Widget>[
                      Text("Please wait..."),
                      LinearProgressIndicator(
                        semanticsLabel: "Signing in...",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      BotToast.showText(text: "Number Verified");
      setState(() {
        _inAsync = true;
        _phoneAuthState = PhoneAuthState.Verified;
      });
      AuthResult authResult =
          await _auth.signInWithCredential(phoneAuthCredential);
      if (authResult != null) {
        _isNewLogin = authResult.additionalUserInfo.isNewUser;
      } else {
        BotToast.showText(
            text: "Number could not be verified. Try again later");
        return null;
      }
      final FirebaseUser currentUser = await _auth.currentUser();
      if (currentUser != null) {
        if (_isNewLogin) {
          await _signUpWithStrapi(
              currentUser.uid, _backendService.getGraphClient());
        } else {
          await _signInToStrapi(currentUser.uid);
        }
      } else {
        BotToast.showText(
            text: "Number could not be verified. Try again later");
      }
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      BotToast.showText(text: "❗Phone login failed: ${authException.message}");
      setState(() {
        _phoneAuthState = PhoneAuthState.None;
        _phoneNumber.clear();
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      BotToast.showText(text: "Please check your phone for pin code");
      _verificationId = verificationId;
      setState(() {
        _phoneAuthState = PhoneAuthState.CodeSent;
      });
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _phoneAuthState = PhoneAuthState.AutoRetrieveTimeout;
      });
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumberFormatter(changeDigit(_phoneNumber.text, true)),
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  // Example code of how to sign in with phone.
  Future<FirebaseUser> _signInWithPhoneNumber(String pinCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: pinCode,
    );
    try {
      AuthResult authResult = await _auth.signInWithCredential(credential);
      if (authResult != null) {
        _isNewLogin = authResult.additionalUserInfo.isNewUser;
        return authResult.user;
      }
    } catch (error) {
      if (error.code == "ERROR_INVALID_VERIFICATION_CODE") {
        BotToast.showText(text: "Incorrect Code! Try again");
        setState(() {
          _phoneAuthState = PhoneAuthState.None;
        });
      }
    }
    return null;
  }

  Future _signInToStrapi(String firebaseID) async {
    if (firebaseID != null) {
      setState(() {
        _inAsync = true;
      });
      String email = "$firebaseID@redclover.co";
      String password = firebaseID;
      String signInResponse =
          await _backendService.loginAccount(email, password);
      int getMeStatus = await _backendService.getMe();

      if (signInResponse == "success")
        BotToast.showText(text: "✅ Login Successful");
      else
        BotToast.showText(text: "$signInResponse");

      if (signInResponse == "success" && getMeStatus == 200) {
        setState(() {
          _inAsync = false;
        });
        GraphQLProvider.of(context).value = _backendService.getGraphClient();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        setState(() {
          _inAsync = false;
        });
      }
    }
  }

  Future _signUpWithStrapi(String firebaseID, GraphQLClient client) async {
    setState(() {
      _inAsync = true;
    });
    String email = "$firebaseID@redclover.co";
    String password = firebaseID;
    String username = email.split("@").first;
    String signUpResponse = await _backendService.createAccount(
        email, username, password, _phoneNumber.text, firebaseID);

    if (signUpResponse == "success") {
      int getMeStatus = await _backendService.getMe();
      if (signUpResponse == "success" && getMeStatus == 200) {
        BotToast.showText(text: "✅ Login Successful");
        setState(() {
          _inAsync = false;
        });
        GraphQLProvider.of(context).value = _backendService.getGraphClient();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      }
    } else {
      setState(() {
        _inAsync = false;
      });
      BotToast.showText(text: signUpResponse);
      return;
    }
  }

  bool checkNewUserFromMeta(FirebaseUser user) {
    // https://stackoverflow.com/questions/57645912/
    return user.metadata.lastSignInTime.millisecondsSinceEpoch -
            user.metadata.creationTime.millisecondsSinceEpoch <
        10;
  }
}
