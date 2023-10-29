import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String dialogTitle;
  final String deleteContent;
  final String yesButton;
  final String noButton;

  DeleteConfirmationDialog(
      {this.dialogTitle, this.deleteContent, this.yesButton, this.noButton});

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text(
        noButton ?? "Cancel",
        style: TextStyle(color: primaryColor),
      ),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        yesButton ?? "Continue",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () async {
        Navigator.of(context).pop(true);
      },
    );
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      title: Text(dialogTitle),
      content: Text(deleteContent),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}
