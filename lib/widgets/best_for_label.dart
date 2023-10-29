import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';

class BestForLabel extends StatelessWidget {
  final String labelText;

  const BestForLabel({Key key, this.labelText}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        labelText,
        style: TextStyle(
            color: exoticPurple, fontSize: 12, letterSpacing: 1.25, height: 1),
      ),
    );
  }
}
