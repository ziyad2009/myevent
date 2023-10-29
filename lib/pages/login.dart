import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/pages/signup.dart';
import 'package:myevents/widgets/main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _signInformKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  bool _inAsync = false;
  final BackendService _backendService = locator<BackendService>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 43, right: 43, top: 43),
        child: SingleChildScrollView(
          child: Form(
            key: _signInformKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    "lib/assets/myevents_logo.png",
                    height: 264,
                    width: 192,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Sign In",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _emailController,
                  enabled: !_inAsync,
                  keyboardType: TextInputType.emailAddress,
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
                    ),
                  ),
                  validator: (val) =>
                      RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                              .hasMatch(val)
                          ? null
                          : 'Incorrect email',
                ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _passwordController,
                  enabled: !_inAsync,
                  obscureText: _hidePassword,
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
                    ),
                    suffixIcon: IconButton(
                      icon: _hidePassword
                          ? Icon(
                              Icons.visibility_off,
                              color: Colors.grey,
                            )
                          : Icon(
                              Icons.visibility,
                              color: primaryColor,
                            ),
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                    ),
                  ),
                  validator: (val) => val.length < 6
                      ? 'Minimum password length is 6 characters'
                      : null,
                ),
                SizedBox(
                  height: 8,
                ),
                Visibility(
                  visible: _inAsync,
                  child: LinearProgressIndicator(
                    semanticsLabel: "Please Wait...",
                  ),
                ),
                Visibility(
                  visible: !_inAsync,
                  child: RaisedButton(
                    color: primaryColor,
                    child: Text("LOGIN", style: raisedTextStyle),
                    onPressed: () async {
                      if (_signInformKey.currentState.validate()) {
                        setState(() {
                          _inAsync = true;
                        });
                        String email = _emailController.text.trim();
                        String password = _passwordController.text;
                        String authResponse =
                            await _backendService.loginAccount(email, password);
                        Fluttertoast.showToast(msg: authResponse);
                        setState(() {
                          _inAsync = false;
                        });
                        if (authResponse == "success") {
                          GraphQLProvider.of(context).value =
                              _backendService.getGraphClient();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainPage()));
                        }
                      }
                    },
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FlatButton(
        child: Text(
          "DON'T HAVE AN ACCOUNT? REGISTER HERE!",
          style: flatTextStyle,
        ),
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignUpPage()));
        },
      ),
    );
  }
}
