import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:share/share.dart';

class PostAdDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Congratulations",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w700),
            ),
            Text(
              "Your Ad is posted",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Icon(
              Icons.share,
              color: primaryColor,
            ),
            SizedBox(height: 20),
            OutlineButton(
              child: Text("Share Ad", style: TextStyle(color: primaryColor)),
              onPressed: () {
                Share.share("Hi, check out this amazing deal!");
              },
            ),
            OutlineButton(
              child: Text("View Ad", style: TextStyle(color: primaryColor)),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        ),
      ),
    );
  }
}
