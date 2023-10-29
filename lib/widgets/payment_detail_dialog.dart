import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';

class PaymentDetailDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      title: Text(
        "Add Payment Method",
      ),
      content: Column(
        children: <Widget>[],
      ),
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
