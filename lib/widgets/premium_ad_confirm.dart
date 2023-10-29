import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';

class PremiumAdConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      title: Text(
        "Premium Ad",
      ),
      content: Text(
          "Ads with video showcasing are considered premium.\n\nAre you sure you want to continue to the payment step?"),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(
            "BACK",
            style: TextStyle(color: exoticPurple, letterSpacing: 1.25),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(
            "NEXT",
            style: TextStyle(color: exoticPurple, letterSpacing: 1.25),
          ),
        )
      ],
    );
  }
}
