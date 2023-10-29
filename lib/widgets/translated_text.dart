import 'package:flutter/material.dart';

/* 
  Custom text widget to support translation with less boilerplate code
  Basically, the call to AppLocaliztion(key) etc. all will be done here
  [Style] is provided as a parameter accordingly
*/

class Arabic extends StatelessWidget {
  final String tr;
  final TextStyle style;
  Arabic({this.tr, this.style});
  @override
  Widget build(BuildContext context) {
    return Text(tr, style: style);
  }
}
