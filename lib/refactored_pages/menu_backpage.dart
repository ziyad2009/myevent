import 'package:flutter/material.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/pages/signup.dart';
import 'package:myevents/widgets/shrine_backdrop.dart';

class MenuListPage extends StatelessWidget {
  final Function backdropCallback;
  const MenuListPage({Key key, this.backdropCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor,
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FlatButton(
            child: new Text(
              "Home",
              style: backdropListStyle,
            ),
            onPressed: () {
              backdropCallback(FrontPages.HomeSimple);
            },
          ),
          FlatButton(
            child: new Text(
              "Chats",
              style: backdropListStyle,
            ),
            onPressed: () {
              backdropCallback(FrontPages.Chats);
            },
          ),
          FlatButton(
            child: new Text(
              "Help & Support",
              style: backdropListStyle,
            ),
            onPressed: () {
              backdropCallback(FrontPages.HelpSupport);
            },
          ),
          FlatButton(
            child: new Text(
              "Logout",
              style: backdropListStyle,
            ),
            onPressed: () async {
              BackendService backendService = locator<BackendService>();
              await backendService.savePrefrences("token", null);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SignUpPage()));
            },
          ),
        ],
      )),
    );
  }
}
